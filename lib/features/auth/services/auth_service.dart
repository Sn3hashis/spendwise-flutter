import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:spendwise/features/auth/services/otp_service.dart';
import 'package:spendwise/features/auth/services/email_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise/features/auth/providers/pin_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../categories/providers/categories_provider.dart';

import '../providers/pin_provider.dart';
import '../providers/user_provider.dart';
import '../providers/security_preferences_provider.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../budget/providers/budget_provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    signInOption: SignInOption.standard,
  );
  final Ref ref;

  AuthService(this.ref);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up with OTP
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user with email and password first
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user's display name
      await userCredential.user?.updateDisplayName(name);

      // Generate OTP
      final otp = OTPService.generateOTP();
      
      // Save OTP and send email in parallel
      await Future.wait([
        OTPService.saveOTP(email, otp),
        EmailService.sendOTPEmail(email, otp),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () => [null, null], // Return empty list on timeout
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Verify OTP
  Future<UserCredential> verifyOTP({
    required String email,
    required String otp,
    required String password,
    required String name,
  }) async {
    try {
      final isValid = await OTPService.verifyOTP(email, otp);
      if (!isValid) {
        throw 'Invalid or expired OTP';
      }

      // If OTP is valid, sign in the user
      final userCredential = await signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user's display name after successful verification
      await userCredential.user?.updateDisplayName(name);

      return userCredential;
    } catch (e) {
      throw e.toString();
    }
  }

  // Email/Password Sign In
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create/update user document first
      await _createOrUpdateUserDocument(userCredential.user!);
      
      // Then restore all data in parallel
      await _restoreUserData();
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle({required GoogleSignInAccount? googleAccount}) async {
    try {
      if (googleAccount == null) {
        throw 'Google Sign In was cancelled';
      }

      // Get auth details - this is done in parallel
      final googleAuth = await googleAccount.authentication;
      
      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create/update user document in parallel with navigation
      _createOrUpdateUserDocument(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final userDoc = _firestore.collection('users').doc(user.uid);
      
      // Use set with merge to avoid unnecessary writes
      await userDoc.set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastSignIn': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating user document: $e');
      // Don't rethrow - this is not critical for login
    }
  }

  Future<void> _initializeUserData() async {
    try {
      debugPrint('[AuthService] Initializing user data...');
      await ref.read(categoriesProvider.notifier).loadCategories();
      await ref.read(transactionsProvider.notifier).loadTransactions();
      await ref.read(budgetProvider.notifier).loadBudgets();
      debugPrint('[AuthService] User data initialized successfully');
    } catch (e) {
      debugPrint('[AuthService] Error initializing user data: $e');
      rethrow;
    }
  }

  Future<void> _restoreUserData() async {
    try {
      debugPrint('[AuthService] Restoring user data...');
      await _initializeUserData();
      debugPrint('[AuthService] User data restored successfully');
    } catch (e) {
      debugPrint('[AuthService] Error restoring user data: $e');
      rethrow;
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Sign Out
  Future<void> signOut(WidgetRef ref) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Clear PIN from local storage only
        await ref.read(pinProvider.notifier).clearLocalPin();
        
        // Reset security preferences to PIN
        await ref.read(securityPreferencesProvider.notifier).setSecurityMethod(SecurityMethod.pin);
      }
      
      // Clear onboarding status
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('has_completed_onboarding');
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Firebase
      await _auth.signOut();
      
      // Clear user state
      ref.read(userProvider.notifier).state = null;
    } catch (e) {
      debugPrint('Error during sign out: $e');
      rethrow;
    }
  }

  // Helper method to handle Firebase Auth errors
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid credentials';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification ID';
      case 'network-request-failed':
        return 'Network error occurred. Please check your connection';
      default:
        return e.message ?? 'An error occurred during authentication';
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
}); 