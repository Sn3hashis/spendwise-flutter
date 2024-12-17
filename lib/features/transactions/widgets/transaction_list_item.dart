import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_helper.dart';

class TransactionListItem extends StatelessWidget {
  final String title;
  final String description;
  final double amount;
  final String time;
  final IconData icon;
  final Color iconBackgroundColor;
  final bool isDarkMode;
  final String currencyCode;

  const TransactionListItem({
    super.key,
    required this.title,
    required this.description,
    required this.amount,
    required this.time,
    required this.icon,
    required this.iconBackgroundColor,
    required this.isDarkMode,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackgroundColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconBackgroundColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  ),
                ),
                Text(
                  description,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${amount < 0 ? "- " : "+ "}${getCurrencySymbol(currencyCode)}${amount.abs()}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: amount < 0 
                      ? CupertinoColors.systemRed 
                      : CupertinoColors.systemGreen,
                ),
              ),
              Text(
                time,
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
    );
  }
} 