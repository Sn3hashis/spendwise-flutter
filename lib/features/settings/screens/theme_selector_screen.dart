import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../features/settings/providers/settings_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart' show Theme, ThemeData;

class ThemeSelector extends ConsumerWidget {
  final String selectedTheme;
  
  const ThemeSelector({
    super.key,
    this.selectedTheme = 'System',
  });

  static const List<(IconData, String, String)> themes = [
    (CupertinoIcons.sun_max_fill, 'Light', 'Light theme'),
    (CupertinoIcons.moon_fill, 'Dark', 'Dark theme'),
    (CupertinoIcons.gear_alt_fill, 'System', 'Follow system settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: const Text('Theme'),
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
                    'assets/animations/theme.json',
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
                itemCount: themes.length,
                itemBuilder: (context, index) {
                  final (icon, theme, description) = themes[index];
                  final isSelected = theme == selectedTheme;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        await ref.read(settingsProvider.notifier).updateTheme(theme);
                        if (context.mounted) {
                          Navigator.pop(context, theme);
                        }
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
                                color: const Color(0xFF9B59B6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                icon,
                                color: const Color(0xFF9B59B6),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    theme,
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
                                color: const Color(0xFF9B59B6),
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