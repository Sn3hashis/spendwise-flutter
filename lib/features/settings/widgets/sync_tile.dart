import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../sync/providers/sync_provider.dart';

class SyncTile extends ConsumerWidget {
  const SyncTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncProvider);
    
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(
          syncStatus == SyncStatus.syncing 
              ? Icons.sync
              : syncStatus == SyncStatus.success
                  ? Icons.check_circle
                  : syncStatus == SyncStatus.error
                      ? Icons.error
                      : Icons.sync,
          color: syncStatus == SyncStatus.success
              ? Colors.green
              : syncStatus == SyncStatus.error
                  ? Colors.red
                  : null,
        ),
        title: const Text('Sync Data'),
        subtitle: Text(
          syncStatus == SyncStatus.syncing
              ? 'Syncing...'
              : syncStatus == SyncStatus.success
                  ? 'Sync completed'
                  : syncStatus == SyncStatus.error
                      ? 'Sync failed'
                      : 'Sync data with cloud',
        ),
        trailing: syncStatus == SyncStatus.syncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : null,
        onTap: syncStatus == SyncStatus.syncing
            ? null
            : () => ref.read(syncProvider.notifier).sync(),
      ),
    );
  }
}
