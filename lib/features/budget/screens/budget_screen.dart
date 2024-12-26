import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendwise/core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

import '../models/budget_model.dart';
import '../providers/budget_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transactions_provider.dart';

import 'create_budget_screen.dart';
import '../../../core/providers/currency_provider.dart';
import 'budget_transactions_screen.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  bool _showBudgets = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final allBudgets = ref.watch(budgetProvider);

    // Filter based on selected type and active status
    final filteredBudgets = allBudgets
        .where((b) =>
            b.isActive() && (_showBudgets ? !b.isRecurring : b.isRecurring))
        .toList();

    return CupertinoPageScaffold(
      backgroundColor:
          isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Section with Segment Control
            SliverPersistentHeader(
              pinned: true,
              delegate: _BudgetHeaderDelegate(
                isDarkMode: isDarkMode,
                showBudgets: _showBudgets,
                onSegmentChanged: (value) =>
                    setState(() => _showBudgets = value),
              ),
            ),

            // Summary Card
            SliverToBoxAdapter(
              child: _buildSummaryCard(
                filteredBudgets,
                isDarkMode,
                _showBudgets ? 'Total Budget' : 'Total Goals',
              ),
            ),

            // Create Budget Button
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: CupertinoColors.systemPurple,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => CreateBudgetScreen(
                          isGoal: !_showBudgets,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.add,
                          color: CupertinoColors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Create New ${_showBudgets ? 'Budget' : 'Goal'}',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  _showBudgets ? 'Active Budgets' : 'Active Goals',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                ),
              ),
            ),

            // Budget Cards
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: filteredBudgets.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _showBudgets
                                  ? CupertinoIcons.money_dollar_circle
                                  : CupertinoIcons.flag,
                              size: 64,
                              color: isDarkMode
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showBudgets
                                  ? 'No active budgets'
                                  : 'No active goals',
                              style: TextStyle(
                                fontSize: 20,
                                color: isDarkMode
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.systemGrey3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildBudgetCard(
                            filteredBudgets[index], isDarkMode),
                        childCount: filteredBudgets.length,
                      ),
                    ),
            ),

            // Bottom Padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      List<Budget> budgets, bool isDarkMode, String title) {
    final totalBudget =
        budgets.fold<double>(0, (sum, budget) => sum + budget.amount);
    final totalSpent =
        budgets.fold<double>(0, (sum, budget) => sum + budget.spent);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CupertinoColors.systemPurple,
            CupertinoColors.systemPurple.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(title, totalBudget),
              _buildSummaryItem('Total Spent', totalSpent),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressBar(totalSpent / totalBudget),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Update the budget card design
  Widget _buildBudgetCard(Budget budget, bool isDarkMode) {
    final progress = budget.getCurrentProgress();
    final isOverBudget = progress > 1.0;

    return Dismissible(
      key: Key(budget.id),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: CupertinoColors.systemBlue,
        alignment: Alignment.centerLeft,
        child: const Icon(
          CupertinoIcons.pencil,
          color: CupertinoColors.white,
        ),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: CupertinoColors.destructiveRed,
        alignment: Alignment.centerRight,
        child: const Icon(
          CupertinoIcons.delete,
          color: CupertinoColors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete action
          return await _showDeleteDialog(budget);
        } else {
          // Edit action
          await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => CreateBudgetScreen(
                budget: budget,
                isGoal: budget.isRecurring,
              ),
            ),
          );
          return false; // Don't dismiss, just show edit screen
        }
      },
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _showBudgetDetails(budget),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode
                  ? CupertinoColors.systemGrey.withOpacity(0.2)
                  : CupertinoColors.systemGrey6,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: budget.category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        budget.category.icon,
                        color: budget.category.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                          ),
                          Text(
                            'Ends ${_formatDate(budget.endDate)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${budget.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            color: isOverBudget
                                ? CupertinoColors.systemRed
                                : budget.category.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressBar(
                    progress, isOverBudget, budget.category.color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showDeleteDialog(Budget budget) async {
    bool delete = false;
    await showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete ${budget.name}?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              delete = true;
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              delete = false;
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );

    if (delete) {
      try {
        await ref.read(budgetProvider.notifier).deleteBudget(budget.id);
        return true;
      } catch (e) {
        if (!mounted) return false;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to delete budget: $e'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return false;
      }
    }
    return false;
  }

  Widget _buildProgressBar(double progress,
      [bool isOverBudget = false, Color? color]) {
    final progressColor = isOverBudget
        ? CupertinoColors.systemRed
        : (color ?? CupertinoColors.white);

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: progressColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: progressColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 0 && difference < 7) {
      return 'in $difference days';
    } else {
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return '$day/$month';
    }
  }

  void _showBudgetDetails(Budget budget) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => BudgetTransactionsScreen(budget: budget),
      ),
    );
  }

  // ...rest of existing code...
}

class _BudgetHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isDarkMode;
  final bool showBudgets;
  final ValueChanged<bool> onSegmentChanged;

  _BudgetHeaderDelegate({
    required this.isDarkMode,
    required this.showBudgets,
    required this.onSegmentChanged,
  });

  @override
  Widget build(context, shrinkExtent, overlapsContent) {
    return Container(
      height: maxExtent,
      color: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoSegmentedControl<bool>(
              selectedColor: CupertinoColors.systemPurple,
              padding: EdgeInsets.zero,
              children: {
                true: _buildSegment('Budgets', true),
                false: _buildSegment('Goals', false),
              },
              groupValue: showBudgets,
              onValueChanged: onSegmentChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected
              ? CupertinoColors.white
              : (isDarkMode ? CupertinoColors.white : CupertinoColors.black),
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
