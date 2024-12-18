import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../transactions/models/transaction_model.dart';
import 'package:flutter/material.dart' show DateTimeRange;
class TrendChart extends StatelessWidget {
  final List<Transaction> transactions;
  final String period;
  final DateTimeRange? dateRange;
  final Key? chartKey;

  const TrendChart({
    super.key,
    required this.transactions,
    required this.period,
    this.dateRange,
    this.chartKey,
  });

  List<FlSpot> _getSpots() {
    final Map<DateTime, double> dailyTotals = {};
    final filteredTransactions = _getFilteredTransactions();

    for (var transaction in filteredTransactions) {
      final date = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      dailyTotals[date] = (dailyTotals[date] ?? 0) + transaction.amount;
    }

    final sortedDates = dailyTotals.keys.toList()..sort();
    return sortedDates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), dailyTotals[entry.value]!);
    }).toList();
  }

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

  @override
  Widget build(BuildContext context) {
    final spots = _getSpots();
    if (spots.isEmpty) {
      return const Center(
        child: Text('No data available for selected period'),
      );
    }

    return RepaintBoundary(
      key: chartKey,
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      NumberFormat.compact().format(value),
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(
                      DateFormat('MMM d').format(date),
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: CupertinoColors.activeBlue,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: CupertinoColors.activeBlue.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 