import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/budget_model.dart';
import '../../categories/models/category_model.dart';
import '../../categories/providers/categories_provider.dart';
import 'package:uuid/uuid.dart';

class BudgetNotifier extends StateNotifier<List<Budget>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref;
  final _uuid = const Uuid();
  
  BudgetNotifier(this.ref) : super([]) {
    debugPrint('[BudgetNotifier] Initializing...');
    _loadFromLocal();
  }

  Future<void> _loadFromLocal() async {
    try {
      debugPrint('[BudgetNotifier] Loading budgets from local storage...');
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getStringList('budgets') ?? [];
      
      state = budgetsJson
          .map((json) => Budget.fromJson(jsonDecode(json)))
          .toList();
      
      debugPrint('[BudgetNotifier] Loaded ${state.length} budgets from local storage');
      
      // After loading from local, try to sync with Firebase
      _syncWithFirebase();
    } catch (e) {
      debugPrint('[BudgetNotifier] Error loading budgets from local: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      debugPrint('[BudgetNotifier] Saving budgets to local storage...');
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = state
          .map((budget) => jsonEncode(budget.toJson()))
          .toList();
      
      await prefs.setStringList('budgets', budgetsJson);
      debugPrint('[BudgetNotifier] Saved ${state.length} budgets to local storage');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error saving budgets to local: $e');
    }
  }

  Future<void> _syncWithFirebase() async {
    try {
      debugPrint('[BudgetNotifier] Starting Firebase sync...');
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('[BudgetNotifier] No user logged in, skipping Firebase sync');
        return;
      }

      // First, try to get any newer data from Firebase
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .orderBy('updatedAt', descending: true)
          .get();

      debugPrint('[BudgetNotifier] Found ${snapshot.docs.length} budgets in Firebase');

      // Create a map of local budgets by ID
      final localBudgets = Map.fromEntries(
        state.map((b) => MapEntry(b.id, b))
      );

      // Process Firebase budgets
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final firebaseBudget = Budget.fromJson(data);
        
        // If budget exists locally, keep the newer one based on updatedAt
        if (localBudgets.containsKey(firebaseBudget.id)) {
          final localBudget = localBudgets[firebaseBudget.id]!;
          if (data['updatedAt'] != null && 
              (data['updatedAt'] as Timestamp).toDate().isAfter(localBudget.updatedAt)) {
            localBudgets[firebaseBudget.id] = firebaseBudget;
          }
        } else {
          // If it doesn't exist locally, add it
          localBudgets[firebaseBudget.id] = firebaseBudget;
        }
      }

      // Update state with merged budgets
      state = localBudgets.values.toList();

      // Save merged state to local storage
      await _saveToLocal();

      // Now push our changes back to Firebase
      final batch = _firestore.batch();
      final budgetsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets');

      for (var budget in state) {
        final docRef = budgetsRef.doc(budget.id);
        final data = {
          ...budget.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('[BudgetNotifier] Successfully completed Firebase sync');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error during Firebase sync: $e');
    }
  }

  Future<void> syncWithFirebase() => _syncWithFirebase();

  Future<void> addBudget(Budget budget) async {
    try {
      debugPrint('[BudgetNotifier] Adding new budget ${budget.id}');
      state = [...state, budget];
      
      // First save locally
      await _saveToLocal();
      
      // Then try to sync with Firebase in the background
      _syncWithFirebase();
      debugPrint('[BudgetNotifier] Successfully added new budget');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error adding budget: $e');
    }
  }

  Future<void> updateBudget(Budget updatedBudget) async {
    debugPrint('[BudgetNotifier] Updating budget ${updatedBudget.id}...');
    final updatedBudgets = state.map((budget) {
      return budget.id == updatedBudget.id ? updatedBudget : budget;
    }).toList();
    
    state = updatedBudgets;
    
    // First save locally
    await _saveToLocal();
    
    // Then try to sync with Firebase in the background
    _syncWithFirebase();
  }

  Future<void> deleteBudget(String id) async {
    debugPrint('[BudgetNotifier] Deleting budget $id...');
    final updatedBudgets = state.where((budget) => budget.id != id).toList();
    state = updatedBudgets;
    
    // First save locally
    await _saveToLocal();
    
    // Then try to sync with Firebase in the background
    _syncWithFirebase();
  }

  void checkBudgetAlerts() {
    for (final budget in state) {
      if (budget.shouldNotify) {
        // Send notification
        // Update budget to mark as notified
        updateBudget(budget.copyWith(hasNotified: true));
      }
    }
  }

  void updateBudgetSpent(String budgetId, double amount) {
    final updatedBudgets = state.map((budget) {
      if (budget.id == budgetId) {
        return budget.copyWith(
          spent: budget.spent + amount,
        );
      }
      return budget;
    }).toList();
    
    state = updatedBudgets;
    _syncWithFirebase();
  }

  Future<void> loadBudgets() async {
    await _loadFromLocal();
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<Budget>>((ref) {
  return BudgetNotifier(ref);
}); 