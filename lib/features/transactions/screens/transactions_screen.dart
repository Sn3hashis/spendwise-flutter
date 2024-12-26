import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/transaction_list_item.dart';
import '../models/transaction_filter.dart';
import '../models/transaction_model.dart';
import '../screens/filter_screen.dart';
import '../widgets/date_range_selector.dart';
import '../../../core/services/haptic_service.dart';
import '../providers/transactions_provider.dart';
import '../providers/transaction_filter_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../services/sms_transaction_service.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  late DateRange _selectedRange;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateRange(
      startDate: DateTime(now.year, now.month, 1),
      endDate: now,
      type: DateRangeType.month,
    );
    // Load initial transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(transactionsProvider.notifier).loadTransactions();
    });
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    final filter = ref.watch(transactionFilterProvider);
    final searchQuery = _searchController.text.toLowerCase();

    return transactions.where((transaction) {
      // Search filter
      if (searchQuery.isNotEmpty) {
        final matchesAmount =
            transaction.amount.toString().contains(searchQuery);
        final matchesDescription =
            transaction.description.toLowerCase().contains(searchQuery);
        final matchesCategory =
            transaction.category.name.toLowerCase().contains(searchQuery);
        if (!matchesAmount && !matchesDescription && !matchesCategory) {
          return false;
        }
      }

      // Date range filter
      final isInDateRange = transaction.date.isAfter(
              _selectedRange.startDate.subtract(const Duration(days: 1))) &&
          transaction.date
              .isBefore(_selectedRange.endDate.add(const Duration(days: 1)));
      if (!isInDateRange) return false;

      // Transaction type filter
      if (filter.types.isNotEmpty && !filter.types.contains(transaction.type)) {
        return false;
      }

      // Category filter
      if (filter.categories.isNotEmpty &&
          !filter.categories.contains(transaction.category.id)) {
        return false;
      }

      // Bank transaction filter
      if (filter.isBankTransaction && transaction.messageId == null) {
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

  Widget _buildSearchBar() {
    final isDarkMode = ref.watch(themeProvider);

    if (!_isSearchExpanded) {
      return CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          setState(() {
            _isSearchExpanded = true;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _searchFocusNode.requestFocus();
          });
        },
        child: const Icon(CupertinoIcons.search),
      );
    }

    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFE5E5EA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CupertinoTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                placeholder: 'Search transactions...',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.search,
                    size: 20,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                suffix: _searchController.text.isNotEmpty
                    ? CupertinoButton(
                        padding: const EdgeInsets.only(right: 8),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        child: const Icon(
                          CupertinoIcons.clear_circled_solid,
                          size: 20,
                          color: CupertinoColors.systemGrey,
                        ),
                      )
                    : null,
                decoration: null,
                onChanged: (value) {
                  setState(() {});
                },
                style: TextStyle(
                  color: isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),
              ),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.only(left: 8),
            onPressed: () {
              setState(() {
                _isSearchExpanded = false;
                _searchController.clear();
                _searchFocusNode.unfocus();
              });
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);
    final filteredTransactions = _getFilteredTransactions(transactions);
    final isDarkMode = ref.watch(themeProvider);
    final filter = ref.watch(transactionFilterProvider);
    final backgroundColor =
        isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    if (!_isSearchExpanded)
                      // Date Range Selector
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
                    // Search Bar
                    _buildSearchBar(),
                    if (!_isSearchExpanded) ...[
                      const SizedBox(width: 8),
                      // SMS Sync Button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await HapticService.lightImpact(ref);
                          try {
                            await ref
                                .read(smsTransactionServiceProvider)
                                .syncSmsTransactions();
                            if (mounted) {
                              _showAlert(
                                  'Successfully synced SMS transactions');
                            }
                          } catch (e) {
                            if (mounted) {
                              _showAlert(e.toString());
                            }
                          }
                        },
                        child: const Icon(CupertinoIcons.arrow_2_circlepath),
                      ),
                      const SizedBox(width: 8),
                      // Filter Button
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await HapticService.lightImpact(ref);
                          if (!mounted) return;

                          await showCupertinoModalPopup(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => FilterScreen(
                              initialFilter: filter,
                              onApply: (newFilter) {
                                if (mounted) {
                                  ref
                                      .read(transactionFilterProvider.notifier)
                                      .updateFilter(newFilter);
                                }
                              },
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            const Icon(CupertinoIcons.slider_horizontal_3),
                            if (_getActiveFilterCount() > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF7F3DFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    _getActiveFilterCount().toString(),
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Transaction List
            SliverFillRemaining(
              hasScrollBody: true,
              child: filteredTransactions.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontSize: 17,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                      ),
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final transaction = filteredTransactions[index];
                        return TransactionListItem(
                          key: ValueKey(transaction.id),
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

  int _getActiveFilterCount() {
    final filter = ref.watch(transactionFilterProvider);
    int count = 0;
    if (filter.types.isNotEmpty) count++;
    if (filter.sortBy != SortBy.newest) count++;
    if (filter.categories.isNotEmpty) count++;
    if (filter.isBankTransaction) count++;
    return count;
  }

  Transaction _updateTransactionCurrency(Transaction transaction) {
    final currentCurrency = ref.watch(currencyProvider);
    return transaction.copyWith(
      currencyCode: currentCurrency.code,
    );
  }

  void _showAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
