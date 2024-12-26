import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import '../../home/screens/home_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../budget/screens/budget_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/exit_dialog.dart';
import '../../transactions/screens/expense_screen.dart';
import '../../transactions/screens/income_screen.dart';
import '../../transactions/screens/transfer_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isSubMenuOpen = false;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionsScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  final List<TabItem> items = [
    const TabItem(
      icon: CupertinoIcons.house_fill,
      title: 'Home',
    ),
    const TabItem(
      icon: CupertinoIcons.arrow_right_arrow_left,
      title: 'Transactions',
    ),
    const TabItem(
      icon: Icons.add,
      title: '',
    ),
    const TabItem(
      icon: CupertinoIcons.chart_bar_fill,
      title: 'Budget',
    ),
    const TabItem(
      icon: CupertinoIcons.person_fill,
      title: 'Profile',
    ),
  ];

  Future<bool> _onWillPop() async {
    if (!mounted) return false;

    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }

    final shouldPop = await ExitDialog.show(context);
    if (shouldPop ?? false) {
      SystemNavigator.pop();
      return true;
    }
    return false;
  }

  void _toggleSubMenu() {
    setState(() {
      _isSubMenuOpen = !_isSubMenuOpen;
    });
    if (_isSubMenuOpen) {
      _rotationController.forward();
    } else {
      _rotationController.reverse();
    }
    HapticFeedback.mediumImpact();
  }

  void _handleAddAction(BuildContext context, String type) {
    _toggleSubMenu();
    switch (type) {
      case 'expense':
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const ExpenseScreen(),
          ),
        );
        break;
      case 'income':
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const IncomeScreen(),
          ),
        );
        break;
      case 'transfer':
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const TransferScreen(),
          ),
        );
        break;
    }
  }

  void _handleNavigation(int index) {
    if (_isSubMenuOpen && index != 2) {
      _toggleSubMenu();
    }

    if (index == 2) {
      _toggleSubMenu();
    } else if (index > 2) {
      setState(() {
        _currentIndex = index - 1;
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildSubMenu(bool isDarkMode) {
    if (!_isSubMenuOpen) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: 90,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSubMenuItem(
                icon: CupertinoIcons.minus_circle,
                label: 'Expense',
                color: CupertinoColors.systemRed,
                onTap: () => _handleAddAction(context, 'expense'),
              ),
              _buildSubMenuItem(
                icon: CupertinoIcons.plus_circle,
                label: 'Income',
                color: CupertinoColors.systemGreen,
                onTap: () => _handleAddAction(context, 'income'),
              ),
              _buildSubMenuItem(
                icon: CupertinoIcons.arrow_right_arrow_left_circle,
                label: 'Transfer',
                color: CupertinoColors.systemBlue,
                onTap: () => _handleAddAction(context, 'transfer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.25, // 1/4 turn (90 degrees)
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Material(
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;
          if (_isSubMenuOpen) {
            _toggleSubMenu();
            return;
          }
          final shouldPop = await _onWillPop();
        },
        child: CupertinoPageScaffold(
          backgroundColor:
              isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          child: Stack(
            children: [
              _screens[_currentIndex],
              if (_isSubMenuOpen) _buildSubMenu(isDarkMode),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppTheme.bottomNavBarDark
                        : AppTheme.bottomNavBarLight,
                    border: Border(
                      top: BorderSide(
                        color: isDarkMode
                            ? const Color(0xFF2C2C2E).withOpacity(0.5)
                            : const Color(0xFFE5E5EA).withOpacity(0.5),
                        width: 0.3,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(
                            icon: CupertinoIcons.house,
                            selectedIcon: CupertinoIcons.house_fill,
                            label: 'Home',
                            index: 0,
                          ),
                          _buildNavItem(
                            icon: CupertinoIcons.arrow_right_arrow_left,
                            selectedIcon: CupertinoIcons.arrow_right_arrow_left,
                            label: 'Transactions',
                            index: 1,
                          ),
                          _buildCenterButton(),
                          _buildNavItem(
                            icon: CupertinoIcons.chart_bar,
                            selectedIcon: CupertinoIcons.chart_bar_fill,
                            label: 'Budget',
                            index: 3,
                          ),
                          _buildNavItem(
                            icon: CupertinoIcons.person,
                            selectedIcon: CupertinoIcons.person_fill,
                            label: 'Profile',
                            index: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isDarkMode = ref.watch(themeProvider);
    final isSelected =
        index > 2 ? _currentIndex == index - 1 : _currentIndex == index;

    return GestureDetector(
      onTap: () {
        _handleNavigation(index);
        HapticFeedback.selectionClick();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        height: 50,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 28,
              color: isSelected
                  ? CupertinoColors.activeBlue
                  : (isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black),
            ),
            if (isSelected) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: CupertinoColors.activeBlue,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    final isDarkMode = ref.watch(themeProvider);

    return GestureDetector(
      onTap: _toggleSubMenu,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: CupertinoColors.activeBlue,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDarkMode
                ? const Color(0xFF2C2C2E).withOpacity(0.5)
                : const Color(0xFFE5E5EA).withOpacity(0.5),
            width: 0.3,
          ),
        ),
        child: AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Icon(
                CupertinoIcons.add,
                color: CupertinoColors.white,
                size: 22,
              ),
            );
          },
        ),
      ),
    );
  }
}
