import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/screens/home_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../budget/screens/budget_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:flutter/services.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> 
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<({IconData icon, String label})> navItems = [
    (icon: CupertinoIcons.house_fill, label: 'Home'),
    (icon: CupertinoIcons.arrow_right_arrow_left, label: 'Transactions'),
    (icon: CupertinoIcons.add, label: ''),
    (icon: CupertinoIcons.chart_bar_fill, label: 'Budget'),
    (icon: CupertinoIcons.person_fill, label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0.5).animate(_animationController);
  }

  void onItemTapped(int index) {
    if (index == 2) {
      _showAddTransactionMenu();
      return;
    }
    setState(() {
      _currentIndex = index;
      final pageIndex = index > 2 ? index - 1 : index;
      _pageController.jumpToPage(pageIndex);
    });
  }

  void _showAddTransactionMenu() {
    _animationController.forward();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle Income
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.arrow_down_circle_fill,
                  color: CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 8),
                const Text('Income'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle Expense
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.arrow_up_circle_fill,
                  color: CupertinoColors.systemRed,
                ),
                const SizedBox(width: 8),
                const Text('Expense'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Handle Transfer
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.arrow_right_arrow_left_circle_fill,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(width: 8),
                const Text('Transfer'),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    ).whenComplete(() {
      _animationController.reverse();
    });
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
        _pageController.jumpToPage(0);
      });
      return false;
    }

    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: CupertinoPageScaffold(
          backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index > 1 ? index + 1 : index;
                  });
                },
                children: const [
                  HomeScreen(),
                  TransactionsScreen(),
                  BudgetScreen(),
                  ProfileScreen(),
                ],
              ),
              
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 65,
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppTheme.bottomNavBarDark : AppTheme.bottomNavBarLight,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDarkMode 
                          ? AppTheme.bottomNavBarBorderDark 
                          : AppTheme.bottomNavBarBorderLight,
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode 
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, navItems[0].icon, navItems[0].label),
                      _buildNavItem(1, navItems[1].icon, navItems[1].label),
                      const SizedBox(width: 56),
                      _buildNavItem(3, navItems[3].icon, navItems[3].label),
                      _buildNavItem(4, navItems[4].icon, navItems[4].label),
                    ],
                  ),
                ),
              ),
              
              Positioned(
                left: 0,
                right: 0,
                bottom: 44,
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.activeBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: RawMaterialButton(
                      onPressed: () => _showAddTransactionMenu(),
                      elevation: 0,
                      fillColor: CupertinoColors.activeBlue,
                      shape: const CircleBorder(),
                      child: const Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.white,
                        size: 28,
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

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? CupertinoColors.systemBlue 
                  : CupertinoColors.systemGrey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected 
                    ? CupertinoColors.systemBlue 
                    : CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
