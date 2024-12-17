import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';

class SecuritySelector extends StatelessWidget {
  final String selectedOption;
  
  const SecuritySelector({
    super.key,
    this.selectedOption = 'Biometric',
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final options = [
      (CupertinoIcons.tag_circle, 'Biometric', 'Use fingerprint or face ID'),
      (CupertinoIcons.lock_fill, 'PIN', 'Use 6-digit PIN code'),
      (CupertinoIcons.lock_slash_fill, 'None', 'No security'),
    ];

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: const Text('Security'),
        border: null,
      ),
      child: SafeArea(
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
    );
  }
} 