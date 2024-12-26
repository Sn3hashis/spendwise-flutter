import 'package:flutter/cupertino.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bottom_navbar_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../services/haptic_service.dart';


class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavProvider);
    final isDarkMode = ref.watch(themeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        border: Border(
          top: BorderSide(
            color:
                isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8), // Increase vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: CupertinoIcons.home,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => _onItemTapped(0, ref),
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: CupertinoIcons.chart_bar_square,
                label: 'Transactions',
                isSelected: selectedIndex == 1,
                onTap: () => _onItemTapped(1, ref),
                isDarkMode: isDarkMode,
              ),
              _buildNavItem(
                icon: CupertinoIcons.person,
                label: 'Profile',
                isSelected: selectedIndex == 2,
                onTap: () => _onItemTapped(2, ref),
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero, // Remove default padding
      minSize: 0, // Remove minimum size constraint
      child: Container(
        width: 80, // Increase width
        height: 56, // Increase height
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? CupertinoColors.systemPurple
                  : (isDarkMode
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey2),
              size: 24, // Slightly increase icon size
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? CupertinoColors.systemPurple
                    : (isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey2),
              ),
            ),
          ],
        ),
      ),
      onPressed: onTap,
    );
  }

  void _onItemTapped(int index, WidgetRef ref) async {
    await HapticService.lightImpact(ref);
    ref.read(bottomNavProvider.notifier).state = index;
  }


}

