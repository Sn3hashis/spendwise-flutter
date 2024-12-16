import 'package:flutter/cupertino.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../../home/screens/home_screen.dart';
import '../../transactions/screens/transactions_screen.dart';
import '../../budget/screens/budget_screen.dart';
import '../../profile/screens/profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;
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
    selectedIndex = 0;
    _pageController = PageController(initialPage: selectedIndex);

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0, end: 0.5).animate(_animationController);
  }

  void onItemTapped(int index) {
    if (index == 2) {
      _showAddTransactionMenu();
      return;
    }
    setState(() {
      selectedIndex = index;
      final pageIndex = index > 2 ? index - 1 : index;
      _pageController.animateToPage(
        pageIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showAddTransactionMenu() {
    _animationController.forward(); // Start rotation animation
    // Show the action sheet
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
      _animationController.reverse(); // Reset rotation animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: const [
              HomeScreen(),
              TransactionsScreen(),
              BudgetScreen(),
              ProfileScreen(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Bottom Navigation Bar
                Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(navItems.length, (index) {
                      final isSelected = selectedIndex == index;
                      final item = navItems[index];

                      if (index == 2) {
                        // Empty space for center button
                        return const SizedBox(width: 50);
                      }

                      return CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => onItemTapped(index),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isSelected
                              ? Text(
                                  item.label,
                                  key: ValueKey('text_$index'),
                                  style: const TextStyle(
                                    color: CupertinoColors.activeBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              : Icon(
                                  item.icon,
                                  key: ValueKey('icon_$index'),
                                  color: const Color(0xFF8E8E93),
                                  size: 24,
                                ),
                        ),
                      );
                    }),
                  ),
                ),
                // Floating Add Button
                Positioned(
                  top: -25,
                  child: RotationTransition(
                    turns: _animation,
                    child: GestureDetector(
                      onTap: () => _showAddTransactionMenu(),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  CupertinoColors.activeBlue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.add,
                          color: CupertinoColors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
