import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/utils/currency_converter.dart';

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final Ref ref;
  
  TransactionsNotifier(this.ref) : super([]) {
    _loadTransactions();
    
    // Listen to currency changes
    ref.listen<String>(currencyProvider, (previous, next) {
      if (previous == null) return;
      
      // Only update the currency code, keep original amounts
      final updatedTransactions = state.map((transaction) => 
        transaction.copyWith(currencyCode: next)
      ).toList();
      
      state = updatedTransactions;
      _saveTransactions(updatedTransactions);
    });
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList('transactions') ?? [];
    
    state = transactionsJson
        .map((json) => Transaction.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList();
    
    await prefs.setStringList('transactions', transactionsJson);
  }

  void addTransaction(Transaction transaction) {
    final currentCurrency = ref.read(currencyProvider);
    final updatedTransaction = transaction.copyWith(
      currencyCode: currentCurrency,
    );
    final updatedTransactions = [...state, updatedTransaction];
    
    state = updatedTransactions;
    _saveTransactions(updatedTransactions);
  }

  void deleteTransaction(String id) {
    final updatedTransactions = state.where((transaction) => 
      transaction.id != id
    ).toList();
    
    state = updatedTransactions;
    _saveTransactions(updatedTransactions);
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier(ref);
}); 