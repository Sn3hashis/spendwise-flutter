import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';
import '../../budget/providers/budget_provider.dart';
import 'package:uuid/uuid.dart';

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final Ref ref;
  
  TransactionNotifier(this.ref) : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionList = prefs.getStringList('transactions') ?? [];
    
    state = transactionList.map<Transaction>((transactionString) {
      final map = jsonDecode(transactionString);
      return Transaction.fromJson(map);
    }).toList();
  }

  Future<void> _saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions.map((transaction) => 
      jsonEncode(transaction.toJson())
    ).toList();
    
    await prefs.setStringList('transactions', transactionsJson);
  }

  Future<void> addTransaction(Transaction transaction) async {
    final updatedTransactions = [...state, transaction];
    state = updatedTransactions;
    await _saveTransactions(updatedTransactions);

    // Update budget spent amount if transaction is linked to a budget
    if (transaction.budgetId != null && transaction.type == TransactionType.expense) {
      final budgetNotifier = ref.read(budgetProvider.notifier);
      budgetNotifier.updateBudgetSpent(
        transaction.budgetId!,
        transaction.amount,
      );
    }
  }

  List<Transaction> getTransactionsForBudget(String budgetId) {
    return state.where((transaction) => 
      transaction.budgetId == budgetId
    ).toList();
  }

  double getTotalSpentForBudget(String budgetId) {
    return state
      .where((transaction) => 
        transaction.budgetId == budgetId && 
        transaction.type == TransactionType.expense
      )
      .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier(ref);
}); 