import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show Colors;
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/services/attachment_service.dart';
import '../../../features/categories/models/category_model.dart';
import '../../budget/models/budget_model.dart';
import 'dart:io';
import '../../../features/transactions/widgets/repeat_dialog.dart';
import '../../../features/categories/screens/categories_screen.dart';
import '../models/transaction_model.dart';
import '../providers/transactions_provider.dart';
import '../widgets/category_selection_sheet.dart';
import '../../categories/providers/categories_provider.dart';
import 'dart:async';
import '../../payees/models/payee_model.dart';
import '../../payees/providers/payees_provider.dart';
import '../../budget/providers/budget_provider.dart';
import 'package:uuid/uuid.dart';

class AttachmentPreview extends StatelessWidget {
  final String filePath;
  final VoidCallback onDelete;
  final bool isDarkMode;

  const AttachmentPreview({
    super.key,
    required this.filePath,
    required this.onDelete,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = filePath.toLowerCase().endsWith('.jpg') ||
        filePath.toLowerCase().endsWith('.jpeg') ||
        filePath.toLowerCase().endsWith('.png');

    // Get file name from path
    final fileName = filePath.split('/').last;
    // Truncate file name if too long
    final displayName =
        fileName.length > 10 ? '${fileName.substring(0, 7)}...' : fileName;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        ),
      ),
      child: Stack(
        children: [
          // Image or PDF preview with filename
          Center(
            child: isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(filePath),
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.doc_fill,
                        size: 40,
                        color: CupertinoColors.systemPurple,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.6)
                      : Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.xmark_circle_fill,
                  size: 20,
                  color: isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BaseTransactionScreen extends ConsumerStatefulWidget {
  final TransactionType type;
  final Transaction? transaction;

  const BaseTransactionScreen({
    super.key,
    required this.type,
    this.transaction,
  });

  @override
  ConsumerState<BaseTransactionScreen> createState() =>
      _BaseTransactionScreenState();
}

class _BaseTransactionScreenState extends ConsumerState<BaseTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isValid = false;
  List<String> _attachments = [];
  bool _isRepeat = false;
  RepeatFrequency _repeatFrequency = RepeatFrequency.monthly;
  DateTime? _repeatEndDate;
  Category? _selectedCategory;
  bool _showCategoryMessage = false;
  Timer? _messageTimer;
  Payee? _selectedPayee;
  Budget? _selectedBudget;

  static const _padding = EdgeInsets.all(24);
  static const _spacing = SizedBox(height: 16);
  static const _largeSpacing = SizedBox(height: 24);

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateInputs);
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.abs().toString();
      _descriptionController.text = widget.transaction!.description;
      _selectedCategory = widget.transaction!.category;
      _attachments = List.from(widget.transaction!.attachments);
      _isRepeat = widget.transaction!.isRepeat;
      _repeatFrequency =
          widget.transaction!.repeatFrequency ?? RepeatFrequency.monthly;
      _repeatEndDate = widget.transaction!.repeatEndDate;

      if (widget.transaction!.payeeId != null) {
        final payees = ref.read(payeesProvider);
        try {
          _selectedPayee = payees.firstWhere(
            (p) => p.id == widget.transaction!.payeeId,
          );
        } catch (e) {
          debugPrint('Payee not found: ${widget.transaction!.payeeId}');
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _isValid = _amountController.text.isNotEmpty &&
          double.tryParse(_amountController.text) != null &&
          double.parse(_amountController.text) > 0;
    });
  }

  Color _getThemeColor() {
    switch (widget.type) {
      case TransactionType.income:
        return const Color(0xFF00C853);
      case TransactionType.expense:
        return const Color(0xFFFF3B30);
      case TransactionType.transfer:
        return const Color(0xFF007AFF);
      default:
        return const Color(0xFF007AFF); // Default color
    }
  }

  String _getTitle() {
    switch (widget.type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
      default:
        return 'Transaction'; // Default title
    }
  }

