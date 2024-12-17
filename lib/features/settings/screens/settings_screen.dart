import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import 'currency_selector_screen.dart';
import 'language_selector_screen.dart';
import 'theme_selector_screen.dart';
import 'haptics_selector_screen.dart';
import 'security_selector_screen.dart';
import 'notification_selector_screen.dart';
import '../providers/settings_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import '../../categories/screens/categories_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDarkMode = ref.watch(currentThemeProvider);

    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor: isDarkMode ? CupertinoColors.black : CupertinoColors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
                color: isDarkMode ? CupertinoColors.black : CupertinoColors.white,
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      child: Icon(
                        CupertinoIcons.back,
                        color: isDarkMode 
                            ? CupertinoColors.white 
                            : CupertinoColors.black,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode 
                              ? CupertinoColors.white 
                              : CupertinoColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Lottie.asset(
                          'assets/animations/settings.json',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            _buildSettingsItem(
                              context: context,
                              icon: CupertinoIcons.money_dollar_circle_fill,
                              iconColor: const Color(0xFF34C759),
                              title: 'Currency',
                              value: settings.currency,
                              isDarkMode: isDarkMode,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => CurrencySelectorScreen(
                                      selectedCurrency: settings.currency,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  await ref.read(settingsProvider.notifier).updateCurrency(result);
                                }
                              },
                            ),
                            _buildSettingsItem(
                              context: context,
                              icon: CupertinoIcons.globe,
                              iconColor: const Color(0xFF007AFF),
                              title: 'Language',
                              value: settings.language,
                              isDarkMode: isDarkMode,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => LanguageSelectorScreen(
                                      selectedLanguage: settings.language,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  await ref.read(settingsProvider.notifier).updateLanguage(result);
                                }
                              },
                            ),
                            _buildSettingsItem(
                              context: context,
                              icon: CupertinoIcons.moon_fill,
                              iconColor: const Color(0xFF9B59B6),
                              title: 'Theme',
                              value: settings.theme,
                              isDarkMode: isDarkMode,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => ThemeSelector(
                                      selectedTheme: settings.theme,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  await ref.read(settingsProvider.notifier).updateTheme(result);
                                }
                              },
                            ),
                            _buildSettingsItem(
                              context: context,
                              icon: CupertinoIcons.hand_raised_fill,
                              iconColor: const Color(0xFFFF9500),
                              title: 'Haptics',
                              value: settings.haptics,
                              isDarkMode: isDarkMode,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => HapticsSelectorScreen(
                                      selectedOption: settings.haptics,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  await ref.read(settingsProvider.notifier).updateHaptics(result);
                                }
                              },
                            ),
                            _buildSettingsItem(
                              context: context,
                              icon: CupertinoIcons.shield_fill,
                              iconColor: const Color(0xFFFF3B30),
                              title: 'Security',
                              value: settings.security,
                              isDarkMode: isDarkMode,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => SecuritySelectorScreen(
                                      selectedOption: settings.security,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  await ref.read(settingsProvider.notifier).updateSecurity(result);
                                }
                              },
                            ),
                            _buildSettingsItem(
                              context: context,
                              icon: CupertinoIcons.bell_fill,
                              iconColor: const Color(0xFFFF9500),
                              title: 'Notification',
                              value: settings.notifications,
                              isDarkMode: isDarkMode,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => NotificationSelectorScreen(
                                      selectedOption: settings.notifications,
                                    ),
                                  ),
                                );
                                if (result != null) {
                                  await ref.read(settingsProvider.notifier).updateNotifications(result);
                                }
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSettingsItem(
                              context: context,
                              icon: CupertinoIcons.info_circle_fill,
                              iconColor: const Color(0xFF8E8E93),
                              title: 'About',
                              isDarkMode: isDarkMode,
                              onTap: () {},
                            ),
                            _buildSettingsItem(
                              context: context,
                              icon: CupertinoIcons.question_circle_fill,
                              iconColor: const Color(0xFF8E8E93),
                              title: 'Help',
                              isDarkMode: isDarkMode,
                              onTap: () {},
                            ),
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? value,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    color: isDarkMode 
                        ? AppTheme.textPrimaryDark 
                        : AppTheme.textPrimaryLight,
                  ),
                ),
              ),
              if (value != null) ...[
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    color: isDarkMode 
                        ? AppTheme.textSecondaryDark 
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Icon(
                CupertinoIcons.chevron_forward,
                color: isDarkMode 
                    ? AppTheme.textSecondaryDark 
                    : AppTheme.textSecondaryLight,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 