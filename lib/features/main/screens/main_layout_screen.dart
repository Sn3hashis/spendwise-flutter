import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/screens/home_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../transactions/screens/expense_screen.dart';
import '../../transactions/screens/transfer_screen.dart';
import '../../budget/screens/budget_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../transactions/screens/income_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/exit_dialog.dart';

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

  void _showAddTransactionMenu() async {
    await HapticService.lightImpact(ref);
    if (!mounted) return;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        final isDarkMode = ref.watch(themeProvider);
        
        return CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                await HapticService.lightImpact(ref);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const IncomeScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.arrow_down_circle_fill,
                    color: const Color(0xFF00C853),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Income',
                    style: TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                await HapticService.lightImpact(ref);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const ExpenseScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.arrow_up_circle_fill,
                    color: const Color(0xFFFF3B30),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Expense',
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                await HapticService.lightImpact(ref);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const TransferScreen(),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.arrow_right_arrow_left_circle_fill,
                    color: const Color(0xFF007AFF),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Transfer',
                    style: TextStyle(
                      color: Color(0xFF007AFF),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () async {
              await HapticService.lightImpact(ref);
              Navigator.pop(context);
            },
            isDestructiveAction: true,
            child: const Text('Cancel'),
          ),
        );
      },
    ).whenComplete(() {
      _animationController.reverse();
    });
  }

  Future<bool> _onWillPop() async {
    if (!mounted) return false;
    
    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = 0;
        _pageController.jumpToPage(0);
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        final shouldPop = await _onWillPop();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        ),
        child: CupertinoPageScaffold(
          backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index >= 2 ? index + 1 : index;
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
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        HapticFeedbackWrapper(
                          onPressed: () => onItemTapped(0),
                          child: _buildNavItem(0, navItems[0].icon, navItems[0].label),
                        ),
                        HapticFeedbackWrapper(
                          onPressed: () => onItemTapped(1),
                          child: _buildNavItem(1, navItems[1].icon, navItems[1].label),
                        ),
                        SizedBox(width: 40),
                        HapticFeedbackWrapper(
                          onPressed: () => onItemTapped(3),
                          child: _buildNavItem(3, navItems[3].icon, navItems[3].label),
                        ),
                        HapticFeedbackWrapper(
                          onPressed: () => onItemTapped(4),
                          child: _buildNavItem(4, navItems[4].icon, navItems[4].label),
                        ),
                      ],
                    ),
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
                    child: HapticFeedbackWrapper(
                      onPressed: () {
                        _animationController.forward();
                        _showAddTransactionMenu();
                      },
                      child: RawMaterialButton(
                        onPressed: () {
                          _animationController.forward();
                          _showAddTransactionMenu();
                        },
                        elevation: 0,
                        fillColor: CupertinoColors.activeBlue,
                        shape: const CircleBorder(),
                        child: RotationTransition(
                          turns: _animation,
                          child: const Icon(
                            CupertinoIcons.add,
                            color: CupertinoColors.white,
                            size: 28,
                          ),
                        ),
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
    return SizedBox(
      height: 65,
      width: 65,
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
              fontSize: 10,
              color: isSelected 
                  ? CupertinoColors.systemBlue 
                  : CupertinoColors.systemGrey,
            ),
            maxLines: 1,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
          ),
        ],
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
