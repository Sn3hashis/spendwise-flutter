import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_filter.dart';

class TransactionFilterNotifier extends StateNotifier<TransactionFilter> {
  TransactionFilterNotifier() : super(const TransactionFilter());

  void updateFilter(TransactionFilter filter) {
    state = filter;
  }

  void resetFilter() {
    state = const TransactionFilter();
  }
}

final transactionFilterProvider = StateNotifierProvider<TransactionFilterNotifier, TransactionFilter>((ref) {
  return TransactionFilterNotifier();
}); 