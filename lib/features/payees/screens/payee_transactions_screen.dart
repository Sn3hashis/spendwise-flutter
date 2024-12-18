import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/date_helper.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transactions_provider.dart';
import '../../transactions/screens/transaction_details_screen.dart';
import '../models/payee_model.dart';

class PayeeTransactionsScreen extends ConsumerWidget {
  final Payee payee;
  final String currencySymbol = '₹';

  const PayeeTransactionsScreen({
    super.key,
    required this.payee,
  });

  Widget _buildTransactionItem(BuildContext context, Transaction transaction, bool isDarkMode) {
    final isExpense = transaction.amount < 0;

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
            // Category Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: transaction.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                transaction.category.icon,
                color: transaction.category.color,
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
                        ? transaction.category.name 
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final allTransactions = ref.watch(transactionsProvider);
    
    // Filter transactions for this payee
    final payeeTransactions = allTransactions
        .where((transaction) => transaction.payeeId == payee.id)
        .toList();
    
    // Calculate total amount
    final totalAmount = payeeTransactions.fold<double>(
      0, 
      (sum, transaction) => sum + transaction.amount
    );

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: Text(payee.name),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Summary Card
            Container(
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
                    'Total Balance',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$currencySymbol${totalAmount.abs()}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: totalAmount < 0
                          ? CupertinoColors.destructiveRed
                          : CupertinoColors.systemGreen,
                    ),
                  ),
                  Text(
                    totalAmount < 0 ? 'You owe' : 'Owes you',
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
            // Transactions List
            Expanded(
              child: payeeTransactions.isEmpty
                  ? Center(
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
                    )
                  : ListView.builder(
                      itemCount: payeeTransactions.length,
                      itemBuilder: (context, index) => _buildTransactionItem(
                        context,
                        payeeTransactions[index],
                        isDarkMode,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 