import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DateTimeRange, Colors, LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../widgets/trend_chart.dart';
import '../widgets/payment_patterns.dart';
import '../services/export_service.dart';
import '../widgets/financial_overview.dart';
import '../../../core/services/haptic_service.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedPeriod = 'Monthly';
  final List<String> _periodOptions = ['Monthly', 'Yearly', 'Custom'];
  DateTimeRange? _customDateRange;

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final isDarkMode = ref.read(themeProvider);
    
    final result = await showCupertinoModalPopup<DateTimeRange>(
      context: context,
      builder: (BuildContext context) {
        DateTime startDate = now.subtract(const Duration(days: 30));
        DateTime endDate = now;
        
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await HapticService.lightImpact(ref);
                        Navigator.pop(
                          context,
                          DateTimeRange(
                            start: startDate,
                            end: endDate,
                          ),
                        );
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Start Date',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDarkMode 
                                  ? CupertinoColors.systemGrey 
                                  : CupertinoColors.systemGrey2,
                            ),
                          ),
                        ),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDarkMode 
                                    ? const Color(0xFF2C2C2E) 
                                    : const Color(0xFFE5E5EA),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: startDate,
                            maximumDate: endDate,
                            onDateTimeChanged: (DateTime value) async {
                              await HapticService.selectionClick(ref);
                              startDate = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'End Date',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDarkMode 
                                  ? CupertinoColors.systemGrey 
                                  : CupertinoColors.systemGrey2,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 180,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: endDate,
                            minimumDate: startDate,
                            maximumDate: now,
                            onDateTimeChanged: (DateTime value) async {
                              await HapticService.selectionClick(ref);
                              endDate = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _customDateRange = result;
      });
    }
  }

  void _exportData() async {
    final isDarkMode = ref.watch(themeProvider);
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Export Data'),
        message: const Text('Choose export format'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              
              // Capture chart images
              final trendChartImage = await _captureChart(_trendChartKey);
              final categoryChartImage = await _captureChart(_categoryChartKey);
              final patternChartImage = await _captureChart(_patternChartKey);

              await ExportService.exportToPDF(
                transactions: _getFilteredTransactions(),
                period: _selectedPeriod,
                context: context,
                trendChartImage: trendChartImage,
                categoryChartImage: categoryChartImage,
                patternChartImage: patternChartImage,
              );
            },
            child: const Text('Export as PDF with Charts'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await ExportService.exportToExcel(_getFilteredTransactions());
            },
            child: const Text('Export as Excel'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  // Add GlobalKeys for charts
  final GlobalKey _trendChartKey = GlobalKey();
  final GlobalKey _categoryChartKey = GlobalKey();
  final GlobalKey _patternChartKey = GlobalKey();
  final GlobalKey _overviewKey = GlobalKey();

  Future<List<int>?> _captureChart(GlobalKey key) async {
    try {
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing chart: $e');
      return null;
    }
  }

  List<Transaction> _getFilteredTransactions() {
    final transactions = ref.read(transactionsProvider);
    final now = DateTime.now();
    
    return transactions.where((transaction) {
      if (_customDateRange != null) {
        return transaction.date.isAfter(_customDateRange!.start) && 
               transaction.date.isBefore(_customDateRange!.end);
      }

      switch (_selectedPeriod) {
        case 'Monthly':
          return transaction.date.year == now.year && 
                 transaction.date.month == now.month;
        case 'Yearly':
          return transaction.date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  double _getTotalSpending() {
    final transactions = ref.read(transactionsProvider);
    return transactions.fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final transactions = ref.watch(transactionsProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: const Text('Analytics & Reports'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _exportData,
          child: const Icon(CupertinoIcons.share),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Period Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1C1C1E) : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CupertinoSegmentedControl<String>(
                        children: {
                          for (final period in _periodOptions)
                            period: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                period == 'Custom' && _customDateRange != null
                                    ? '${DateFormat('MMM d').format(_customDateRange!.start)} - ${DateFormat('MMM d').format(_customDateRange!.end)}'
                                    : period,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: _selectedPeriod == period
                                      ? CupertinoColors.white
                                      : (isDarkMode ? CupertinoColors.white : CupertinoColors.black),
                                ),
                              ),
                            ),
                        },
                        onValueChanged: (value) async {
                          await HapticService.selectionClick(ref);
                          setState(() {
                            _selectedPeriod = value;
                            if (value == 'Custom') {
                              _selectDateRange();
                            }
                          });
                        },
                        groupValue: _selectedPeriod,
                        padding: EdgeInsets.zero,
                        selectedColor: CupertinoColors.systemPurple,
                        unselectedColor: Colors.transparent,
                      ),
                    ),
                  ),
                  if (_selectedPeriod == 'Custom' && _customDateRange != null) ...[
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await HapticService.lightImpact(ref);
                        setState(() {
                          _selectedPeriod = 'Monthly';
                          _customDateRange = null;
                        });
                      },
                      child: Icon(
                        CupertinoIcons.refresh_thin,
                        color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Charts and Analysis
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Financial Overview
                  _buildSection(
                    'Financial Overview',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Summary for ${_selectedPeriod.toLowerCase()} period',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FinancialOverview(
                          transactions: transactions,
                          period: _selectedPeriod,
                          dateRange: _customDateRange,
                          chartKey: _overviewKey,
                        ),
                      ],
                    ),
                    isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  
                  // Monthly Comparison
                  _buildSection(
                    'Monthly Comparison',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Compare with last month',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode 
                                    ? CupertinoColors.systemGrey 
                                    : CupertinoColors.systemGrey2,
                              ),
                            ),
                            _buildComparisonChip(_calculateMonthlyChange()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildMonthlyComparison(),
                      ],
                    ),
                    isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  
                  // Top Categories
                  _buildSection(
                    'Top Categories',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Spending by Category',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode 
                                    ? CupertinoColors.systemGrey 
                                    : CupertinoColors.systemGrey2,
                              ),
                            ),
                            Text(
                              'Total: ₹${_getTotalSpending().toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode 
                                    ? CupertinoColors.systemGrey 
                                    : CupertinoColors.systemGrey2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTopCategories(),
                      ],
                    ),
                    isDarkMode,
                  ),
                  const SizedBox(height: 16),
                  
                  // Payment Patterns
                  _buildSection(
                    'Payment Patterns',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Daily Transaction Distribution',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 240,
                          child: PaymentPatterns(
                            transactions: transactions,
                            period: _selectedPeriod,
                            dateRange: _customDateRange,
                            chartKey: _patternChartKey,
                          ),
                        ),
                      ],
                    ),
                    isDarkMode,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF2C2C2E) 
              : const Color(0xFFE5E5EA),
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.2) 
                : Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode 
                  ? CupertinoColors.white 
                  : CupertinoColors.black,
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildComparisonChip(double percentageChange) {
    final isPositive = percentageChange > 0;
    final color = isPositive 
        ? CupertinoColors.systemRed 
        : CupertinoColors.systemGreen;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive 
                ? CupertinoIcons.arrow_up_right 
                : CupertinoIcons.arrow_down_right,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${percentageChange.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyComparison() {
    final currentMonth = _getMonthlyStats(DateTime.now());
    final lastMonth = _getMonthlyStats(
      DateTime.now().subtract(const Duration(days: 30))
    );

    return Column(
      children: [
        _buildComparisonRow(
          'Income',
          currentMonth.income,
          lastMonth.income,
          CupertinoColors.systemGreen,
        ),
        const SizedBox(height: 12),
        _buildComparisonRow(
          'Expenses',
          currentMonth.expenses,
          lastMonth.expenses,
          CupertinoColors.systemRed,
        ),
        const SizedBox(height: 12),
        _buildComparisonRow(
          'Savings',
          currentMonth.savings,
          lastMonth.savings,
          CupertinoColors.systemBlue,
        ),
      ],
    );
  }

  Widget _buildComparisonRow(
    String label, 
    double current, 
    double previous, 
    Color color,
  ) {
    final percentageChange = previous != 0 
        ? ((current - previous) / previous) * 100 
        : 0.0;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${current.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              _buildComparisonChip(percentageChange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopCategories() {
    final isDarkMode = ref.watch(themeProvider);
    final transactions = ref.watch(transactionsProvider);
    final categoryStats = _getCategoryStats();
    final sortedCategories = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedCategories.take(5);

    return Column(
      children: topCategories.map((entry) {
        final percentage = (entry.value / _getTotalSpending()) * 100;
        final categoryTransaction = transactions.firstWhere(
          (t) => t.category.name == entry.key,
          orElse: () => transactions.first,
        );
        final categoryColor = categoryTransaction.category.color;
        final categoryIcon = categoryTransaction.category.icon;
        
        return GestureDetector(
          onTap: () => _showCategoryDetails(
            context,
            entry.key,
            categoryColor,
            categoryIcon,
            transactions,
            isDarkMode,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? AppTheme.cardDark 
                  : AppTheme.cardLight,
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: CupertinoColors.systemGrey6,
                          valueColor: AlwaysStoppedAnimation(categoryColor),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.systemGrey2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  MonthlyStats _getMonthlyStats(DateTime date) {
    final transactions = ref.read(transactionsProvider);
    final monthTransactions = transactions.where((t) => 
      t.date.year == date.year && t.date.month == date.month
    );
    
    final income = monthTransactions
        .where((t) => t.amount > 0)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final expenses = monthTransactions
        .where((t) => t.amount < 0)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    
    return MonthlyStats(
      income: income,
      expenses: expenses,
      savings: income - expenses,
    );
  }

  Map<String, double> _getCategoryStats() {
    final stats = <String, double>{};
    final filteredTransactions = _getFilteredTransactions();
    
    for (var transaction in filteredTransactions) {
      final category = transaction.category.name;
      stats[category] = (stats[category] ?? 0) + transaction.amount.abs();
    }
    
    return stats;
  }

  double _calculateMonthlyChange() {
    final currentMonth = _getMonthlyStats(DateTime.now());
    final lastMonth = _getMonthlyStats(
      DateTime.now().subtract(const Duration(days: 30))
    );
    
    return lastMonth.expenses != 0 
        ? ((currentMonth.expenses - lastMonth.expenses) / lastMonth.expenses) * 100 
        : 0.0;
  }

  void _showCategoryDetails(
    BuildContext context, 
    String category,
    Color categoryColor,
    IconData categoryIcon,
    List<Transaction> transactions,
    bool isDarkMode,
  ) {
    final categoryTransactions = transactions
        .where((t) => t.category.name == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
      
    final total = categoryTransactions.fold<double>(
      0, (sum, t) => sum + t.amount.abs()
    );
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Category Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(categoryIcon, color: categoryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  _buildCategoryStatCard(
                    'Transactions',
                    categoryTransactions.length.toString(),
                    CupertinoColors.activeBlue,
                    CupertinoIcons.chart_bar,
                    isDarkMode,
                  ),
                  const SizedBox(width: 12),
                  _buildCategoryStatCard(
                    'Average',
                    '₹${(total / categoryTransactions.length).toStringAsFixed(2)}',
                    CupertinoColors.systemGreen,
                    CupertinoIcons.money_dollar,
                    isDarkMode,
                  ),
                ],
              ),
            ),
            
            // Transactions List
            Expanded(
              child: CupertinoScrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categoryTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = categoryTransactions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode 
                            ? const Color(0xFF1C1C1E) 
                            : CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  transaction.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM d, yyyy').format(transaction.date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDarkMode 
                                        ? CupertinoColors.systemGrey 
                                        : CupertinoColors.systemGrey2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${transaction.amount.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: transaction.amount < 0 
                                  ? CupertinoColors.systemRed 
                                  : CupertinoColors.systemGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStatCard(
    String label, 
    String value, 
    Color color,
    IconData icon,
    bool isDarkMode,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MonthlyStats {
  final double income;
  final double expenses;
  final double savings;

  MonthlyStats({
    required this.income,
    required this.expenses,
    required this.savings,
  });
} 