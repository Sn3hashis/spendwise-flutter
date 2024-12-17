import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:lottie/lottie.dart';

class SecuritySelectorScreen extends ConsumerWidget {
  final String selectedOption;
  
  const SecuritySelectorScreen({
    super.key,
    required this.selectedOption,
  });

  static const List<(IconData, String, String)> options = [
    (CupertinoIcons.tag_circle, 'Biometric', 'Use fingerprint or face ID'),
    (CupertinoIcons.lock_fill, 'PIN', 'Use 6-digit PIN code'),
    (CupertinoIcons.lock_slash_fill, 'None', 'No security'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: const Text('Security'),
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
                  ),
                  child: Lottie.asset(
                    'assets/animations/security.json',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final (icon, option, description) = options[index];
                  final isSelected = option == selectedOption;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.pop(context, option);
                      },
                      child: Container(
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
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF3B30).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                color: const Color(0xFFFF3B30),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode 
                                          ? AppTheme.textPrimaryDark 
                                          : AppTheme.textPrimaryLight,
                                    ),
                                  ),
                                  Text(
                                    description,
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
                                color: const Color(0xFFFF3B30),
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 