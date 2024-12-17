import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  TransactionsNotifier() : super([]);

  void addTransaction(Transaction transaction) {
    state = [...state, transaction];
    print('Transaction added: ${transaction.description} - ${transaction.amount}');
    print('Total transactions: ${state.length}');
  }

  void deleteTransaction(String id) {
    state = state.where((transaction) => transaction.id != id).toList();
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier();
}); 