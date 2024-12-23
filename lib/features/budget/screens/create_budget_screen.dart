import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../../categories/models/category_model.dart';
import '../../categories/providers/categories_provider.dart';
import '../models/budget_model.dart';
import '../providers/budget_provider.dart';
import '../../../core/providers/currency_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart' show Colors;
import '../../transactions/models/transaction_model.dart';

class CreateBudgetScreen extends ConsumerStatefulWidget {
  final Budget? budget;
  final bool isEditingCategory;
  final Category? category;

  const CreateBudgetScreen({
    super.key,
    this.budget,
    this.isEditingCategory = false,
    this.category,
  });

  @override
  ConsumerState<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends ConsumerState<CreateBudgetScreen> {
  final TextEditingController _amountController = TextEditingController();
  Category? _selectedCategory;
  bool _isRecurring = false;
  RepeatFrequency _recurringType = RepeatFrequency.monthly;
  bool _isValid = false;
  double _alertThreshold = 0.8;
  final TextEditingController _nameController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 30));
  CategoryType _selectedCategoryType = CategoryType.expense;

  @override
  void initState() {
    super.initState();
    if (widget.isEditingCategory) {
      _selectedCategory = widget.category;
      _selectedCategoryType = widget.category?.type ?? CategoryType.expense;
    } else if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _selectedCategory = widget.budget!.category;
      _isRecurring = widget.budget!.isRecurring;
      _recurringType = widget.budget!.recurringType;
      _alertThreshold = widget.budget!.alertThreshold;
      _nameController.text = widget.budget!.name;
      _startDate = widget.budget!.startDate;
      _endDate = widget.budget!.endDate;
    }
    _amountController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _isValid = _amountController.text.isNotEmpty && 
                 double.tryParse(_amountController.text) != null &&
                 double.parse(_amountController.text) > 0 &&
                 _selectedCategory != null;
    });
  }

  void _showCategoryPicker() async {
    await Future.microtask(() {});
    
    if (!mounted) return;
    
    final categories = ref.read(categoriesProvider)
        .where((cat) => cat.type == _selectedCategoryType)
        .toList();
        
    if (categories.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('No Categories'),
          content: Text('No ${_selectedCategoryType == CategoryType.income ? 'income' : 'expense'} categories available.'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    categories.sort((a, b) => a.name.compareTo(b.name));
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Select ${_selectedCategoryType == CategoryType.income ? 'Income' : 'Expense'} Category'),
        message: Text('${categories.length} categories available'),
        actions: categories.map((category) => 
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                _selectedCategory = category;
              });
              _validateInputs();
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(category.icon, color: category.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (category.description.isNotEmpty)
                                Text(
                                  category.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (category == _selectedCategory)
                    const Icon(
                      CupertinoIcons.check_mark,
                      color: CupertinoColors.activeBlue,
                    ),
                ],
              ),
            ),
          ),
        ).toList(),
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _saveBudget() async {
    if (!_isValid) return;

    await HapticService.lightImpact(ref);

    final budget = Budget(
      id: widget.budget?.id ?? const Uuid().v4(),
      name: _nameController.text,
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategory!.id,
      category: _selectedCategory!,
      startDate: _startDate,
      endDate: _endDate,
      isRecurring: _isRecurring,
      recurringType: _recurringType,
      alertThreshold: _alertThreshold,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (mounted) {
      if (widget.budget != null) {
        ref.read(budgetProvider.notifier).updateBudget(budget);
      } else {
        ref.read(budgetProvider.notifier).addBudget(budget);
      }
      Navigator.pop(context);
    }
  }

  void _showDeleteConfirmation() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await ref.read(budgetProvider.notifier).deleteBudget(widget.budget!.id);
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close screen
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  DateTime _getEndDate(DateTime startDate, RepeatFrequency type) {
    switch (type) {
      case RepeatFrequency.daily:
        return startDate.add(const Duration(days: 1));
      case RepeatFrequency.weekly:
        return startDate.add(const Duration(days: 7));
      case RepeatFrequency.monthly:
        return DateTime(startDate.year, startDate.month + 1, startDate.day);
      case RepeatFrequency.yearly:
        return DateTime(startDate.year + 1, startDate.month, startDate.day);
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return CupertinoColors.systemRed;
    if (progress >= 0.6) return CupertinoColors.systemOrange;
    return CupertinoColors.systemPurple;
  }

  String _getRecurringText(RepeatFrequency type) {
    switch (type) {
      case RepeatFrequency.daily:
        return 'Daily';
      case RepeatFrequency.weekly:
        return 'Weekly';
      case RepeatFrequency.monthly:
        return 'Monthly';
      case RepeatFrequency.yearly:
        return 'Yearly';
    }
  }

  Widget _buildCategorySelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Type Selector
              CupertinoSlidingSegmentedControl<CategoryType>(
                groupValue: _selectedCategoryType,
                children: const {
                  CategoryType.expense: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Expense'),
                  ),
                  CategoryType.income: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('Income'),
                  ),
                },
                onValueChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategoryType = value;
                      // Clear selected category if type changes
                      if (_selectedCategory?.type != value) {
                        _selectedCategory = null;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Category Selector
              GestureDetector(
                onTap: _showCategoryPicker,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? AppTheme.backgroundDark 
                        : CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      if (_selectedCategory != null) ...[
                        Icon(
                          _selectedCategory!.icon,
                          color: _selectedCategory!.color,
                        ),
                        const SizedBox(width: 8),
                        Text(_selectedCategory!.name),
                      ] else
                        Text(
                          'Select ${_selectedCategoryType == CategoryType.income ? 'Income' : 'Expense'} Category',
                          style: TextStyle(
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                      const Spacer(),
                      const Icon(CupertinoIcons.chevron_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currency = ref.watch(currencyProvider);

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemPurple,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemPurple,
        border: null,
        middle: Text(
          widget.budget != null ? 'Edit Budget' : 'Create Budget',
          style: const TextStyle(color: CupertinoColors.white),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.back,
            color: CupertinoColors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: widget.budget != null ? CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.delete,
            color: CupertinoColors.white,
          ),
          onPressed: _showDeleteConfirmation,
        ) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Text(
              'How much do yo want to spend?',
              style: TextStyle(
                fontSize: 24,
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  currency.symbol,
                  style: const TextStyle(
                    fontSize: 40,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: CupertinoTextField(
                    controller: _amountController,
                    style: const TextStyle(
                      fontSize: 40,
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: null,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    placeholder: '0',
                    placeholderStyle: TextStyle(
                      fontSize: 40,
                      color: CupertinoColors.white.withOpacity(0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.backgroundDark : CupertinoColors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildCategorySelector(isDarkMode),
                  const SizedBox(height: 24),
                  
                  // Alert Option
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Receive Alert'),
                            CupertinoSwitch(
                              value: _alertThreshold > 0,
                              onChanged: (value) {
                                setState(() {
                                  _alertThreshold = value ? 0.8 : 0;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_alertThreshold > 0) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Alert me when budget reaches',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkMode 
                                      ? CupertinoColors.systemGrey 
                                      : CupertinoColors.systemGrey2,
                                ),
                              ),
                              Text(
                                '${(_alertThreshold * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode 
                                      ? CupertinoColors.white 
                                      : CupertinoColors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 40,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? AppTheme.backgroundDark 
                                  : CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Progress Indicator
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: _alertThreshold,
                                          backgroundColor: Colors.transparent,
                                          valueColor: AlwaysStoppedAnimation(
                                            _getProgressColor(_alertThreshold)
                                          ),
                                          minHeight: 24,
                                        ),
                                      ),
                                      // Slider
                                      CupertinoSlider(
                                        value: _alertThreshold,
                                        min: 0.1,
                                        max: 1.0,
                                        activeColor: Colors.transparent,
                                        thumbColor: _getProgressColor(_alertThreshold),
                                        onChanged: (value) async {
                                          await HapticService.selectionClick(ref);
                                          setState(() {
                                            _alertThreshold = value;
                                          });
                                        },
                                        onChangeEnd: (value) async {
                                          await HapticService.lightImpact(ref);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${(_alertThreshold * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: _getProgressColor(_alertThreshold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Continue Button
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    borderRadius: BorderRadius.circular(30),
                    color: CupertinoColors.systemPurple,
                    onPressed: _isValid ? _saveBudget : null,
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}