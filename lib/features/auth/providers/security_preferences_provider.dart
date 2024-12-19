import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum SecurityMethod {
  pin,
  biometric,
}

final securityPreferencesProvider = StateNotifierProvider<SecurityPreferencesNotifier, SecurityMethod>((ref) {
  return SecurityPreferencesNotifier();
});

class SecurityPreferencesNotifier extends StateNotifier<SecurityMethod> {
  SecurityPreferencesNotifier() : super(SecurityMethod.pin);

  Future<void> loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = SecurityMethod.pin;
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        state = SecurityMethod.pin;
        return;
      }

      final data = doc.data()!;
      final methodString = data['securityMethod'] as String?;
      
      if (methodString != null) {
        state = SecurityMethod.values.firstWhere(
          (e) => e.toString() == methodString,
          orElse: () => SecurityMethod.pin,
        );
      } else {
        state = SecurityMethod.pin;
      }
    } catch (e) {
      debugPrint('Error loading security preferences: $e');
      state = SecurityMethod.pin;
    }
  }

  Future<void> setSecurityMethod(SecurityMethod method) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'securityMethod': method.toString(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      state = method;
    } catch (e) {
      debugPrint('Error setting security method: $e');
      rethrow;
    }
  }
} 