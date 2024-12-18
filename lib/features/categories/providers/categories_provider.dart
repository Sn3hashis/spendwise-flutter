import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Category>>((ref) {
  return CategoriesNotifier();
});

class CategoriesNotifier extends StateNotifier<List<Category>> {
  CategoriesNotifier() : super([
    // Income Categories
    Category(
      id: 'salary',
      name: 'Salary',
      description: 'Regular income from employment',
      icon: CupertinoIcons.money_dollar_circle_fill,
      color: CupertinoColors.systemGreen,
      type: CategoryType.income,
    ),
    Category(
      id: 'freelance',
      name: 'Freelance',
      description: 'Income from freelance work and consulting',
      icon: CupertinoIcons.briefcase_fill,
      color: CupertinoColors.systemBlue,
      type: CategoryType.income,
    ),
    Category(
      id: 'investments',
      name: 'Investments',
      description: 'Returns from stocks, bonds, and other investments',
      icon: CupertinoIcons.graph_circle_fill,
      color: CupertinoColors.systemIndigo,
      type: CategoryType.income,
    ),
    Category(
      id: 'rental',
      name: 'Rental',
      description: 'Income from property rentals and leasing',
      icon: CupertinoIcons.house_fill,
      color: CupertinoColors.systemOrange,
      type: CategoryType.income,
    ),
    Category(
      id: 'business',
      name: 'Business',
      description: 'Income from business operations and sales',
      icon: CupertinoIcons.building_2_fill,
      color: CupertinoColors.systemPurple,
      type: CategoryType.income,
    ),
    Category(
      id: 'dividends',
      name: 'Dividends',
      description: 'Dividend payments from stocks and investments',
      icon: CupertinoIcons.chart_bar_fill,
      color: CupertinoColors.systemTeal,
      type: CategoryType.income,
    ),
    Category(
      id: 'bonus',
      name: 'Bonus',
      description: 'Additional income from bonuses and rewards',
      icon: CupertinoIcons.gift_fill,
      color: CupertinoColors.systemPink,
      type: CategoryType.income,
    ),
    Category(
      id: 'interest',
      name: 'Interest',
      description: 'Interest earned from savings and deposits',
      icon: CupertinoIcons.percent,
      color: CupertinoColors.systemYellow,
      type: CategoryType.income,
    ),

    // Expense Categories
    Category(
      id: 'groceries',
      name: 'Groceries',
      description: 'Food and household supplies',
      icon: CupertinoIcons.cart_fill,
      color: CupertinoColors.systemRed,
      type: CategoryType.expense,
    ),
    Category(
      id: 'dining',
      name: 'Dining',
      description: 'Restaurants, cafes, and eating out',
      icon: CupertinoIcons.bed_double_fill,
      color: CupertinoColors.systemOrange,
      type: CategoryType.expense,
    ),
    Category(
      id: 'transport',
      name: 'Transport',
      description: 'Public transport, fuel, and vehicle maintenance',
      icon: CupertinoIcons.car_fill,
      color: CupertinoColors.systemYellow,
      type: CategoryType.expense,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      description: 'Clothing, accessories, and personal items',
      icon: CupertinoIcons.shopping_cart,
      color: CupertinoColors.systemPink,
      type: CategoryType.expense,
    ),
    Category(
      id: 'utilities',
      name: 'Utilities',
      description: 'Electricity, water, gas, and internet bills',
      icon: CupertinoIcons.lightbulb_fill,
      color: CupertinoColors.systemBlue,
      type: CategoryType.expense,
    ),
    Category(
      id: 'housing',
      name: 'Housing',
      description: 'Rent, mortgage, and home maintenance',
      icon: CupertinoIcons.house_fill,
      color: CupertinoColors.systemGreen,
      type: CategoryType.expense,
    ),
    Category(
      id: 'healthcare',
      name: 'Healthcare',
      description: 'Medical expenses, insurance, and pharmacy',
      icon: CupertinoIcons.heart_fill,
      color: CupertinoColors.systemRed,
      type: CategoryType.expense,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      description: 'Movies, games, streaming services, and hobbies',
      icon: CupertinoIcons.game_controller_solid,
      color: CupertinoColors.systemPurple,
      type: CategoryType.expense,
    ),
    Category(
      id: 'education',
      name: 'Education',
      description: 'Tuition fees, books and supplies, online courses or certifications',
      icon: CupertinoIcons.book_circle_fill,
      color: CupertinoColors.systemIndigo,
      type: CategoryType.expense,
    ),
    Category(
      id: 'fitness',
      name: 'Fitness',
      description: 'Gym memberships and sports activities',
      icon: CupertinoIcons.sportscourt_fill,
      color: CupertinoColors.systemTeal,
      type: CategoryType.expense,
    ),
    Category(
      id: 'personal_care',
      name: 'Personal Care',
      description: 'Haircuts and styling, skincare and cosmetics, toiletries',
      icon: CupertinoIcons.person_crop_circle_fill,
      color: CupertinoColors.systemPurple,
      type: CategoryType.expense,
    ),
    Category(
      id: 'gifts',
      name: 'Gifts',
      description: 'Presents and donations',
      icon: CupertinoIcons.gift_fill,
      color: CupertinoColors.systemRed,
      type: CategoryType.expense,
    ),
    Category(
      id: 'insurance',
      name: 'Insurance',
      description: 'Life, home, and vehicle insurance',
      icon: CupertinoIcons.shield_fill,
      color: CupertinoColors.systemBlue,
      type: CategoryType.expense,
    ),
    Category(
      id: 'taxes',
      name: 'Taxes',
      description: 'Income tax and other government payments',
      icon: CupertinoIcons.doc_text_fill,
      color: CupertinoColors.systemGrey,
      type: CategoryType.expense,
    ),
    Category(
      id: 'travel',
      name: 'Travel',
      description: 'Vacations, hotels, and travel expenses',
      icon: CupertinoIcons.airplane,
      color: CupertinoColors.systemTeal,
      type: CategoryType.expense,
    ),
    Category(
      id: 'debt_repayments',
      name: 'Debt Repayments',
      description: 'Credit card payments, loan repayments, interest on loans or credit card',
      icon: CupertinoIcons.creditcard_fill,
      color: CupertinoColors.systemRed,
      type: CategoryType.expense,
    ),
    Category(
      id: 'clothing',
      name: 'Clothing',
      description: 'Clothing and accessories, shoes, laundry and dry cleaning',
      icon: CupertinoIcons.tag_fill,
      color: CupertinoColors.systemPink,
      type: CategoryType.expense,
    ),
    Category(
      id: 'miscellaneous',
      name: 'Miscellaneous',
      description: 'Other uncategorized expenses',
      icon: CupertinoIcons.ellipsis_circle_fill,
      color: CupertinoColors.systemGrey,
      type: CategoryType.expense,
    ),
  ]);

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

  void addCategory(Category category) {
    state = [...state, category];
  }

  void updateCategory(Category category) {
    state = [
      for (final cat in state)
        if (cat.id == category.id) category else cat
    ];
  }

  void deleteCategory(String id) {
    state = state.where((cat) => cat.id != id).toList();
  }
} 