import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();
  
  CategoriesNotifier() : super([]) {
    _initializeCategories();
  }

  static final List<Category> _defaultCategories = [
    // Income Categories
    Category(
      id: 'salary',
      name: 'Salary',
      description: 'Regular income from employment',
      icon: CupertinoIcons.money_dollar_circle_fill,
      color: CupertinoColors.systemGreen,
      type: CategoryType.income,
      isDefault: true,
    ),
    Category(
      id: 'freelance',
      name: 'Freelance',
      description: 'Income from freelance work and consulting',
      icon: CupertinoIcons.briefcase_fill,
      color: CupertinoColors.systemBlue,
      type: CategoryType.income,
      isDefault: true,
    ),
    Category(
      id: 'investments',
      name: 'Investments',
      description: 'Returns from stocks, bonds, and other investments',
      icon: CupertinoIcons.graph_circle_fill,
      color: CupertinoColors.systemIndigo,
      type: CategoryType.income,
      isDefault: true,
    ),
    Category(
      id: 'rental',
      name: 'Rental',
      description: 'Income from rental properties',
      icon: CupertinoIcons.house_fill,
      color: CupertinoColors.systemOrange,
      type: CategoryType.income,
      isDefault: true,
    ),
    Category(
      id: 'business',
      name: 'Business',
      description: 'Income from business operations',
      icon: CupertinoIcons.building_2_fill,
      color: CupertinoColors.systemPink,
      type: CategoryType.income,
      isDefault: true,
    ),
    Category(
      id: 'other_income',
      name: 'Other Income',
      description: 'Other sources of income',
      icon: CupertinoIcons.money_dollar,
      color: CupertinoColors.systemGrey,
      type: CategoryType.income,
      isDefault: true,
    ),

    // Expense Categories
    Category(
      id: 'food',
      name: 'Food & Dining',
      description: 'Groceries, restaurants, and food delivery',
      icon: CupertinoIcons.cart_fill,
      color: CupertinoColors.systemRed,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'transportation',
      name: 'Transportation',
      description: 'Public transit, fuel, and vehicle maintenance',
      icon: CupertinoIcons.car_fill,
      color: CupertinoColors.systemBlue,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'housing',
      name: 'Housing',
      description: 'Rent, mortgage, and home maintenance',
      icon: CupertinoIcons.house_fill,
      color: CupertinoColors.systemBrown,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'utilities',
      name: 'Utilities',
      description: 'Electricity, water, gas, and internet',
      icon: CupertinoIcons.lightbulb_fill,
      color: CupertinoColors.systemYellow,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'insurance',
      name: 'Insurance',
      description: 'Health, life, and property insurance',
      icon: CupertinoIcons.shield_fill,
      color: CupertinoColors.systemGreen,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'healthcare',
      name: 'Healthcare',
      description: 'Medical expenses and medications',
      icon: CupertinoIcons.heart_fill,
      color: CupertinoColors.systemPink,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'savings',
      name: 'Savings',
      description: 'Personal savings and investments',
      icon: CupertinoIcons.money_dollar,
      color: CupertinoColors.systemIndigo,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      description: 'Movies, games, and hobbies',
      icon: CupertinoIcons.game_controller_solid,
      color: CupertinoColors.systemPurple,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      description: 'Clothing, electronics, and personal items',
      icon: CupertinoIcons.bag_fill,
      color: CupertinoColors.systemOrange,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'education',
      name: 'Education',
      description: 'Tuition, books, and courses',
      icon: CupertinoIcons.book_fill,
      color: CupertinoColors.systemTeal,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'debt',
      name: 'Debt',
      description: 'Credit card payments and loans',
      icon: CupertinoIcons.creditcard_fill,
      color: CupertinoColors.systemRed,
      type: CategoryType.expense,
      isDefault: true,
    ),
    Category(
      id: 'other_expense',
      name: 'Other Expense',
      description: 'Other miscellaneous expenses',
      icon: CupertinoIcons.money_dollar,
      color: CupertinoColors.systemGrey,
      type: CategoryType.expense,
      isDefault: true,
    ),
  ];

  Future<void> _initializeCategories() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // First load all categories from Firebase
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .get();

      if (snapshot.docs.isEmpty) {
        // If no categories exist, sync default categories
        await _syncDefaultCategories();
      } else {
        // Load all categories from Firebase
        final categories = snapshot.docs.map((doc) {
          final data = doc.data();
          return Category.fromJson(data);
        }).toList();

        // Merge with default categories, preferring Firebase data
        final categoryMap = Map.fromEntries(
          categories.map((c) => MapEntry(c.id, c))
        );

        // Add any missing default categories
        for (var defaultCat in _defaultCategories) {
          if (!categoryMap.containsKey(defaultCat.id)) {
            categoryMap[defaultCat.id] = defaultCat;
          }
        }

        state = categoryMap.values.toList();
      }
    } catch (e) {
      debugPrint('Error initializing categories: $e');
    }
  }

  Future<void> _syncDefaultCategories() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      
      final categoriesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories');

      // Add or update default categories
      for (var category in _defaultCategories) {
        final docRef = categoriesRef.doc(category.id);
        final data = {
          ...category.toJson(),
          'isDefault': true,
          'updatedAt': FieldValue.serverTimestamp(),
        };
        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      
      // Update local state with default categories
      state = _defaultCategories;
    } catch (e) {
      debugPrint('Error syncing default categories with Firebase: $e');
    }
  }

  Future<void> _syncWithFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      
      final categoriesRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories');

      // Get existing categories to handle deletions
      final snapshot = await categoriesRef.get();
      final existingIds = snapshot.docs.map((doc) => doc.id).toSet();

      // Add or update current categories
      for (var category in state) {
        final docRef = categoriesRef.doc(category.id);
        final data = {
          ...category.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        batch.set(docRef, data, SetOptions(merge: true));
        existingIds.remove(category.id);
      }

      // Delete categories that no longer exist
      for (var id in existingIds) {
        batch.delete(categoriesRef.doc(id));
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error syncing categories with Firebase: $e');
    }
  }

  Future<void> loadCategories() async {
    debugPrint('[CategoriesNotifier] Loading categories...');
    await _loadFromLocal();
    _syncWithFirebase();
  }

  Future<void> addCategory({
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required CategoryType type,
  }) async {
    final newCategory = Category(
      id: _uuid.v4(),
      name: name,
      description: description,
      icon: icon,
      color: color,
      type: type,
      isDefault: false,
    );

    state = [...state, newCategory];
    await _syncWithFirebase();
    await _saveToLocal();
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required CategoryType type,
  }) async {
    final index = state.indexWhere((category) => category.id == id);
    if (index == -1) return;

    final oldCategory = state[index];
    final updatedCategory = Category(
      id: id,
      name: name,
      description: description,
      icon: icon,
      color: color,
      type: type,
      isDefault: oldCategory.isDefault,
    );

    state = [...state]..setAll(index, [updatedCategory]);
    await _syncWithFirebase();
    await _saveToLocal();
  }

  Future<void> deleteCategory(String id) async {
    final category = getCategoryById(id);
    // Only allow deletion of custom categories
    if (category == null || !category.isCustom) {
      debugPrint('Cannot delete default category: ${category?.name}');
      return;
    }

    state = state.where((category) => category.id != id).toList();
    await _syncWithFirebase();
    await _saveToLocal();
  }

  Future<void> restoreCategoriesFromFirebase() async {
    await _initializeCategories();
  }

  Future<void> restoreFromFirebase() async {
    await _initializeCategories();
  }

  Future<void> _loadFromLocal() async {
    try {
      debugPrint('[CategoriesNotifier] Loading categories from local storage...');
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = prefs.getStringList('categories') ?? [];
      
      final loadedCategories = categoriesJson
          .map((json) => Category.fromJson(jsonDecode(json)))
          .toList();
      
      // Merge with default categories
      final defaultCategories = _defaultCategories;
      final mergedCategories = {...loadedCategories, ...defaultCategories}
          .toList();
      
      state = mergedCategories;
      debugPrint('[CategoriesNotifier] Loaded ${state.length} categories from local storage');
    } catch (e) {
      debugPrint('[CategoriesNotifier] Error loading categories from local: $e');
      // If local load fails, fall back to default categories
      state = _defaultCategories;
    }
  }

  Future<void> _saveToLocal() async {
    try {
      debugPrint('[CategoriesNotifier] Saving categories to local storage...');
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = state
          .map((category) => jsonEncode(category.toJson()))
          .toList();
      
      await prefs.setStringList('categories', categoriesJson);
      debugPrint('[CategoriesNotifier] Saved ${state.length} categories to local storage');
    } catch (e) {
      debugPrint('[CategoriesNotifier] Error saving categories to local: $e');
    }
  }

  Future<void> syncWithFirebase() => _syncWithFirebase();

  // Helper methods to get categories by type
  List<Category> getCategoriesByType(CategoryType type) {
    return state.where((category) => category.type == type).toList();
  }

  // Get a specific category by ID
  Category? getCategoryById(String id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}