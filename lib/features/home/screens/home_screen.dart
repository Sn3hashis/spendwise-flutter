import 'package:flutter/cupertino.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';
import '../../../core/services/haptic_service.dart';
import '../../../features/transactions/providers/transactions_provider.dart';
import '../../../features/transactions/widgets/transaction_list_item.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/widgets/exit_dialog.dart';
import 'package:flutter/services.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime selectedMonth;
  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
  }

  String _getMonthName(DateTime date) {
    return months[date.month - 1];
  }

  void _showMonthPicker() {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    // Month Picker
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMonth.month - 1,
                        ),
                        onSelectedItemChanged: (int index) async {
                          // Add haptic feedback
                          await HapticService.lightImpact(ref);
                          if (index + 1 <= currentMonth) {
                            setState(() {
                              selectedMonth = DateTime(
                                selectedMonth.year,
                                index + 1,
                                selectedMonth.day,
                              );
                            });
                          }
                        },
                        children: List<Widget>.generate(12, (int index) {
                          final isDisabled = selectedMonth.year == currentYear && 
                                           index + 1 > currentMonth;
                          return Center(
                            child: Text(
                              months[index],
                              style: TextStyle(
                                color: isDisabled 
                                    ? CupertinoColors.systemGrey.withOpacity(0.5)
                                    : CupertinoColors.label.resolveFrom(context),
                                fontSize: 16,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    // Year Picker
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 40,
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedMonth.year - currentYear + 1,
                        ),
                        onSelectedItemChanged: (int index) async {
                          // Add haptic feedback
                          await HapticService.lightImpact(ref);
                          setState(() {
                            selectedMonth = DateTime(
                              currentYear - 1 + index,
                              selectedMonth.month,
                              selectedMonth.day,
                            );
                          });
                        },
                        children: List<Widget>.generate(
                          2, // Show current year and previous year
                          (int index) {
                            final year = currentYear - 1 + index;
                            return Center(
                              child: Text(
                                year.toString(),
                                style: TextStyle(
                                  color: CupertinoColors.label.resolveFrom(context),
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToPreviousMonth() {
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month - 1,
        selectedMonth.day,
      );
    });
  }

  void _navigateToNextMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      selectedMonth.day,
    );
    
    // Only allow navigation up to current month
    if (nextMonth.isBefore(DateTime(now.year, now.month + 1, 1))) {
      setState(() {
        selectedMonth = nextMonth;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!mounted) return false;
    
    final shouldPop = await ExitDialog.show(context);
    if (shouldPop ?? false) {
      SystemNavigator.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentCurrency = ref.watch(currencyProvider);
    final size = MediaQuery.of(context).size;
    final transactions = ref.watch(transactionsProvider);
    final recentTransactions = transactions.take(5).toList(); // Show last 5 transactions

    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor: isDarkMode ? CupertinoColors.black : CupertinoColors.white,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 16),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // Header (Profile, Month selector, etc.)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode
                                    ? CupertinoColors.systemGrey6.darkColor
                                    : CupertinoColors.systemGrey6,
                              ),
                              child: const Icon(CupertinoIcons.person),
                            ),
                            HapticFeedbackWrapper(
                              onPressed: _showMonthPicker,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? CupertinoColors.systemGrey6.darkColor
                                      : CupertinoColors.systemGrey6,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getMonthName(selectedMonth),
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? CupertinoColors.white
                                            : CupertinoColors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      CupertinoIcons.chevron_down,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Icon(CupertinoIcons.bell_fill),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Account Balance - Centered and with dynamic currency
                        Column(
                          children: [
                            Text(
                              'Account Balance',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDarkMode
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.systemGrey2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${getCurrencySymbol(currentCurrency)}9,400',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Income & Expenses
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGreen,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.arrow_down,
                                        color: CupertinoColors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Income',
                                          style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${getCurrencySymbol(currentCurrency)}5,000',
                                          style: const TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemRed,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.arrow_up,
                                        color: CupertinoColors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Expenses',
                                          style: TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '${getCurrencySymbol(currentCurrency)}1,200',
                                          style: const TextStyle(
                                            color: CupertinoColors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Spend Frequency
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Spend Frequency',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildTimeFilter('Today', true),
                                  const SizedBox(width: 8),
                                  _buildTimeFilter('Week', false),
                                  const SizedBox(width: 8),
                                  _buildTimeFilter('Month', false),
                                  const SizedBox(width: 8),
                                  _buildTimeFilter('Year', false),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Chart
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    FlSpot(0, 3),
                                    FlSpot(2.6, 2),
                                    FlSpot(4.9, 5),
                                    FlSpot(6.8, 3.1),
                                    FlSpot(8, 4),
                                    FlSpot(9.5, 3),
                                    FlSpot(11, 4),
                                  ],
                                  isCurved: true,
                                  color: CupertinoColors.systemPurple,
                                  barWidth: 3,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: CupertinoColors.systemPurple.withOpacity(0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Recent Transactions Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transaction',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Text('See All'),
                              onPressed: () {
                                // Navigate to transactions
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Transactions List
              SliverPadding(
                padding: EdgeInsets.zero,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return TransactionListItem(
                        transaction: recentTransactions[index],
                      );
                    },
                    childCount: recentTransactions.length,
                  ),
                ),
              ),
              // Add some bottom padding
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilter(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? CupertinoColors.systemYellow
            : CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color:
              isSelected ? CupertinoColors.black : CupertinoColors.systemGrey,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
