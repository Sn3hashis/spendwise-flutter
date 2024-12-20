import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart' show Icons, Colors;
import 'package:flutter/cupertino.dart' show CupertinoIcons, CupertinoColors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/category_model.dart';

class CategoryNotifier extends StateNotifier<List<Category>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref;
  
  CategoryNotifier(this.ref) : super([]) {
    _loadCategories();
  }

  final List<Category> defaultCategories = [
    Category(
      id: 'food',
      name: 'Food & Dining',
      description: 'Food and dining expenses',
      icon: CupertinoIcons.cart_fill,
      color: CupertinoColors.systemOrange,
      type: CategoryType.expense,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      description: 'Shopping expenses',
      icon: CupertinoIcons.bag_fill,
      color: CupertinoColors.systemBlue,
      type: CategoryType.expense,
    ),
    Category(
      id: 'transportation',
      name: 'Transportation',
      description: 'Transportation expenses',
      icon: CupertinoIcons.car_fill,
      color: CupertinoColors.systemGreen,
      type: CategoryType.expense,
    ),
    Category(
      id: 'bills',
      name: 'Bills & Utilities',
      description: 'Bills and utility payments',
      icon: CupertinoIcons.doc_text_fill,
      color: CupertinoColors.systemRed,
      type: CategoryType.expense,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      description: 'Entertainment expenses',
      icon: CupertinoIcons.game_controller_solid,
      color: CupertinoColors.systemPurple,
      type: CategoryType.expense,
    ),
    Category(
      id: 'health',
      name: 'Health',
      description: 'Health and medical expenses',
      icon: CupertinoIcons.heart_fill,
      color: CupertinoColors.systemPink,
      type: CategoryType.expense,
    ),
    Category(
      id: 'salary',
      name: 'Salary',
      description: 'Regular income from employment',
      icon: CupertinoIcons.money_dollar_circle_fill,
      color: CupertinoColors.systemTeal,
      type: CategoryType.income,
    ),
    Category(
      id: 'investment',
      name: 'Investment',
      description: 'Investment returns',
      icon: CupertinoIcons.graph_circle_fill,
      color: CupertinoColors.systemIndigo,
      type: CategoryType.income,
    ),
    Category(
      id: 'transfer',
      name: 'Transfer',
      description: 'Money transfers',
      icon: CupertinoIcons.arrow_right_arrow_left_circle_fill,
      color: CupertinoColors.systemGrey,
      type: CategoryType.transfer,
    ),
    Category(
      id: 'others',
      name: 'Others',
      description: 'Other expenses',
      icon: CupertinoIcons.ellipsis_circle_fill,
      color: CupertinoColors.systemGrey2,
      type: CategoryType.expense,
    ),
  ];

  Future<void> _loadCategories() async {
    try {
      // First load default categories
      state = [...defaultCategories];
      
      // Then try to load user's custom categories from Firebase
      await _restoreCategoriesFromFirebase();
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _saveUserCategories(List<Category> categories) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      final userDoc = _firestore.collection('users').doc(user.uid);
      final categoriesRef = userDoc.collection('categories');

      // Get existing categories to handle deletions
      final existingDocs = await categoriesRef.get();
      final existingIds = existingDocs.docs.map((doc) => doc.id).toSet();
      final newIds = categories
          .where((cat) => cat.isCustom)
          .map((cat) => cat.id)
          .toSet();

      // Handle deletions
      for (final docId in existingIds.difference(newIds)) {
        batch.delete(categoriesRef.doc(docId));
      }

      // Handle updates and additions
      for (final category in categories.where((cat) => cat.isCustom)) {
        final docRef = categoriesRef.doc(category.id);
        batch.set(docRef, {
          ...category.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error saving categories to Firebase: $e');
      rethrow;
    }
  }

  Future<void> _restoreCategoriesFromFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final categoriesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .get();

      final customCategories = categoriesSnapshot.docs
          .map((doc) => Category.fromJson({
                ...doc.data(),
                'id': doc.id,
                'isCustom': true,
              }))
          .toList();

      // Combine default and custom categories, ensuring no duplicates
      final allCategories = [
        ...defaultCategories,
        ...customCategories.where(
          (custom) => !defaultCategories.any((def) => def.id == custom.id)
        )
      ];

      state = allCategories;
    } catch (e) {
      debugPrint('Error restoring categories from Firebase: $e');
      // Don't throw - fall back to default categories
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      // Ensure the category is marked as custom
      final customCategory = category.copyWith(isCustom: true);
      final updatedCategories = [...state, customCategory];
      state = updatedCategories;
      await _saveUserCategories(updatedCategories);
    } catch (e) {
      debugPrint('Error adding category: $e');
      // Revert state on error
      await _loadCategories();
      rethrow;
    }
  }

  Future<void> updateCategory(Category updatedCategory) async {
    try {
      // Only allow updating custom categories
      if (!updatedCategory.isCustom || 
          defaultCategories.any((c) => c.id == updatedCategory.id)) {
        return;
      }

      final updatedCategories = state.map((category) {
        if (category.id == updatedCategory.id) {
          return updatedCategory;
        }
        return category;
      }).toList();
      
      state = updatedCategories;
      await _saveUserCategories(updatedCategories);
    } catch (e) {
      debugPrint('Error updating category: $e');
      // Revert state on error
      await _loadCategories();
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      // Only allow deleting custom categories
      if (defaultCategories.any((c) => c.id == id)) {
        return;
      }

      final updatedCategories = state.where((category) => category.id != id).toList();
      state = updatedCategories;
      await _saveUserCategories(updatedCategories);
    } catch (e) {
      debugPrint('Error deleting category: $e');
      // Revert state on error
      await _loadCategories();
      rethrow;
    }
  }

  // Add this public method for external calls
  Future<void> restoreUserCategoriesFromFirebase() async {
    await _loadCategories();
  }
}

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier(ref);
}); 