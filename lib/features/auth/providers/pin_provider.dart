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
  
  Future<void> setPin(String pin) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot set PIN: No user logged in');
      return;
    }

    try {
      debugPrint('Setting PIN for user: ${user.uid}');
      
      // Save to Firebase
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.set({
        'pin': pin,
        'hasPin': true,
        'pinCreatedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin_${user.uid}', pin);
      
      state = pin;
      debugPrint('PIN set successfully: $pin');
    } catch (e) {
      debugPrint('Error setting PIN: $e');
      rethrow;
    }
  }

  Future<void> loadPin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot load PIN: No user logged in');
      state = null;
      return;
    }

    try {
      debugPrint('Loading PIN for user: ${user.uid}');
      
      // Try Firebase first
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

      // Check if PIN exists in Firebase
      if (data.containsKey('pin') && data['pin'] != null) {
        final pin = data['pin'] as String;
        debugPrint('PIN found in Firebase: $pin');
        
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_pin_${user.uid}', pin);
        
        state = pin;
        return;
      }

      // If no PIN in Firebase but hasPin is true, something went wrong
      if (data['hasPin'] == true) {
        // Try local storage as fallback
        final prefs = await SharedPreferences.getInstance();
        final localPin = prefs.getString('user_pin_${user.uid}');
        
        if (localPin != null) {
          debugPrint('PIN found in local storage: $localPin');
          // Sync back to Firebase
          await setPin(localPin);
          return;
        }
      }

      debugPrint('No PIN found for user ${user.uid}');
      state = null;
    } catch (e) {
      debugPrint('Error loading PIN: $e');
      state = null;
    }
  }

  Future<void> clearPin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Clear from Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'pin': FieldValue.delete(),
            'hasPin': false,
          });
      
      // Clear from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_pin_${user.uid}');
      
      state = null;
      debugPrint('PIN cleared successfully');
    } catch (e) {
      debugPrint('Error clearing PIN: $e');
      rethrow;
    }
  }
} 