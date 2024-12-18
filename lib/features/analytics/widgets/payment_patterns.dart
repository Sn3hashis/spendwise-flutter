import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../transactions/models/transaction_model.dart';

class PaymentPatterns extends StatelessWidget {
  final List<Transaction> transactions;
  final String period;
  final DateTimeRange? dateRange;
  final Key? chartKey;

  const PaymentPatterns({
    super.key,
    required this.transactions,
    required this.period,
    this.dateRange,
    this.chartKey,
  });

  List<Transaction> _getFilteredTransactions() {
    final now = DateTime.now();
    
    return transactions.where((transaction) {
      if (dateRange != null) {
        return transaction.date.isAfter(dateRange!.start) && 
               transaction.date.isBefore(dateRange!.end);
      }

      switch (period) {
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

  Map<String, List<Transaction>> _getWeekdayTransactions() {
    final filteredTransactions = _getFilteredTransactions();
    final weekdayMap = <String, List<Transaction>>{};
    
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (var weekday in weekdays) {
      weekdayMap[weekday] = [];
    }

    for (var transaction in filteredTransactions) {
      final weekday = weekdays[transaction.date.weekday - 1];
      weekdayMap[weekday]!.add(transaction);
    }

    return weekdayMap;
  }

  @override
  Widget build(BuildContext context) {
    final weekdayData = _getWeekdayTransactions();
    final maxAmount = weekdayData.values.fold<double>(0, (max, transactions) {
      final total = transactions.fold<double>(0, (sum, t) => sum + t.amount.abs());
      return total > max ? total : max;
    });

    if (weekdayData.isEmpty) {
      return const Center(
        child: Text('No data available for selected period'),
      );
    }

    return RepaintBoundary(
      key: chartKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxAmount * 1.2,
                  barGroups: weekdayData.entries.map((entry) {
                    final total = entry.value.fold<double>(
                      0, (sum, t) => sum + t.amount.abs()
                    );
                    
                    return BarChartGroupData(
                      x: weekdayData.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: total,
                          color: CupertinoColors.activeBlue,
                          width: 14,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxAmount * 1.2,
                            color: CupertinoColors.systemGrey5,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              '₹${NumberFormat.compact().format(value)}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            weekdayData.keys.toList()[value.toInt()],
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildStat(
                    'Most Active Day',
                    weekdayData.entries
                        .reduce((a, b) => 
                          a.value.length > b.value.length ? a : b)
                        .key,
                    CupertinoColors.activeBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStat(
                    'Highest Spending',
                    weekdayData.entries
                        .reduce((a, b) {
                          final aTotal = a.value.fold<double>(0, (sum, t) => sum + t.amount.abs());
                          final bTotal = b.value.fold<double>(0, (sum, t) => sum + t.amount.abs());
                          return aTotal > bTotal ? a : b;
                        })
                        .key,
                    CupertinoColors.systemGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 