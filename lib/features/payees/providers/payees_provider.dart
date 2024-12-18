import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payee_model.dart';

class PayeesNotifier extends StateNotifier<List<Payee>> {
  PayeesNotifier() : super([]);

  void addPayee(Payee payee) {
    state = [...state, payee];
  }

  void updatePayee(Payee payee) {
    state = state.map((p) => p.id == payee.id ? payee : p).toList();
  }

  void deletePayee(String id) {
    state = state.where((p) => p.id != id).toList();
  }
}

final payeesProvider = StateNotifierProvider<PayeesNotifier, List<Payee>>((ref) {
  return PayeesNotifier();
}); 