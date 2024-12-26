import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendwise/features/categories/providers/categories_provider.dart';
import 'package:spendwise/features/categories/models/category_model.dart' as category_model;
import 'dart:convert';
import '../models/budget_model.dart';
import '../../categories/models/category_model.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<Budget>>((ref) {
  return BudgetNotifier(ref);
});

class BudgetNotifier extends StateNotifier<List<Budget>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref;
  final Set<String> _deletedIds = {};

  BudgetNotifier(this.ref) : super([]) {
    _initializeBudgets();
  }

  Future<void> loadBudgets() async {
    debugPrint('[BudgetNotifier] Loading budgets...');
    await _loadFromLocal();
    await syncWithFirebase();
  }

  Future<void> _initializeBudgets() async {
    try {
      // Wait for categories to be initialized first
      await ref.read(categoriesProvider.notifier).loadCategories();
      await loadBudgets();
    } catch (e) {
      debugPrint('[BudgetNotifier] Error initializing budgets: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      debugPrint('[BudgetNotifier] Loading budgets from local storage...');
      final prefs = await SharedPreferences.getInstance();
      final budgetsJson = prefs.getStringList('budgets') ?? [];
      
      final List<Budget> loadedBudgets = [];
      final categories = ref.read(categoriesProvider);

      for (final json in budgetsJson) {
        try {
          final budgetData = jsonDecode(json);
          final categoryId = budgetData['categoryId'];
          
          // Find category including defaults
          final category = categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => throw Exception('Category not found'),
          );
          
          // Update category in budget data
          budgetData['category'] = category.toJson();
          
          loadedBudgets.add(Budget.fromJson(budgetData));
        } catch (e) {
          debugPrint('[BudgetNotifier] Error loading budget: $e');
          // Continue loading other budgets
          continue;
        }
      }
      
      state = loadedBudgets;
      debugPrint('[BudgetNotifier] Loaded ${state.length} budgets');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error loading budgets: $e');
      state = [];
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

  Future<void> _loadDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = prefs.getStringList('deleted_budgets') ?? [];
    _deletedIds.addAll(deletedIds);
  }

  Future<void> _saveDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('deleted_budgets', _deletedIds.toList());
  }

  Future<void> syncWithFirebase() async {
    try {
      debugPrint('[BudgetNotifier] Starting Firebase sync...');
      final user = _auth.currentUser;
      if (user == null) return;

      await _loadDeletedIds();

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .get();

      debugPrint('[BudgetNotifier] Found ${snapshot.docs.length} budgets in Firebase');

      final budgets = <Budget>[];
      
      for (final doc in snapshot.docs) {
        if (_deletedIds.contains(doc.id)) {
          continue;
        }
        
        try {
          final data = doc.data();
          data['id'] = doc.id;
          
          final categoryId = data['categoryId'] as String?;
          if (categoryId == null) {
            debugPrint('[BudgetNotifier] Skipping budget ${doc.id}: missing categoryId');
            continue;
          }

          final categories = ref.read(categoriesProvider);
          final categoriesDebug = categories.map((c) => "${c.id}:${c.name}").join(", ");
          debugPrint("[BudgetNotifier] Available categories: $categoriesDebug");

          category_model.Category? category;
          try {
            category = categories.firstWhere((cat) => cat.id == categoryId);
          } catch (e) {
            try {
              category = categories.firstWhere(
                (cat) => cat.name.toLowerCase() == categoryId.toLowerCase()
              );
              debugPrint("[BudgetNotifier] Found category by name for budget ${doc.id}");
            } catch (e) {
              debugPrint("[BudgetNotifier] Category not found for budget ${doc.id}");
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
          debugPrint("[BudgetNotifier] Error processing budget ${doc.id}: $e");
          continue;
        }
      }

      state = budgets;
      await _saveToLocalStorage(budgets);
      debugPrint('[BudgetNotifier] Sync complete');
    } catch (e) {
      debugPrint('[BudgetNotifier] Sync error: $e');
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

  Future<void> deleteBudget(String budgetId) async {
    try {
      debugPrint('[BudgetNotifier] Deleting budget $budgetId');
      final user = _auth.currentUser;
      if (user == null) return;

      // Delete from Firebase
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .doc(budgetId)
          .delete();

      // Update local state
      final updatedBudgets = state.where((budget) => budget.id != budgetId).toList();
      state = updatedBudgets;
      
      // Update local storage
      await _saveToLocalStorage(updatedBudgets);
      
      // Add to deleted IDs
      _deletedIds.add(budgetId);
      await _saveDeletedIds();
      
      debugPrint('[BudgetNotifier] Successfully deleted budget');
    } catch (e) {
      debugPrint('[BudgetNotifier] Error deleting budget: $e');
      throw Exception('Failed to delete budget: $e');
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