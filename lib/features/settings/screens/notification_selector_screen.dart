import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, ThemeData, Brightness;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';

class NotificationSelectorScreen extends ConsumerWidget {
  final String selectedOption;
  
  const NotificationSelectorScreen({
    super.key,
    required this.selectedOption,
  });

  static const List<(IconData, String, String)> options = [
    (CupertinoIcons.bell_fill, 'On', 'Enable notifications'),
    (CupertinoIcons.bell_slash_fill, 'Off', 'Disable notifications'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: const Text('Notifications'),
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
                    'assets/animations/notification.json',
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
                    child: HapticFeedbackWrapper(
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
                                color: const Color(0xFFFF9500).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                color: const Color(0xFFFF9500),
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
                                color: const Color(0xFFFF9500),
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