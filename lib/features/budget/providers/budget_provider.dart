import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendwise/features/categories/providers/categories_provider.dart';
import 'package:spendwise/features/categories/models/category_model.dart' as category_model;
import 'dart:convert';
import '../models/budget_model.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<Budget>>((ref) {
  return BudgetNotifier(ref);
});

class BudgetNotifier extends StateNotifier<List<Budget>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref;

  BudgetNotifier(this.ref) : super([]) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      debugPrint('[BudgetNotifier] Loading budgets...');
      
      // First try to load from local storage
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getStringList('budgets') ?? [];
      
      final localBudgets = budgetsJson
          .map((json) => Budget.fromJson(jsonDecode(json)))
          .toList();
      
      state = localBudgets;
      debugPrint('[BudgetNotifier] Loaded ${localBudgets.length} budgets from local storage');
      
      // Then sync with Firebase
      await syncWithFirebase();
    } catch (e) {
      debugPrint('[BudgetNotifier] Error loading budgets: $e');
    }
  }

  Future<void> _saveToLocalStorage(List<Budget> budgets) async {
    try {
      debugPrint('[BudgetNotifier] Saving budgets to local storage...');
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = budgets
          .map((budget) => jsonEncode(budget.toJson()))
          .toList();
      
      await prefs.setStringList('budgets', budgetsJson);
      debugPrint('[BudgetNotifier] Saved ${budgets.length} budgets to local storage');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error saving to local storage: $e');
    }
  }

  Future<void> syncWithFirebase() async {
    try {
      debugPrint('[BudgetNotifier] Starting Firebase sync...');
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .get();

      debugPrint('[BudgetNotifier] Found ${snapshot.docs.length} budgets in Firebase');

      final budgets = <Budget>[];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          
          final categoryId = data['categoryId'] as String?;
          if (categoryId == null) {
            debugPrint('[BudgetNotifier] Skipping budget ${doc.id}: missing categoryId');
            continue;
          }

          final categories = ref.read(categoriesProvider);
          debugPrint('[BudgetNotifier] Looking for category with ID: $categoryId');
          debugPrint('[BudgetNotifier] Available categories: ${categories.map((c) => '${c.id}:${c.name}').join(', ')}');

          category_model.Category? category;
          try {
            // Try to find by ID first
            category = categories.firstWhere((cat) => cat.id == categoryId);
          } catch (e) {
            // If not found by ID, try to find by name (for backward compatibility)
            try {
              category = categories.firstWhere((cat) => cat.name.toLowerCase() == categoryId.toLowerCase());
              debugPrint('[BudgetNotifier] Found category by name instead of ID for budget ${doc.id}');
            } catch (e) {
              debugPrint('[BudgetNotifier] Skipping budget ${doc.id}: category not found for ID: $categoryId');
              continue;
            }
          }

          final budgetData = {
            ...data,
            'category': category.toJson(),
            'name': category.name,
          };

          final budget = Budget.fromJson(budgetData);
          budgets.add(budget);
        } catch (e) {
          debugPrint('[BudgetNotifier] Error converting budget ${doc.id}: $e');
          continue;
        }
      }

      state = budgets;
      await _saveToLocalStorage(budgets);
      debugPrint('[BudgetNotifier] Successfully completed Firebase sync');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error during Firebase sync: $e');
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      debugPrint('[BudgetNotifier] Adding new budget ${budget.id}');
      final user = _auth.currentUser;
      if (user == null) return;

      final budgetData = {
        ...budget.toJson(),
        'categoryId': budget.category.id,
      };
      budgetData.remove('category');
      budgetData.remove('name');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .doc(budget.id)
          .set(budgetData);

      state = [...state, budget];
      await _saveToLocalStorage(state);
      debugPrint('[BudgetNotifier] Successfully added new budget');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error adding budget: $e');
    }
  }

  Future<void> updateBudget(Budget updatedBudget) async {
    try {
      debugPrint('[BudgetNotifier] Updating budget ${updatedBudget.id}');
      final user = _auth.currentUser;
      if (user == null) return;

      final budgetData = {
        ...updatedBudget.toJson(),
        'categoryId': updatedBudget.category.id,
      };
      budgetData.remove('category');
      budgetData.remove('name');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .doc(updatedBudget.id)
          .update(budgetData);

      final updatedBudgets = state.map((budget) {
        return budget.id == updatedBudget.id ? updatedBudget : budget;
      }).toList();

      state = updatedBudgets;
      await _saveToLocalStorage(updatedBudgets);
      debugPrint('[BudgetNotifier] Successfully updated budget');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error updating budget: $e');
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      debugPrint('[BudgetNotifier] Deleting budget $id');
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .doc(id)
          .delete();

      final updatedBudgets = state.where((budget) => budget.id != id).toList();
      state = updatedBudgets;
      await _saveToLocalStorage(updatedBudgets);
      debugPrint('[BudgetNotifier] Successfully deleted budget');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error deleting budget: $e');
    }
  }

  void updateBudgetSpent(String budgetId, double amount) async {
    try {
      final updatedBudgets = state.map((budget) {
        if (budget.id == budgetId) {
          return budget.copyWith(spent: budget.spent + amount);
        }
        return budget;
      }).toList();

      state = updatedBudgets;
      await _saveToLocalStorage(updatedBudgets);
      
      // Update in Firebase
      final user = _auth.currentUser;
      if (user != null) {
        final budget = updatedBudgets.firstWhere((b) => b.id == budgetId);
        await updateBudget(budget);
      }
    } catch (e) {
      debugPrint('[BudgetNotifier] Error updating budget spent: $e');
    }
  }
}