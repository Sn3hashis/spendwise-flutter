import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget_model.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class BudgetTransactionsScreen extends ConsumerWidget {
  final Budget budget;

  const BudgetTransactionsScreen({
    super.key,
    required this.budget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider)
      .where((t) => 
        t.category.id == budget.category.id && // Match by category
        budget.isDateInPeriod(t.date) &&
        t.type == TransactionType.expense)
      .toList();
    final isDarkMode = ref.watch(themeProvider);
    final currency = ref.watch(currencyProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: Text('${budget.category.name} Transactions'),
      ),
      child: SafeArea(
        child: transactions.isEmpty
          ? Center(
              child: Text(
                'No transactions yet',
                style: TextStyle(
                  color: isDarkMode 
                    ? CupertinoColors.systemGrey 
                    : CupertinoColors.systemGrey2,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                    borderRadius: BorderRadius.circular(16),
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
                                fontWeight: FontWeight.w600,
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
                        '${currency.symbol}${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: transaction.type == TransactionType.expense
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
    );
  }
} 