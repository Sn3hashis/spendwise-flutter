import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../sync/providers/sync_provider.dart';

class SyncTile extends ConsumerWidget {
  const SyncTile({super.key});

  String _formatLastSyncTime(DateTime? lastSyncTime) {
    if (lastSyncTime == null) return 'Never synced';
    
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime);

    if (difference.inSeconds < 30) {
      return 'Just now';
    } else if (difference.inMinutes < 1) {
      return 'Few seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(lastSyncTime);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncProvider);
    final syncNotifier = ref.watch(syncProvider.notifier);
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: syncStatus == SyncStatus.syncing 
            ? null 
            : () => ref.read(syncProvider.notifier).sync(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode 
                  ? const Color(0xFF2C2C2E) 
                  : const Color(0xFFE5E5EA),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF5856D6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  syncStatus == SyncStatus.syncing 
                      ? CupertinoIcons.arrow_2_circlepath
                      : syncStatus == SyncStatus.success
                          ? CupertinoIcons.check_mark_circled_solid
                          : syncStatus == SyncStatus.error
                              ? CupertinoIcons.exclamationmark_circle_fill
                              : CupertinoIcons.arrow_2_circlepath,
                  color: const Color(0xFF5856D6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sync Data',
                      style: TextStyle(
                        fontSize: 17,
                        color: isDarkMode 
                            ? AppTheme.textPrimaryDark 
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    Text(
                      syncStatus == SyncStatus.syncing
                          ? 'Syncing...'
                          : syncStatus == SyncStatus.success
                              ? 'Last synced ${_formatLastSyncTime(syncNotifier.lastSyncTime)}'
                              : syncStatus == SyncStatus.error
                                  ? 'Sync failed'
                                  : 'Last synced ${_formatLastSyncTime(syncNotifier.lastSyncTime)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode 
                            ? AppTheme.textSecondaryDark 
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (syncStatus == SyncStatus.syncing)
                const CupertinoActivityIndicator()
              else
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: isDarkMode 
                      ? AppTheme.textSecondaryDark 
                      : AppTheme.textSecondaryLight,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
