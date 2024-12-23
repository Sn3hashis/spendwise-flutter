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
  final Set<String> _deletedIds = {};  // Add this field
  
  CategoriesNotifier() : super([]) {
    _initializeCategories();
  }

  static final List<Category> _defaultCategories = _getDefaultCategories();

  static List<Category> _getDefaultCategories() {
    return [
      // Income Categories
      Category(
        id: 'salary',
        name: 'Salary',
        description: 'Regular employment income',
        icon: CupertinoIcons.money_dollar_circle_fill,
        color: const Color(0xFF00C853),
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
        id: 'groceries',
        name: 'Groceries',
        description: 'Food and household items',
        icon: CupertinoIcons.cart_fill,
        color: const Color(0xFFE91E63),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'food',
        name: 'Food & Dining',
        description: 'Restaurants and dining out',
        icon: CupertinoIcons.hand_draw_fill,  // Changed from cup_and_straw_fill
        color: const Color(0xFFFF5722),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'transportation',
        name: 'Transportation',
        description: 'Public transport and rides',
        icon: CupertinoIcons.bus,
        color: const Color(0xFF2196F3),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'fuel',
        name: 'Fuel',
        description: 'Vehicle fuel expenses',
        icon: CupertinoIcons.flame_fill,
        color: const Color(0xFFFFA000),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'vehicle_maintenance',
        name: 'Vehicle Maintenance',
        description: 'Car repairs and servicing',
        icon: CupertinoIcons.car_detailed,
        color: const Color(0xFF607D8B),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'housing',
        name: 'Housing',
        description: 'Rent and home expenses',
        icon: CupertinoIcons.house_fill,
        color: const Color(0xFF9C27B0),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'utilities',
        name: 'Utilities',
        description: 'Bills and services',
        icon: CupertinoIcons.lightbulb_fill,
        color: const Color(0xFFFF9800),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'healthcare',
        name: 'Healthcare',
        description: 'Medical expenses',
        icon: CupertinoIcons.heart_fill,
        color: const Color(0xFFF44336),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'entertainment',
        name: 'Entertainment',
        description: 'Movies, games, and fun',
        icon: CupertinoIcons.gamecontroller_fill,
        color: const Color(0xFF673AB7),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'shopping',
        name: 'Shopping',
        description: 'Clothing and retail',
        icon: CupertinoIcons.bag_fill,
        color: const Color(0xFF3F51B5),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'personal_care',
        name: 'Personal Care',
        description: 'Grooming and self-care',
        icon: CupertinoIcons.person_crop_circle_fill,
        color: const Color(0xFF795548),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'fitness',
        name: 'Fitness',
        description: 'Gym and sports',
        icon: CupertinoIcons.sportscourt_fill,
        color: const Color(0xFF4CAF50),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'education',
        name: 'Education',
        description: 'Learning and courses',
        icon: CupertinoIcons.book_fill,
        color: const Color(0xFF009688),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'gifts',
        name: 'Gifts',
        description: 'Presents and donations',
        icon: CupertinoIcons.gift_fill,
        color: const Color(0xFFE91E63),
        type: CategoryType.expense,
        isDefault: true,
      ),
      Category(
        id: 'pets',
        name: 'Pets',
        description: 'Pet care and supplies',
        icon: CupertinoIcons.paw,
        color: const Color(0xFF8D6E63),
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
        id: 'savings',
        name: 'Savings',
        description: 'Personal savings and investments',
        icon: CupertinoIcons.money_dollar,
        color: CupertinoColors.systemIndigo,
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
  }

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

  Future<void> addCategory(Category category) async {
    try {
      debugPrint('[CategoriesNotifier] Adding new category ${category.name}');
      
      // Check if category with same name exists
      final existingCategory = state.where((c) => 
        c.name.toLowerCase() == category.name.toLowerCase() &&
        c.type == category.type
      ).firstOrNull;
      
      if (existingCategory != null) {
        throw Exception('A category with this name already exists');
      }

      // Use category name as document ID (sanitized for Firestore)
      final docId = category.name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(docId);

      // Create category with the sanitized name as ID
      final newCategory = category.copyWith(id: docId);
      
      await docRef.set(newCategory.toJson());
      
      state = [...state, newCategory];
      
      // Save to local storage
      await _saveCategoriesToLocal(state);
      
      debugPrint('[CategoriesNotifier] Successfully added category ${category.name}');
    } catch (e) {
      debugPrint('[CategoriesNotifier] Error adding category: $e');
      rethrow;
    }
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
    try {
      debugPrint('[CategoriesNotifier] Attempting to delete category $id...');
      
      // Check if category is default
      final category = state.firstWhere((c) => c.id == id);
      if (category.isDefault) {
        debugPrint('[CategoriesNotifier] Cannot delete default category $id');
        throw Exception('Cannot delete default category');
      }

      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .doc(id)
            .delete();
      }

      _deletedIds.add(id);
      await _saveDeletedIds();

      final updatedCategories = state.where((c) => c.id != id).toList();
      state = updatedCategories;
      await _saveToLocalStorage(updatedCategories);
      
      debugPrint('[CategoriesNotifier] Successfully deleted category');
    } catch (e) {
      debugPrint('[CategoriesNotifier] Error deleting category: $e');
      rethrow;
    }
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

  Future<void> syncWithFirebase() async {
    try {
      debugPrint('[CategoriesNotifier] Starting Firebase sync...');
      
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .get();

      final categories = snapshot.docs
          .map((doc) => Category.fromJson(doc.data()))
          .toList();

      // Merge with default categories
      final allCategories = [..._defaultCategories];
      
      // Add custom categories that don't exist in defaults
      for (final category in categories) {
        if (!allCategories.any((c) => c.id == category.id)) {
          allCategories.add(category);
        }
      }

      state = allCategories;
      await _saveCategoriesToLocal(state);
      
      debugPrint('[CategoriesNotifier] Successfully completed Firebase sync');
    } catch (e) {
      debugPrint('[CategoriesNotifier] Error during Firebase sync: $e');
      rethrow;
    }
  }

  Future<void> _saveCategoriesToLocal(List<Category> categories) async {
    try {
      debugPrint('[CategoriesNotifier] Saving categories to local storage...');
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = categories
          .map((category) => jsonEncode(category.toJson()))
          .toList();
      
      await prefs.setStringList('categories', categoriesJson);
      debugPrint('[CategoriesNotifier] Saved ${categories.length} categories to local storage');
    } catch (e) {
      debugPrint('[CategoriesNotifier] Error saving categories to local: $e');
    }
  }

  Future<void> _loadDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = prefs.getStringList('deleted_categories') ?? [];
    _deletedIds.addAll(deletedIds);
  }

  Future<void> _saveDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('deleted_categories', _deletedIds.toList());
  }

  Future<void> _saveToLocalStorage(List<Category> categories) async {
    try {
      debugPrint('[CategoriesNotifier] Saving categories to local storage...');
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = categories
          .map((category) => jsonEncode(category.toJson()))
          .toList();
      
      await prefs.setStringList('categories', categoriesJson);
      debugPrint('[CategoriesNotifier] Saved ${categories.length} categories to local storage');
    } catch (e) {
      debugPrint('[CategoriesNotifier] Error saving to local storage: $e');
    }
  }

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