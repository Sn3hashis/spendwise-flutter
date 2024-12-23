import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../models/budget_model.dart';
import '../providers/budget_provider.dart';
import '../../transactions/widgets/date_range_selector.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transactions_provider.dart';
import 'package:intl/intl.dart';
import 'create_budget_screen.dart';
import '../../../core/providers/currency_provider.dart';
import 'budget_transactions_screen.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  bool _isShowingMonthPicker = false;

  void _showMonthPicker() {
    setState(() {
      _isShowingMonthPicker = true;
    });
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Budget budget) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete "${budget.name}"?'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(budgetProvider.notifier).deleteBudget(budget.id);
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBudgetActions(BuildContext context, WidgetRef ref, Budget budget) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => CreateBudgetScreen(budget: budget),
                ),
              );
            },
            child: const Text('Edit Budget'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, ref, budget);
            },
            child: const Text('Delete Budget'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showBudgetTransactions(BuildContext context, Budget budget, List<Transaction> transactions) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => BudgetTransactionsScreen(budget: budget),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final budgets = ref.watch(budgetProvider);
    final transactions = ref.watch(transactionsProvider);
    final selectedRange = DateRange(
      startDate: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
      endDate: DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0),
      type: DateRangeType.month,
    );

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header with Month Selector
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DateRangeSelector(
                      selectedRange: selectedRange,
                      onRangeSelected: (range) {
                        setState(() {
                          _selectedMonth = range.startDate;
                        });
                      },
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const CreateBudgetScreen(),
                        ),
                      );
                    },
                    child: const Icon(CupertinoIcons.add),
                  ),
                ],
              ),
            ),
            // Budget List or Empty State
            Expanded(
              child: budgets.isEmpty 
                ? _buildEmptyState()
                : _buildBudgetList(budgets),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = ref.watch(themeProvider);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.money_dollar_circle,
            size: 64,
            color: isDarkMode 
                ? CupertinoColors.systemGrey 
                : CupertinoColors.systemGrey2,
          ),
          const SizedBox(height: 16),
          Text(
            "You don't have a budget.",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode 
                  ? CupertinoColors.systemGrey 
                  : CupertinoColors.systemGrey2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Let's make one so you in control.",
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode 
                  ? CupertinoColors.systemGrey 
                  : CupertinoColors.systemGrey2,
            ),
          ),
          const SizedBox(height: 32),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            borderRadius: BorderRadius.circular(30),
            color: CupertinoColors.systemPurple,
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const CreateBudgetScreen(),
                ),
              );
            },
            child: const Text(
              'Create a budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetList(List<Budget> budgets) {
    final isDarkMode = ref.watch(themeProvider);
    final transactions = ref.watch(transactionsProvider);
    final currency = ref.watch(currencyProvider);
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        final spent = _calculateSpentForBudget(budget, transactions);
        final progress = (spent / budget.amount).clamp(0.0, 1.0);
        final remaining = budget.amount - spent;

        return CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showBudgetTransactions(context, budget, transactions),
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1C1C1E) : CupertinoColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            budget.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: budget.category.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  budget.category.icon,
                                  color: budget.category.color,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                budget.category.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: progress >= 1.0
                            ? CupertinoColors.systemRed
                            : progress >= 0.9
                                ? CupertinoColors.systemOrange
                                : CupertinoColors.systemGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: progress >= 1.0
                            ? CupertinoColors.systemRed
                            : progress >= 0.9
                                ? CupertinoColors.systemOrange
                                : CupertinoColors.systemGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spent: ${currency.symbol}${spent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      'Remaining: ${currency.symbol}${remaining.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }  double _calculateSpentForBudget(Budget budget, List<Transaction> transactions) {    return transactions        .where((t) => t.category.id == budget.category.id)        .where((t) => t.type == TransactionType.expense)        .where((t) => t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month)        .fold(0.0, (sum, t) => sum + t.amount.abs());  }}