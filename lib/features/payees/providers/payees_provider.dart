import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/payee_model.dart';

class PayeesNotifier extends StateNotifier<List<Payee>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Set<String> _deletedIds = {};  // Track deleted payees

  PayeesNotifier() : super([]) {
    _initializePayees();
  }

  Future<void> _initializePayees() async {
    try {
      await _loadFromLocal();
      await syncWithFirebase();
    } catch (e) {
      debugPrint('[PayeesNotifier] Error initializing payees: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      debugPrint('[PayeesNotifier] Loading payees from local storage...');
      final prefs = await SharedPreferences.getInstance();
      final payeesJson = prefs.getStringList('payees') ?? [];
      
      final loadedPayees = payeesJson
          .map((json) => Payee.fromJson(jsonDecode(json)))
          .toList();
      
      state = loadedPayees;
      debugPrint('[PayeesNotifier] Loaded ${state.length} payees from local storage');
    } catch (e) {
      debugPrint('[PayeesNotifier] Error loading payees from local: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      debugPrint('[PayeesNotifier] Saving payees to local storage...');
      final prefs = await SharedPreferences.getInstance();
      final payeesJson = state
          .map((payee) => jsonEncode(payee.toJson()))
          .toList();
      
      await prefs.setStringList('payees', payeesJson);
      debugPrint('[PayeesNotifier] Saved ${state.length} payees to local storage');
    } catch (e) {
      debugPrint('[PayeesNotifier] Error saving to local storage: $e');
    }
  }

  Future<void> syncWithFirebase() async {
    try {
      debugPrint('[PayeesNotifier] Starting Firebase sync...');
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('[PayeesNotifier] No user logged in, skipping sync');
        return;
      }

      final payeesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payees');

      // Get existing payees to handle deletions
      final snapshot = await payeesRef.get();
      final existingIds = snapshot.docs.map((doc) => doc.id).toSet();

      // First sync local to Firebase
      for (var payee in state) {
        final docRef = payeesRef.doc(payee.id);
        final data = {
          ...payee.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        await docRef.set(data, SetOptions(merge: true));
        existingIds.remove(payee.id);
      }

      // Delete payees that no longer exist locally
      for (var id in existingIds) {
        if (_deletedIds.contains(id)) {
          await payeesRef.doc(id).delete();
        }
      }

      // Then sync Firebase to local
      final updatedSnapshot = await payeesRef.get();
      final payees = updatedSnapshot.docs
          .map((doc) => Payee.fromJson(doc.data()))
          .toList();

      state = payees;
      await _saveToLocal();
      
      debugPrint('[PayeesNotifier] Successfully synced payees with Firebase');
    } catch (e) {
      debugPrint('[PayeesNotifier] Error syncing with Firebase: $e');
      rethrow;
    }
  }

  Future<void> addPayee(Payee payee) async {
    try {
      state = [...state, payee];
      await _saveToLocal();
      await syncWithFirebase();
    } catch (e) {
      debugPrint('[PayeesNotifier] Error adding payee: $e');
      rethrow;
    }
  }

  Future<void> updatePayee(Payee payee) async {
    try {
      state = [
        for (final p in state)
          if (p.id == payee.id) payee else p
      ];
      await _saveToLocal();
      await syncWithFirebase();
    } catch (e) {
      debugPrint('[PayeesNotifier] Error updating payee: $e');
      rethrow;  
    }
  }

  Future<void> deletePayee(String id) async {
    try {
      _deletedIds.add(id);  // Mark as deleted
      state = state.where((p) => p.id != id).toList();
      await _saveToLocal();
      await syncWithFirebase();
    } catch (e) {
      debugPrint('[PayeesNotifier] Error deleting payee: $e');
      rethrow;
    }
  }
}

final payeesProvider = StateNotifierProvider<PayeesNotifier, List<Payee>>((ref) {
  return PayeesNotifier();
});