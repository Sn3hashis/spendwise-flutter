import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/currency_provider.dart';
import '../models/transaction_model.dart';
import '../screens/transaction_details_screen.dart';

class TransactionListItem extends ConsumerWidget {
  final Transaction transaction;

  const TransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currentCurrency = ref.watch(currencyProvider).code;

    // Format amount with current currency symbol
    final amountText = transaction.amount < 0 
        ? '- ${getCurrencySymbol(currentCurrency)}${transaction.amount.abs().toStringAsFixed(2)}'
        : '+ ${getCurrencySymbol(currentCurrency)}${transaction.amount.abs().toStringAsFixed(2)}';

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => TransactionDetailsScreen(
              transaction: transaction.copyWith(
                currencyCode: currentCurrency,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: transaction.category.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                transaction.category.icon,
                color: transaction.category.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                    ),
                  ),
                  Text(
                    _getDescription(),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: transaction.amount < 0 
                        ? CupertinoColors.systemRed 
                        : CupertinoColors.systemGreen,
                  ),
                ),
                Text(
                  _formatDate(transaction.date),
                  style: TextStyle(
                    fontSize: 15,
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
  }

  String _getDescription() {
    if (transaction.description.isNotEmpty) {
      return transaction.description;
    }
    return transaction.category.description;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return DateFormat('HH:mm').format(date);
    } else {
      return DateFormat('dd MMM HH:mm').format(date);
    }
  }
} 