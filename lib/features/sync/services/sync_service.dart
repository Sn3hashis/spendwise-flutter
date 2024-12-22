import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../categories/providers/categories_provider.dart';
import '../../budget/providers/budget_provider.dart';
import '../../settings/providers/settings_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) => SyncService(ref));

class SyncService {
  final Ref ref;

  SyncService(this.ref);

  Future<void> syncAll() async {
    debugPrint('[SyncService] Starting full sync...');
    try {
      // First sync settings and categories
      await Future.wait([
        ref.read(settingsProvider.notifier).syncWithFirebase(),
        ref.read(categoriesProvider.notifier).syncWithFirebase(),
      ]);
      
      // Then sync transactions and budgets
      await Future.wait([
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
