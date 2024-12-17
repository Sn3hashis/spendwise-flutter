import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/transaction_list_item.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/transaction_filter.dart';
import '../screens/filter_screen.dart';
import '../widgets/date_range_selector.dart';
import '../../../core/services/haptic_service.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionFilter _filter = const TransactionFilter();
  late DateRange _selectedRange;

  @override
  void initState() {
    super.initState();
    // Initialize with current month
    final now = DateTime.now();
    _selectedRange = DateRange(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
      type: DateRangeType.month,
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_filter.types.isNotEmpty) count++;
    if (_filter.sortBy != SortBy.newest) count++;
    if (_filter.categories.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final settings = ref.watch(settingsProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header with Month Selector
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DateRangeSelector(
                      selectedRange: _selectedRange,
                      onRangeSelected: (range) {
                        setState(() {
                          _selectedRange = range;
                        });
                        // TODO: Filter transactions based on selected date range
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            CupertinoIcons.slider_horizontal_3,
                            color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                          ),
                          if (_getActiveFilterCount() > 0)
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: CupertinoColors.systemPurple,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Center(
                                  child: Text(
                                    _getActiveFilterCount().toString(),
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      onPressed: () async {
                        await HapticService.lightImpact(ref);
                        if (!mounted) return;
                        
                        showCupertinoModalPopup<void>(
                          context: context,
                          builder: (BuildContext context) => FilterScreen(
                            initialFilter: _filter,
                            onApply: (filter) {
                              setState(() {
                                _filter = filter;
                              });
                              // TODO: Apply filter to transactions
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Financial Report Button
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text(
                      'See your financial report',
                      style: TextStyle(
                        fontSize: 17,
                        color: CupertinoColors.systemPurple,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      CupertinoIcons.chevron_right,
                      color: CupertinoColors.systemPurple,
                      size: 20,
                    ),
                  ],
                ),
              ),
              onPressed: () {
                // TODO: Navigate to financial report
              },
            ),
            const SizedBox(height: 8),
            // Transactions List
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                      ),
                    ),
                  ),
                  TransactionListItem(
                    title: 'Shopping',
                    description: 'Buy some grocery',
                    amount: -120,
                    time: '10:00 AM',
                    icon: CupertinoIcons.shopping_cart,
                    iconBackgroundColor: CupertinoColors.systemOrange,
                    isDarkMode: isDarkMode,
                    currencyCode: settings.currency,
                  ),
                  // Add more transactions as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
