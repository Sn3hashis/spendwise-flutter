import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(FirebaseAuth.instance.currentUser) {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = user;
      if (user == null) {
        // Clear PIN when user logs out
        SharedPreferences.getInstance().then((prefs) {
          prefs.remove('user_pin_${user?.uid}');
        });
      }
    });
  }

  Future<void> signOut() async {
    final user = state;
    if (user != null) {
      try {
        // Clear PIN before signing out
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('user_pin_${user.uid}');
        
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();
        state = null;
      } catch (e) {
        debugPrint('Error during sign out: $e');
        rethrow;
      }
    }
  }
} 