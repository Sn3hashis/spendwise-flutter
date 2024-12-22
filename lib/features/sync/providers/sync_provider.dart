import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncNotifier extends StateNotifier<SyncStatus> {
  final SyncService _syncService;

  SyncNotifier(this._syncService) : super(SyncStatus.idle);

  Future<void> sync() async {
    if (state == SyncStatus.syncing) return;
    
    state = SyncStatus.syncing;
    try {
      await _syncService.syncAll();
      state = SyncStatus.success;
      
      // Reset to idle after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (state == SyncStatus.success) {
        state = SyncStatus.idle;
      }
    } catch (e) {
      state = SyncStatus.error;
      
      // Reset to idle after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (state == SyncStatus.error) {
        state = SyncStatus.idle;
      }
    }
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncNotifier(syncService);
});
