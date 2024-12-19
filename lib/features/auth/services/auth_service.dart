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

import '../providers/pin_provider.dart';
import '../providers/user_provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    signInOption: SignInOption.standard,
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Email/Password Sign Up with OTP
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update user's display name
      await userCredential.user?.updateDisplayName(name);

      // Generate and save OTP
      final otp = OTPService.generateOTP();
      await OTPService.saveOTP(email, otp);

      // Send OTP email
      await EmailService.sendOTPEmail(email, otp);

      // Sign out until verified
      await _auth.signOut();
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
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // Google Sign In
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Start sign in flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user == null) {
        throw 'Failed to sign in with Google';
      }

      // Create or update user document in Firestore
      await _createOrUpdateUserDocument(userCredential.user!);

      return userCredential;
    } catch (e) {
      debugPrint('Error in Google Sign In: $e');
      rethrow;
    }
  }

  Future<void> _createOrUpdateUserDocument(User user) async {
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      
      // Get existing document
      final doc = await userDoc.get();
      
      if (!doc.exists) {
        // Create new user document with initial PIN state
        await userDoc.set({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
          'hasPin': false,
          'pin': null,
        });
      } else {
        // Update existing document but preserve PIN and hasPin
        final updates = {
          'lastLogin': FieldValue.serverTimestamp(),
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
        };

        // If PIN exists but hasPin is not set, set it
        final data = doc.data();
        if (data != null && data.containsKey('pin') && data['pin'] != null && !(data['hasPin'] as bool? ?? false)) {
          updates['hasPin'] = true;
        }

        await userDoc.update(updates);
      }
    } catch (e) {
      debugPrint('Error creating/updating user document: $e');
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
      // Only clear PIN from local storage
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await prefs.remove('user_pin_${user.uid}');
      }
      
      // Clear onboarding status
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