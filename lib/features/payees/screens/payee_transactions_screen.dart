import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/date_helper.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../transactions/screens/transaction_details_screen.dart';
import '../models/payee_model.dart';

class PayeeTransactionsScreen extends ConsumerStatefulWidget {
  final Payee payee;

  const PayeeTransactionsScreen({
    super.key,
    required this.payee,
  });

  @override
  ConsumerState<PayeeTransactionsScreen> createState() => _PayeeTransactionsScreenState();
}

class _PayeeTransactionsScreenState extends ConsumerState<PayeeTransactionsScreen> {
  final String currencySymbol = '₹';
  String _selectedFilter = 'All Time';
  String _selectedSort = 'Latest First';
  final ScrollController _scrollController = ScrollController();

  final List<String> _filterOptions = [
    'All Time',
    'This Month',
    'Last Month',
    'Last 3 Months',
    'Last 6 Months',
    'This Year',
  ];

  final List<String> _sortOptions = [
    'Latest First',
    'Oldest First',
    'Highest Amount',
    'Lowest Amount',
  ];

  final GlobalKey _screenshotKey = GlobalKey();

  Future<void> _shareTransactionSummary(String payeeName, double totalDue) async {
    try {
      RenderRepaintBoundary boundary = _screenshotKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final message = '''
Hi ${payeeName}, 
${totalDue < 0 ? "I owe you" : "You owe me"} ${currencySymbol}${totalDue.abs()}

Track finances in Spendwise
''';

      await Share.shareXFiles(
        [
          XFile.fromData(
            pngBytes,
            name: 'transaction_summary.png',
            mimeType: 'image/png',
          ),
        ],
        text: message,
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
    }
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    final filtered = transactions.where((transaction) {
      switch (_selectedFilter) {
        case 'This Month':
          return transaction.date.year == now.year && 
                 transaction.date.month == now.month;
        case 'Last Month':
          final lastMonth = DateTime(now.year, now.month - 1);
          return transaction.date.year == lastMonth.year && 
                 transaction.date.month == lastMonth.month;
        case 'Last 3 Months':
          final threeMonthsAgo = DateTime(now.year, now.month - 3);
          return transaction.date.isAfter(threeMonthsAgo);
        case 'Last 6 Months':
          final sixMonthsAgo = DateTime(now.year, now.month - 6);
          return transaction.date.isAfter(sixMonthsAgo);
        case 'This Year':
          return transaction.date.year == now.year;
        default:
          return true;
      }
    }).toList();

    // Sort transactions
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'Oldest First':
          return a.date.compareTo(b.date);
        case 'Highest Amount':
          return b.amount.abs().compareTo(a.amount.abs());
        case 'Lowest Amount':
          return a.amount.abs().compareTo(b.amount.abs());
        default: // Latest First
          return b.date.compareTo(a.date);
      }
    });

    return filtered;
  }

  Widget _buildTransactionStats(List<Transaction> transactions, bool isDarkMode, double totalDue) {
    final totalTransactions = transactions.length;
    final averageAmount = totalTransactions > 0 
        ? transactions.fold<double>(0, (sum, t) => sum + t.amount.abs()) / totalTransactions 
        : 0.0;
    final highestAmount = transactions.isEmpty 
        ? 0.0 
        : transactions.map((t) => t.amount.abs()).reduce((a, b) => a > b ? a : b);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF2C2C2E) 
              : const Color(0xFFE5E5EA),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Transaction Statistics',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode 
                      ? CupertinoColors.white 
                      : CupertinoColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (totalDue < 0 ? CupertinoColors.destructiveRed : CupertinoColors.systemGreen)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Due: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: totalDue < 0 
                        ? CupertinoColors.destructiveRed 
                        : CupertinoColors.systemGreen,
                  ),
                ),
                Text(
                  '$currencySymbol${totalDue.abs()}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: totalDue < 0 
                        ? CupertinoColors.destructiveRed 
                        : CupertinoColors.systemGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total', totalTransactions.toString(), isDarkMode),
              _buildStatItem('Average', '$currencySymbol${averageAmount.toStringAsFixed(2)}', isDarkMode),
              _buildStatItem('Highest', '$currencySymbol$highestAmount', isDarkMode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, bool isDarkMode) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode 
                ? CupertinoColors.systemGrey 
                : CupertinoColors.systemGrey2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDarkMode 
                ? CupertinoColors.white 
                : CupertinoColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartInsights(List<Transaction> transactions, bool isDarkMode) {
    if (transactions.isEmpty) return const SizedBox.shrink();

    final mostFrequentAmount = _getMostFrequentAmount(transactions);
    final lastTransactionDate = transactions.first.date;
    final monthlyAverage = _getMonthlyAverage(transactions);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF2C2C2E) 
              : const Color(0xFFE5E5EA),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Smart Insights',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode 
                      ? CupertinoColors.white 
                      : CupertinoColors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            'Most frequent transaction amount: $currencySymbol$mostFrequentAmount',
            isDarkMode,
          ),
          _buildInsightItem(
            'Last transaction: ${DateFormat('MMM d, yyyy').format(lastTransactionDate)}',
            isDarkMode,
          ),
          _buildInsightItem(
            'Monthly average: $currencySymbol${monthlyAverage.toStringAsFixed(2)}',
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.lightbulb,
            size: 16,
            color: CupertinoColors.systemYellow,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode 
                    ? CupertinoColors.white 
                    : CupertinoColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMostFrequentAmount(List<Transaction> transactions) {
    final amountFrequency = <double, int>{};
    for (var transaction in transactions) {
      final amount = transaction.amount.abs();
      amountFrequency[amount] = (amountFrequency[amount] ?? 0) + 1;
    }
    return amountFrequency.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  double _getMonthlyAverage(List<Transaction> transactions) {
    if (transactions.isEmpty) return 0;
    
    final totalAmount = transactions.fold<double>(
      0, 
      (sum, transaction) => sum + transaction.amount.abs()
    );
    
    final firstDate = transactions.map((t) => t.date).reduce((a, b) => a.isBefore(b) ? a : b);
    final lastDate = transactions.map((t) => t.date).reduce((a, b) => a.isAfter(b) ? a : b);
    
    final months = (lastDate.year - firstDate.year) * 12 + 
                  lastDate.month - firstDate.month + 1;
    
    return totalAmount / months;
  }

  Widget _buildFilterSort(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showFilterOptions(isDarkMode),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode 
                        ? const Color(0xFF2C2C2E) 
                        : const Color(0xFFE5E5EA),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.slider_horizontal_3,
                      size: 16,
                      color: isDarkMode 
                          ? CupertinoColors.white 
                          : CupertinoColors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedFilter,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode 
                            ? CupertinoColors.white 
                            : CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showSortOptions(isDarkMode),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDarkMode 
                        ? const Color(0xFF2C2C2E) 
                        : const Color(0xFFE5E5EA),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.sort_down,
                      size: 16,
                      color: isDarkMode 
                          ? CupertinoColors.white 
                          : CupertinoColors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedSort,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode 
                            ? CupertinoColors.white 
                            : CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(bool isDarkMode) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter Transactions'),
        actions: _filterOptions.map((filter) => 
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _selectedFilter = filter);
              Navigator.pop(context);
            },
            isDefaultAction: filter == _selectedFilter,
            child: Text(filter),
          ),
        ).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showSortOptions(bool isDarkMode) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Sort Transactions'),
        actions: _sortOptions.map((sort) => 
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _selectedSort = sort);
              Navigator.pop(context);
            },
            isDefaultAction: sort == _selectedSort,
            child: Text(sort),
          ),
        ).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction, bool isDarkMode) {
    final isExpense = transaction.amount < 0;
    final isToPayee = transaction.toPayee?.id == widget.payee.id;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => TransactionDetailsScreen(
              transaction: transaction,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDarkMode 
                  ? const Color(0xFF2C2C2E) 
                  : const Color(0xFFE5E5EA),
            ),
          ),
        ),
        child: Row(
          children: [
            // Category Icon or Transfer Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isToPayee ? CupertinoColors.activeBlue : transaction.category.color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isToPayee ? CupertinoIcons.arrow_right_circle : transaction.category.icon,
                color: isToPayee ? CupertinoColors.activeBlue : transaction.category.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Transaction Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description.isEmpty 
                        ? (isToPayee ? 'Transfer to ${widget.payee.name}' : transaction.category.name)
                        : transaction.description,
                    style: TextStyle(
                      fontSize: 17,
                      color: isDarkMode 
                          ? CupertinoColors.white 
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDateTime(transaction.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              '$currencySymbol${transaction.amount.abs()}',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isExpense
                    ? CupertinoColors.destructiveRed
                    : CupertinoColors.systemGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalDue, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF2C2C2E) 
              : const Color(0xFFE5E5EA),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Total Due',
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode 
                  ? CupertinoColors.systemGrey 
                  : CupertinoColors.systemGrey2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$currencySymbol${totalDue.abs()}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: totalDue < 0
                  ? CupertinoColors.destructiveRed
                  : CupertinoColors.systemGreen,
            ),
          ),
          Text(
            totalDue < 0 ? 'You owe' : 'Owes you',
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode 
                  ? CupertinoColors.systemGrey 
                  : CupertinoColors.systemGrey2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final allTransactions = ref.watch(transactionsProvider);
    
    // Filter transactions for this payee
    final allPayeeTransactions = allTransactions.where((transaction) => 
      transaction.fromPayee?.id == widget.payee.id || 
      transaction.toPayee?.id == widget.payee.id ||
      transaction.payeeId == widget.payee.id
    ).toList();

    // Apply filter and sort
    final payeeTransactions = _getFilteredTransactions(allPayeeTransactions);
    
    // Calculate total due
    final totalDue = payeeTransactions.fold<double>(0, (sum, transaction) {
      if (transaction.toPayee?.id == widget.payee.id) {
        return sum - transaction.amount;
      } else {
        return sum + transaction.amount;
      }
    });

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: Text(widget.payee.name),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _shareTransactionSummary(widget.payee.name, totalDue),
          child: const Icon(CupertinoIcons.share),
        ),
      ),
      child: SafeArea(
        child: RepaintBoundary(
          key: _screenshotKey,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                },
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Transaction Statistics
                    _buildTransactionStats(payeeTransactions, isDarkMode, totalDue),
                    // Smart Insights
                    _buildSmartInsights(payeeTransactions, isDarkMode),
                    // Filter and Sort
                    _buildFilterSort(isDarkMode),
                  ],
                ),
              ),
              // Transactions List
              payeeTransactions.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No transactions with this payee',
                              style: TextStyle(
                                fontSize: 17,
                                color: isDarkMode 
                                    ? CupertinoColors.systemGrey 
                                    : CupertinoColors.systemGrey2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a transaction to get started',
                              style: TextStyle(
                                fontSize: 15,
                                color: isDarkMode 
                                    ? CupertinoColors.systemGrey 
                                    : CupertinoColors.systemGrey2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildTransactionItem(
                          context,
                          payeeTransactions[index],
                          isDarkMode,
                        ),
                        childCount: payeeTransactions.length,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 