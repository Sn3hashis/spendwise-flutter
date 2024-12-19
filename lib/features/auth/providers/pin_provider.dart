import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final pinProvider = StateNotifierProvider<PinNotifier, String?>((ref) {
  return PinNotifier();
});

class PinNotifier extends StateNotifier<String?> {
  PinNotifier() : super(null);
  
  Future<void> loadPin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot load PIN: No user logged in');
      state = null;
      return;
    }

    try {
      debugPrint('Loading PIN for user: ${user.uid}');
      
      // Try local storage first
      final prefs = await SharedPreferences.getInstance();
      final localPin = prefs.getString('user_pin_${user.uid}');
      
      if (localPin != null) {
        debugPrint('PIN found in local storage');
        state = localPin;
        return;
      }

      // If not in local storage, try Firebase
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!doc.exists) {
        debugPrint('No document found for user ${user.uid}');
        state = null;
        return;
      }

      final data = doc.data()!;
      debugPrint('Firebase data: $data');
      
      if (data.containsKey('pin') && data['pin'] != null) {
        final pin = data['pin'] as String;
        debugPrint('PIN found in Firebase: $pin');
        
        // Save to local storage
        await prefs.setString('user_pin_${user.uid}', pin);
        
        state = pin;
        return;
      }

      debugPrint('No PIN found for user ${user.uid}');
      state = null;
    } catch (e) {
      debugPrint('Error loading PIN: $e');
      state = null;
    }
  }

  Future<void> setPin(String pin) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'pin': pin,
        'hasPin': true,
        'pinCreatedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin_${user.uid}', pin);
      
      state = pin;
    } catch (e) {
      debugPrint('Error setting PIN: $e');
      rethrow;
    }
  }

  Future<void> clearLocalPin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Only clear from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_pin_${user.uid}');
      
      state = null;
    } catch (e) {
      debugPrint('Error clearing local PIN: $e');
      rethrow;
    }
  }
} 