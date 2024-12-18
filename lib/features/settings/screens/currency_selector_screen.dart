import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/models/currency_model.dart';

class CurrencySelectorScreen extends ConsumerWidget {
  final String selectedCurrency;
  
  const CurrencySelectorScreen({
    super.key,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currencies = Currency.currencies;

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
                    brightness: isDarkMode ? Brightness.dark : Brightness.light,
                    colorScheme: isDarkMode 
                        ? const ColorScheme.dark(primary: CupertinoColors.white)
                        : const ColorScheme.light(),
                  ),
                  child: Lottie.asset(
                    'assets/animations/currency.json',
                    height: 200,
                    width: 200,
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
                        final currency = currencies[index];
                        final isSelected = currency.code == selectedCurrency;
                        return HapticFeedbackWrapper(
                          onPressed: () async {
                            await ref.read(currencyProvider.notifier).setCurrency(currency.code);
                            Navigator.pop(context, currency.code);
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
                                      currency.symbol,
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
                                        currency.code,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: isDarkMode 
                                              ? AppTheme.textPrimaryDark 
                                              : AppTheme.textPrimaryLight,
                                        ),
                                      ),
                                      Text(
                                        currency.name,
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
                                  const Icon(
                                    CupertinoIcons.checkmark_alt,
                                    color: Color(0xFF007AFF),
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