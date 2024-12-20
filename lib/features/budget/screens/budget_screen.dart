import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../transactions/models/transaction_model.dart';
import '../../transactions/providers/transactions_provider.dart';
import 'package:intl/intl.dart';
import 'create_budget_screen.dart';
import '../providers/budget_provider.dart';
import '../models/budget_model.dart';
import '../../../core/providers/currency_provider.dart';
import 'budget_transactions_screen.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  DateTime _selectedMonth = DateTime.now();
  bool _isShowingMonthPicker = false;

  void _showMonthPicker() {
    setState(() {
      _isShowingMonthPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final monthName = DateFormat('MMMM').format(_selectedMonth);
    final budgets = ref.watch(budgetProvider);
    final transactions = ref.watch(transactionsProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                color: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: _showMonthPicker,
                              child: Row(
                                children: [
                                  Text(
                                    monthName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: CupertinoColors.systemPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    CupertinoIcons.chevron_down,
                                    color: CupertinoColors.systemPurple,
                                    size: 20,
                                  ),
                                ],
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
                      Container(
                        height: 1,
                        color: isDarkMode 
                            ? const Color(0xFF2C2C2E) 
                            : const Color(0xFFE5E5EA),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: budgets.isEmpty
                    ? _buildEmptyState()
                    : _buildBudgetList(budgets),
              ),
            ],
          ),
          if (_isShowingMonthPicker)
            Container(
              color: CupertinoColors.black.withOpacity(0.4),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isShowingMonthPicker = false;
                        });
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF1C1C1E) : CupertinoColors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CupertinoButton(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: isDarkMode ? CupertinoColors.white : CupertinoColors.systemBlue,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isShowingMonthPicker = false;
                                  });
                                },
                              ),
                              CupertinoButton(
                                child: Text(
                                  'Done',
                                  style: TextStyle(
                                    color: isDarkMode ? CupertinoColors.white : CupertinoColors.systemBlue,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isShowingMonthPicker = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.monthYear,
                            initialDateTime: _selectedMonth,
                            maximumDate: DateTime.now(),
                            minimumYear: 2000,
                            maximumYear: DateTime.now().year,
                            onDateTimeChanged: (date) {
                              setState(() {
                                _selectedMonth = DateTime(
                                  date.year,
                                  date.month,
                                  1,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
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
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            // Refresh budgets if needed
          },
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final budget = budgets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildBudgetCard(budget),
                );
              },
              childCount: budgets.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final isDarkMode = ref.watch(themeProvider);
    final currency = ref.watch(currencyProvider);
    final transactions = ref.watch(transactionsProvider);
    
    // Calculate spent amount for this budget
    final spent = _calculateSpentAmount(budget, transactions);
    final progress = spent / budget.amount;

    Color getProgressColor(double progress) {
      if (progress >= 1.0) return CupertinoColors.systemRed;
      if (progress >= 0.8) return CupertinoColors.systemOrange;
      return budget.category.color;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => BudgetTransactionsScreen(budget: budget),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
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
                        budget.category.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        budget.isRecurring
                            ? budget.recurringType?.toString().split('.').last.toUpperCase() ?? 'MONTHLY'
                            : 'ONE TIME',
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
                      '${currency.symbol}${budget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Spent: ${currency.symbol}${spent.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDarkMode 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.systemGrey2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 24,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: getProgressColor(progress).withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(getProgressColor(progress)),
                        minHeight: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: getProgressColor(progress),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateSpentAmount(Budget budget, List<Transaction> transactions) {
    return transactions
      .where((t) => 
        t.category.id == budget.category.id && // Match by category
        t.type == TransactionType.expense &&
        budget.isDateInPeriod(t.date))
      .fold(0.0, (sum, t) => sum + t.amount.abs());
  }
}

