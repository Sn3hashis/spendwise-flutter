import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import '../../transactions/models/transaction_model.dart';

class FinancialOverview extends StatelessWidget {
  final List<Transaction> transactions;
  final String period;
  final DateTimeRange? dateRange;
  final Key? chartKey;

  const FinancialOverview({
    super.key,
    required this.transactions,
    required this.period,
    this.dateRange,
    this.chartKey,
  });

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _getFilteredTransactions();
    final totalIncome = filteredTransactions
        .where((t) => t.amount > 0)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = filteredTransactions
        .where((t) => t.amount < 0)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
    final balance = totalIncome - totalExpense;

    return RepaintBoundary(
      key: chartKey,
      child: Column(
        children: [
          _buildOverviewCard(
            'Total Income',
            totalIncome,
            CupertinoColors.systemGreen,
            CupertinoIcons.arrow_down_circle_fill,
          ),
          const SizedBox(height: 12),
          _buildOverviewCard(
            'Total Expense',
            totalExpense,
            CupertinoColors.systemRed,
            CupertinoIcons.arrow_up_circle_fill,
          ),
          const SizedBox(height: 12),
          _buildOverviewCard(
            'Net Balance',
            balance,
            balance >= 0 ? CupertinoColors.systemBlue : CupertinoColors.systemRed,
            CupertinoIcons.money_dollar_circle_fill,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${amount.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
} 