  void _deleteAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _saveTransaction() async {
    if (!_isValid || _selectedCategory == null) return;

    await HapticService.lightImpact(ref);

    final amount = double.parse(_amountController.text);
    final now = DateTime.now();

    final budget = _findMatchingBudget();
    final transaction = Transaction(
      id: widget.transaction?.id ?? const Uuid().v4(),
      amount:
          widget.type == TransactionType.expense ? -amount.abs() : amount.abs(),
      description: _descriptionController.text,
      date: now,
      category: _selectedCategory!,
      budgetId: budget?.id,
      type: widget.type,
      attachments: _attachments,
      currencyCode: ref.read(settingsProvider).currency,
      updatedAt: DateTime.now(),
      isRepeat: _isRepeat,
      repeatFrequency: _isRepeat ? _repeatFrequency : null,
      repeatEndDate: _isRepeat ? _repeatEndDate : null,
      payeeId: _selectedPayee?.id,
    );

    if (mounted) {
      ref.read(transactionsProvider.notifier).addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  void _showTemporaryMessage() {
    setState(() {
      _showCategoryMessage = true;
    });

    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showCategoryMessage = false;
        });
      }
    });
  }

  Widget _buildCategorySelector(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode
                  ? const Color(0xFF2C2C2E)
                  : const Color(0xFFE5E5EA),
            ),
          ),
          child: CupertinoButton(
            padding: const EdgeInsets.all(16),
            onPressed: widget.transaction != null
                ? () => _showTemporaryMessage()
                : () async {
                    final categories = ref
                        .read(categoriesProvider)
                        .where((cat) =>
                            cat.type ==
                            (widget.type == TransactionType.income
                                ? CategoryType.income
                                : CategoryType.expense))
                        .toList();

                    await showCupertinoModalPopup(
                      context: context,
                      useRootNavigator: true,
                      barrierDismissible: true,
                      builder: (BuildContext context) => CategorySelectionSheet(
                        categories: categories,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          if (mounted) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                      ),
                    );
                  },
            child: Row(
              children: [
                if (_selectedCategory != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedCategory!.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _selectedCategory!.icon,
                      color: _selectedCategory!.color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedCategory!.name,
                    style: TextStyle(
                      fontSize: 17,
                      color: widget.transaction != null
                          ? (isDarkMode
                              ? CupertinoColors.white.withOpacity(0.6)
                              : CupertinoColors.black.withOpacity(0.6))
                          : (isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black),
                    ),
                  ),
                ] else
                  Text(
                    'Select Category',
                    style: TextStyle(
                      fontSize: 17,
                      color: isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                const Spacer(),
                if (widget.transaction == null)
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: isDarkMode
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey2,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (_showCategoryMessage)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Category change is not allowed. Please delete this transaction and add a new one.',
              style: TextStyle(
                fontSize: 13,
                color: CupertinoColors.systemRed,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDescriptionField(bool isDarkMode) {
    return Container(
      decoration: _getCardDecoration(isDarkMode),
      child: CupertinoTextField(
        controller: _descriptionController,
        padding: const EdgeInsets.all(16),
        placeholder: 'Description',
        decoration: null,
        style: TextStyle(
          color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        ),
        placeholderStyle: TextStyle(
          color: isDarkMode
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey2,
        ),
      ),
    );
  }

  Widget _buildWalletSelector(bool isDarkMode) {
    return Container(
      decoration: _getCardDecoration(isDarkMode),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        onPressed: () {
          // TODO: Show wallet selector
        },
        child: Row(
          children: [
            Text(
              'Wallet',
              style: TextStyle(
                fontSize: 17,
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
              ),
            ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_down,
              size: 16,
              color: isDarkMode
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayeeSelector(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.all(16),
        onPressed: () async {
          final payees = ref.read(payeesProvider);

          await showCupertinoModalPopup(
            context: context,
            useRootNavigator: true,
            barrierDismissible: true,
            builder: (BuildContext context) => CupertinoActionSheet(
              title: const Text('Select Payee'),
              message: const Text('Choose a payee for this transaction'),
              actions: [
                ...payees.map(
                  (payee) => CupertinoActionSheetAction(
                    onPressed: () {
                      setState(() {
                        _selectedPayee = payee;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(payee.name),
                  ),
                ),
              ],
              cancelButton: CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  setState(() {
                    _selectedPayee = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear Selection'),
              ),
            ),
          );
        },
        child: Row(
          children: [
            if (_selectedPayee != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode
                      ? CupertinoColors.systemGrey6.darkColor
                      : CupertinoColors.systemGrey6,
                ),
                child: Center(
                  child: Text(
                    _selectedPayee!.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _selectedPayee!.name,
                style: TextStyle(
                  fontSize: 17,
                  color: isDarkMode
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                ),
              ),
            ] else
              Text(
                'Select Payee',
                style: TextStyle(
                  fontSize: 17,
                  color: isDarkMode
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey2,
                ),
              ),
            const Spacer(),
            Icon(
              CupertinoIcons.chevron_right,
              color: isDarkMode
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _getCardDecoration(bool isDarkMode) {
    return BoxDecoration(
      color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
      ),
    );
  }

  Widget _buildAttachmentSection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        ),
      ),
      child: _attachments.isEmpty
          ? CupertinoButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              onPressed: () {
                AttachmentService.showAttachmentOptions(
                  context,
                  onAttachmentsSelected: (paths) {
                    setState(() {
                      _attachments.addAll(paths);
                    });
                  },
                );
              },
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.paperclip,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add attachment',
                    style: TextStyle(
                      fontSize: 17,
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (int i = 0; i < _attachments.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          AttachmentPreview(
                            filePath: _attachments[i],
                            onDelete: () => _deleteAttachment(i),
                            isDarkMode: isDarkMode,
                          ),
                        ],
                        if (_attachments.length < 2) ...[
                          const SizedBox(width: 12),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              AttachmentService.showAttachmentOptions(
                                context,
                                onAttachmentsSelected: (paths) {
                                  setState(() {
                                    _attachments.addAll(paths);
                                  });
                                },
                              );
                            },
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? AppTheme.cardDark
                                    : AppTheme.cardLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? const Color(0xFF2C2C2E)
                                      : const Color(0xFFE5E5EA),
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.add_circled,
                                  size: 30,
                                  color: isDarkMode
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRepeatSection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repeat',
                    style: TextStyle(
                      fontSize: 17,
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  Text(
                    _isRepeat
                        ? '${_repeatFrequency.name.substring(0, 1).toUpperCase()}${_repeatFrequency.name.substring(1)} until ${_repeatEndDate?.toString().split(' ')[0] ?? 'No end date'}'
                        : 'Repeat transaction',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              CupertinoSwitch(
                value: _isRepeat,
                onChanged: (value) async {
                  await HapticService.lightImpact(ref);
                  setState(() {
                    _isRepeat = value;
                  });
                  if (value && mounted) {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) => ProviderScope(
                        parent: ProviderScope.containerOf(context),
                        child: RepeatDialog(
                          frequency: _repeatFrequency,
                          endDate: _repeatEndDate,
                          onSave: (frequency, endDate) {
                            setState(() {
                              _repeatFrequency = frequency;
                              _repeatEndDate = endDate;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
        child: Row(
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
              child: const Icon(
                CupertinoIcons.back,
                color: CupertinoColors.white,
              ),
            ),
            Expanded(
              child: Text(
                _getTitle(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How much?',
            style: TextStyle(
              fontSize: 20,
              color: CupertinoColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                getCurrencySymbol(ref.watch(settingsProvider).currency),
                style: const TextStyle(
                  fontSize: 64,
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: CupertinoTextField(
                  controller: _amountController,
                  style: const TextStyle(
                    fontSize: 64,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: null,
                  placeholder: '0',
                  placeholderStyle: TextStyle(
                    fontSize: 64,
                    color: CupertinoColors.white.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      try {
                        final text = newValue.text;
                        if (text.isEmpty) return newValue;
                        final number = double.parse(text);
                        final isValid = text.contains('.')
                            ? text.split('.')[1].length <= 2
                            : true;
                        if (isValid) return newValue;
                      } catch (e) {}
                      return oldValue;
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: ListView(
        padding: _padding,
        physics: const BouncingScrollPhysics(),
        children: [
          RepaintBoundary(child: _buildCategorySelector(isDarkMode)),
          _spacing,
          _buildDescriptionField(isDarkMode),
          _spacing,
          _buildWalletSelector(isDarkMode),
          _spacing,
          if (widget.type == TransactionType.transfer)
            Column(
              children: [
                _buildPayeeSelector(isDarkMode),
                _spacing,
              ],
            ),
          RepaintBoundary(child: _buildAttachmentSection(isDarkMode)),
          _largeSpacing,
          RepaintBoundary(child: _buildRepeatSection(isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildSaveButton(bool isDarkMode, Color themeColor) {
    return Container(
      color: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 24,
        top: 16,
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: BorderRadius.circular(30),
        color: themeColor,
        onPressed:
            _isValid && _selectedCategory != null ? _saveTransaction : null,
        child: const Center(
          child: Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Budget? _findMatchingBudget() {
    if (_selectedCategory == null) return null;

    final budgets = ref.read(budgetProvider);
    try {
      return budgets.firstWhere(
        (budget) =>
            budget.category.id == _selectedCategory!.id &&
            budget.isActive() &&
            budget.isDateInPeriod(DateTime.now()),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final themeColor = _getThemeColor();

    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor: themeColor,
        child: Column(
          children: [
            // Header
            RepaintBoundary(child: _buildHeader()),
            // Amount Input
            RepaintBoundary(child: _buildAmountInput()),
            // Form Fields
            Expanded(
              child: _buildFormFields(isDarkMode),
            ),
            // Save Button
            RepaintBoundary(child: _buildSaveButton(isDarkMode, themeColor)),
          ],
        ),
      ),
    );
  }
}
