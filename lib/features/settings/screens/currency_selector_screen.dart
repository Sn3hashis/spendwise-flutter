import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';

class CurrencySelectorScreen extends StatelessWidget {
  final String selectedCurrency;
  
  const CurrencySelectorScreen({
    super.key,
    this.selectedCurrency = 'USD',  // Default selected currency
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final currencies = [
      ('\$', 'USD', 'US Dollar'),
      ('€', 'EUR', 'Euro'),
      ('£', 'GBP', 'British Pound'),
      ('¥', 'JPY', 'Japanese Yen'),
      ('₹', 'INR', 'Indian Rupee'),
      // Add more currencies as needed
    ];

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: const Text('Currency'),
        border: null,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Theme(
                  data: ThemeData(
                    brightness: isDarkMode ? Brightness.light : Brightness.dark,
                  ),
                  child: Lottie.asset(
                    'assets/animations/currency.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.systemGrey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Select Currency',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: ListView.builder(
                      itemCount: currencies.length,
                      itemBuilder: (context, index) {
                        final (symbol, code, name) = currencies[index];
                        final isSelected = code == selectedCurrency;
                        return CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pop(context, code);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemGrey6,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      symbol,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        code,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode 
                                              ? AppTheme.textPrimaryDark 
                                              : AppTheme.textPrimaryLight,
                                        ),
                                      ),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode 
                                              ? AppTheme.textSecondaryDark 
                                              : AppTheme.textSecondaryLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: const Color(0xFF007AFF),
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 