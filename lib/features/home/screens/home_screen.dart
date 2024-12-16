import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor:
            isDarkMode ? CupertinoColors.black : CupertinoColors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                    CupertinoButton(
                      padding: EdgeInsets.zero,
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
                          children: [
                            Text(
                              'October',
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
                      onPressed: () {
                        // Show month picker
                      },
                    ),
                    const Icon(CupertinoIcons.bell_fill),
                  ],
                ),
                const SizedBox(height: 24),
                // Account Balance
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
                  '\$9,400',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
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
                              children: const [
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '\$5,000',
                                  style: TextStyle(
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
                              children: const [
                                Text(
                                  'Expenses',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '\$1,200',
                                  style: TextStyle(
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
                            const FlSpot(0, 3),
                            const FlSpot(2.6, 2),
                            const FlSpot(4.9, 5),
                            const FlSpot(6.8, 2.5),
                            const FlSpot(8, 4),
                            const FlSpot(9.5, 3),
                            const FlSpot(11, 4),
                          ],
                          isCurved: true,
                          color: CupertinoColors.systemPurple,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color:
                                CupertinoColors.systemPurple.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Recent Transactions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Recent Transaction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
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
                const SizedBox(height: 16),
                _buildTransactionItem(
                  icon: CupertinoIcons.shopping_cart,
                  color: CupertinoColors.systemOrange,
                  title: 'Shopping',
                  subtitle: 'Buy some grocery',
                  amount: '-\$120',
                  time: '10:00 AM',
                  isDarkMode: isDarkMode,
                ),
                _buildTransactionItem(
                  icon: CupertinoIcons.play_circle,
                  color: CupertinoColors.systemPurple,
                  title: 'Subscription',
                  subtitle: 'Disney+ Annual..',
                  amount: '-\$80',
                  time: '03:30 PM',
                  isDarkMode: isDarkMode,
                ),
                _buildTransactionItem(
                  icon: CupertinoIcons.cart,
                  color: CupertinoColors.systemPink,
                  title: 'Food',
                  subtitle: 'Buy a ramen',
                  amount: '-\$32',
                  time: '07:30 PM',
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
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

  Widget _buildTransactionItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String amount,
    required String time,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
