import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../../categories/screens/categories_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../payees/screens/manage_payees_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: SafeArea(
        child: ListView(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1C1C1E) : CupertinoColors.white,
                borderRadius: BorderRadius.circular(16),
                border: isDarkMode 
                    ? null 
                    : Border.all(color: const Color(0xFFE5E5EA)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: isDarkMode ? CupertinoColors.white : const Color(0xFFF2F2F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: 32,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : const Color(0xFF8E8E93),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Iriana Saliha',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode 
                                ? AppTheme.textPrimaryDark 
                                : AppTheme.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'iriana.saliha@example.com',
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
                ],
              ),
            ),
            
            // Menu Items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    context: context,
                    ref: ref,
                    icon: CupertinoIcons.creditcard,
                    iconColor: AppTheme.iconColors['account']!,
                    title: 'Account',
                    isDarkMode: isDarkMode,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context: context,
                    ref: ref,
                    icon: CupertinoIcons.settings,
                    iconColor: AppTheme.iconColors['settings']!,
                    title: 'Settings',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    ref: ref,
                    icon: CupertinoIcons.arrow_down_doc,
                    iconColor: AppTheme.iconColors['export']!,
                    title: 'Export Data',
                    isDarkMode: isDarkMode,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context: context,
                    ref: ref,
                    icon: CupertinoIcons.tag,
                    iconColor: AppTheme.iconColors['category']!,
                    title: 'Manage Category',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const CategoriesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    ref: ref,
                    icon: CupertinoIcons.person_2,
                    iconColor: AppTheme.iconColors['payees']!,
                    title: 'Manage Payees',
                    isDarkMode: isDarkMode,
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const ManagePayeesScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    ref: ref,
                    icon: CupertinoIcons.money_dollar,
                    iconColor: AppTheme.iconColors['lend']!,
                    title: 'Lend Management',
                    isDarkMode: isDarkMode,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context: context,
                    ref: ref,
                    icon: CupertinoIcons.arrow_right_circle,
                    iconColor: AppTheme.iconColors['logout']!,
                    title: 'Logout',
                    isDarkMode: isDarkMode,
                    showDivider: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDarkMode,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await HapticService.lightImpact(ref);
            onTap();
          },
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
        if (showDivider) const SizedBox(height: 8),
      ],
    );
  }
}
