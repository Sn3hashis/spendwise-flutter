import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../budget/providers/budget_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) => SyncService(ref));

class SyncService {
  final Ref ref;

  SyncService(this.ref);

  Future<void> syncAll() async {
    debugPrint('[SyncService] Starting full sync...');
    try {
      await Future.wait([
        ref.read(categoriesProvider.notifier).syncWithFirebase(),
        ref.read(transactionsProvider.notifier).syncWithFirebase(),
        ref.read(budgetProvider.notifier).syncWithFirebase(),
      ]);
      debugPrint('[SyncService] Full sync completed successfully');
    } catch (e) {
      debugPrint('[SyncService] Error during full sync: $e');
      rethrow;
    }
  }
}
