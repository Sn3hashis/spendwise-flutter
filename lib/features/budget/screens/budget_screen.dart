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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final monthName = DateFormat('MMMM').format(_selectedMonth);
    final budgets = ref.watch(budgetProvider);

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

        return Container(
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
                  Text(
                    budget.category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
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
        );
      },
    );
  }

  double _calculateSpentForBudget(Budget budget, List<Transaction> transactions) {
    return transactions
        .where((t) => t.category.id == budget.category.id)
        .where((t) => t.type == TransactionType.expense)
        .where((t) => t.date.year == _selectedMonth.year && t.date.month == _selectedMonth.month)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }
}
