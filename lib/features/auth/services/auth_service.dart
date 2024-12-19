import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:spendwise/features/auth/services/otp_service.dart';
import 'package:spendwise/features/auth/services/email_service.dart';

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
  }) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

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
  }) async {
    try {
      final isValid = await OTPService.verifyOTP(email, otp);
      if (!isValid) {
        throw 'Invalid or expired OTP';
      }

      // If OTP is valid, sign in the user
      return await signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      // Sign out first to ensure clean state
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn()
          .timeout(const Duration(minutes: 1), onTimeout: () {
        throw 'Sign in timed out. Please try again.';
      });

      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication
          .timeout(const Duration(minutes: 1), onTimeout: () {
        throw 'Authentication timed out. Please try again.';
      });

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _auth.signInWithCredential(credential)
          .timeout(const Duration(minutes: 1), onTimeout: () {
        throw 'Firebase sign in timed out. Please try again.';
      });

      if (userCredential.user == null) {
        throw 'Failed to sign in with Google';
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      await _handleSignOutError();
      throw _handleFirebaseAuthError(e);
    } on PlatformException catch (e) {
      await _handleSignOutError();
      throw 'Platform error during Google sign in: ${e.message}';
    } catch (e) {
      await _handleSignOutError();
      if (e is String) {
        throw e;
      }
      throw 'Failed to sign in with Google: ${e.toString()}';
    }
  }

  Future<void> _handleSignOutError() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {
      // Ignore errors during sign out
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
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw 'Failed to sign out: ${e.toString()}';
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