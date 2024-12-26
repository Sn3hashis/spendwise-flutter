import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/payee_model.dart';

final payeeProvider = StateNotifierProvider<PayeeNotifier, List<Payee>>((ref) {
  return PayeeNotifier();
});

class PayeeNotifier extends StateNotifier<List<Payee>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  PayeeNotifier() : super([]) {
    loadPayees();
  }

  Future<void> loadPayees() async {
    try {
      debugPrint('[PayeeNotifier] Loading payees...');
      
      // First try to load from local storage
      final prefs = await SharedPreferences.getInstance();
      final payeesJson = prefs.getStringList('payees') ?? [];
      
      final localPayees = payeesJson
          .map((json) => Payee.fromJson(jsonDecode(json)))
          .toList();
      
      state = localPayees;
      debugPrint('[PayeeNotifier] Loaded ${localPayees.length} payees from local storage');
      
      // Then sync with Firebase
      await syncWithFirebase();
    } catch (e) {
      debugPrint('[PayeeNotifier] Error loading payees: $e');
    }
  }

  Future<void> _saveToLocalStorage(List<Payee> payees) async {
    try {
      debugPrint('[PayeeNotifier] Saving payees to local storage...');
      final prefs = await SharedPreferences.getInstance();
      final payeesJson = payees
          .map((payee) => jsonEncode(payee.toJson()))
          .toList();
      
      await prefs.setStringList('payees', payeesJson);
      debugPrint('[PayeeNotifier] Saved ${payees.length} payees to local storage');
    } catch (e) {
      debugPrint('[PayeeNotifier] Error saving to local storage: $e');
    }
  }

  Future<void> syncWithFirebase() async {
    try {
      debugPrint('[PayeeNotifier] Starting Firebase sync...');
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payees')
          .get();

      debugPrint('[PayeeNotifier] Found ${snapshot.docs.length} payees in Firebase');

      final payees = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Payee.fromJson(data);
      }).toList();

      state = payees;
      await _saveToLocalStorage(payees);
      debugPrint('[PayeeNotifier] Successfully completed Firebase sync');
    } catch (e) {
      debugPrint('[PayeeNotifier] Error during Firebase sync: $e');
    }
  }

  Future<void> addPayee(Payee payee) async {
    try {
      debugPrint('[PayeeNotifier] Adding new payee ${payee.id}');
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payees')
          .doc(payee.id)
          .set(payee.toJson());

      state = [...state, payee];
      await _saveToLocalStorage(state);
      debugPrint('[PayeeNotifier] Successfully added new payee');
    } catch (e) {
      debugPrint('[PayeeNotifier] Error adding payee: $e');
    }
  }

  Future<void> updatePayee(Payee updatedPayee) async {
    try {
      debugPrint('[PayeeNotifier] Updating payee ${updatedPayee.id}');
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payees')
          .doc(updatedPayee.id)
          .update(updatedPayee.toJson());

      final updatedPayees = state.map((payee) {
        return payee.id == updatedPayee.id ? updatedPayee : payee;
      }).toList();

      state = updatedPayees;
      await _saveToLocalStorage(updatedPayees);
      debugPrint('[PayeeNotifier] Successfully updated payee');
    } catch (e) {
      debugPrint('[PayeeNotifier] Error updating payee: $e');
    }
  }

  Future<void> deletePayee(String id) async {
    try {
      debugPrint('[PayeeNotifier] Deleting payee $id');
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payees')
          .doc(id)
          .delete();

      final updatedPayees = state.where((payee) => payee.id != id).toList();
      state = updatedPayees;
      await _saveToLocalStorage(updatedPayees);
      debugPrint('[PayeeNotifier] Successfully deleted payee');
    } catch (e) {
      debugPrint('[PayeeNotifier] Error deleting payee: $e');
    }
  }
}
