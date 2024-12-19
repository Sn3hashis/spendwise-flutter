import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(FirebaseAuth.instance.currentUser) {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      state = user;
    });
  }

  User? get currentUser => state;
} 