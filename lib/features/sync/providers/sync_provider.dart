import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/sync_service.dart';

enum SyncStatus {
  initial,
  syncing,
  success,
  error,
}

class SyncNotifier extends StateNotifier<SyncStatus> {
  final Ref ref;
  DateTime? _lastSyncTime;

  SyncNotifier(this.ref) : super(SyncStatus.initial) {
    _loadLastSyncTime();
  }

  Future<void> _loadLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('last_sync_time');
    if (timestamp != null) {
      _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
  }

  Future<void> _saveLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_sync_time', DateTime.now().millisecondsSinceEpoch);
  }

  DateTime? get lastSyncTime => _lastSyncTime;

  Future<void> sync() async {
    state = SyncStatus.syncing;
    try {
      await ref.read(syncServiceProvider).syncAll();
      await _saveLastSyncTime();
      _lastSyncTime = DateTime.now();
      state = SyncStatus.success;
    } catch (e) {
      state = SyncStatus.error;
      rethrow;
    }
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncStatus>((ref) {
  return SyncNotifier(ref);
});
