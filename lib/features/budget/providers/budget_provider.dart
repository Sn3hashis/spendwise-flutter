import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/budget_model.dart';
import '../../categories/models/category_model.dart';
import 'package:uuid/uuid.dart';

class BudgetNotifier extends StateNotifier<List<Budget>> {
  final Ref ref;
  
  BudgetNotifier(this.ref) : super([]) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetList = prefs.getStringList('budgets') ?? [];
    
    state = budgetList.map<Budget>((budgetString) {
      final map = jsonDecode(budgetString) as Map<String, dynamic>;
      return Budget(
        id: map['id'] ?? const Uuid().v4(),
        name: map['name'] ?? 'Untitled Budget',
        amount: (map['amount'] ?? 0.0).toDouble(),
        spent: (map['spent'] ?? 0.0).toDouble(),
        category: Category.fromJson(jsonDecode(map['category'])),
        startDate: DateTime.parse(map['startDate']),
        endDate: DateTime.parse(map['endDate']),
        alertThreshold: (map['alertThreshold'] ?? 0.8).toDouble(),
        isRecurring: map['isRecurring'] ?? false,
        recurringType: RecurringType.values.firstWhere(
          (type) => type.toString() == map['recurringType'],
          orElse: () => RecurringType.monthly,
        ),
        hasNotified: map['hasNotified'] ?? false,
      );
    }).toList();
  }

  Future<void> _saveBudgets(List<Budget> budgets) async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = budgets.map((budget) => jsonEncode({
      'id': budget.id,
      'amount': budget.amount,
      'category': budget.category.toJson(),
      'startDate': budget.startDate.toIso8601String(),
      'endDate': budget.endDate.toIso8601String(),
      'spent': budget.spent,
      'isRecurring': budget.isRecurring,
      'recurringType': budget.recurringType.toString(),
    })).toList();
    
    await prefs.setStringList('budgets', budgetsJson);
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