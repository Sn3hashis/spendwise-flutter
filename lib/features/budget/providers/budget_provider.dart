import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/budget_model.dart';
import '../../categories/models/category_model.dart';
import '../../categories/providers/category_provider.dart';
import 'package:uuid/uuid.dart';

class BudgetNotifier extends StateNotifier<List<Budget>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref;
  
  BudgetNotifier(this.ref) : super([]) {
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = prefs.getStringList('budgets') ?? [];
    
    state = budgetsJson
        .map((json) => Budget.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = budgets
        .map((budget) => jsonEncode(budget.toJson()))
        .toList();
    
    await prefs.setStringList('budgets', budgetsJson);
    
    // Sync with Firebase in the background
    _syncWithFirebase(budgets);
  }

  Future<void> _syncWithFirebase(List<Budget> budgets) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      final userDoc = _firestore.collection('users').doc(user.uid);
      final budgetsRef = userDoc.collection('budgets');

      // Get existing budgets to handle deletions
      final existingDocs = await budgetsRef.get();
      final existingIds = existingDocs.docs.map((doc) => doc.id).toSet();
      final newIds = budgets.map((budget) => budget.id).toSet();

      // Handle deletions
      for (final docId in existingIds.difference(newIds)) {
        batch.delete(budgetsRef.doc(docId));
      }

      // Handle updates and additions
      for (final budget in budgets) {
        final docRef = budgetsRef.doc(budget.id);
        batch.set(docRef, {
          ...budget.toJson(),
          'categoryId': budget.category.id, // Store category reference
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error syncing budgets with Firebase: $e');
    }
  }

  Future<void> restoreBudgetsFromFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final categories = ref.read(categoryProvider);
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .get();

      final budgets = snapshot.docs.map((doc) {
        final data = doc.data();
        final categoryId = data['categoryId'] as String;
        final category = categories.firstWhere(
          (cat) => cat.id == categoryId,
          orElse: () => throw 'Category not found: $categoryId',
        );
        
        return Budget.fromJson({
          ...data,
          'id': doc.id,
          'category': category.toJson(),
        });
      }).toList();

      state = budgets;
      await _saveBudgets(budgets);
    } catch (e) {
      debugPrint('Error restoring budgets from Firebase: $e');
    }
  }

  void addBudget(Budget budget) {
    final updatedBudgets = [...state, budget];
    state = updatedBudgets;
    _saveBudgets(updatedBudgets);
  }

  void updateBudget(Budget updatedBudget) {
    final updatedBudgets = state.map((budget) => 
      budget.id == updatedBudget.id ? updatedBudget : budget
    ).toList();
    
    state = updatedBudgets;
    _saveBudgets(updatedBudgets);
  }

  void deleteBudget(String id) {
    final updatedBudgets = state.where((budget) => budget.id != id).toList();
    state = updatedBudgets;
    _saveBudgets(updatedBudgets);
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
    _saveBudgets(updatedBudgets);
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<Budget>>((ref) {
  return BudgetNotifier(ref);
}); 