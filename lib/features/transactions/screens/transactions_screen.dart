import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/transaction_list_item.dart';
import '../../settings/providers/settings_provider.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_model.dart';
import '../screens/filter_screen.dart';
import '../widgets/date_range_selector.dart';
import '../../../core/services/haptic_service.dart';
import '../../categories/providers/categories_provider.dart';
import '../providers/transactions_provider.dart';
import '../providers/transaction_filter_provider.dart';
import '../../../core/providers/currency_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late DateRange _selectedRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateRange(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
      type: DateRangeType.month,
    );
  }

  int _getActiveFilterCount() {
    final filter = ref.watch(transactionFilterProvider);
    int count = 0;
    if (filter.types.isNotEmpty) count++;
    if (filter.sortBy != SortBy.newest) count++;
    if (filter.categories.isNotEmpty) count++;
    return count;
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    final filter = ref.watch(transactionFilterProvider);
    return transactions.where((transaction) {
      // Date range filter
      final isInDateRange = transaction.date.isAfter(_selectedRange.startDate) && 
                           transaction.date.isBefore(_selectedRange.endDate.add(const Duration(days: 1)));
      if (!isInDateRange) return false;

      // Transaction type filter
      if (filter.types.isNotEmpty && !filter.types.contains(transaction.type)) {
        return false;
      }

      // Category filter
      if (filter.categories.isNotEmpty && !filter.categories.contains(transaction.category.id)) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (filter.sortBy) {
          case SortBy.newest:
            return b.date.compareTo(a.date);
          case SortBy.oldest:
            return a.date.compareTo(b.date);
          case SortBy.highest:
            return b.amount.abs().compareTo(a.amount.abs());
          case SortBy.lowest:
            return a.amount.abs().compareTo(b.amount.abs());
        }
      });
  }

  Transaction _updateTransactionCurrency(Transaction transaction) {
    final currentCurrency = ref.watch(currencyProvider);
    return transaction.copyWith(
      currencyCode: currentCurrency.code,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentCurrency = ref.watch(currencyProvider).code;
    final transactions = ref.watch(transactionsProvider);
    
    // Apply filters to transactions
    final filteredTransactions = _getFilteredTransactions(transactions);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header with Month Selector
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DateRangeSelector(
                      selectedRange: _selectedRange,
                      onRangeSelected: (range) {
                        setState(() {
                          _selectedRange = range;
                        });
                      },
                    ),
                  ),
                  CupertinoButton(
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
                          initialFilter: ref.read(transactionFilterProvider),
                          onApply: (filter) {
                            ref.read(transactionFilterProvider.notifier).updateFilter(filter);
                          },
                        ),
                      );
                    },
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
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(
                          color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2,
                          fontSize: 17,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return TransactionListItem(
                          transaction: _updateTransactionCurrency(transaction),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
