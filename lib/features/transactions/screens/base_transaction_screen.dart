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
import 'dart:io';
import '../../../features/transactions/widgets/repeat_dialog.dart';
import '../../../features/categories/screens/categories_screen.dart';

enum TransactionType { income, expense, transfer }

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
    final displayName = fileName.length > 10 
        ? '${fileName.substring(0, 7)}...' 
        : fileName;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? const Color(0xFF2C2C2E) 
              : const Color(0xFFE5E5EA),
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

  const BaseTransactionScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<BaseTransactionScreen> createState() => _BaseTransactionScreenState();
}

class _BaseTransactionScreenState extends ConsumerState<BaseTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isValid = false;
  List<String> _attachments = [];
  bool _isRepeat = false;
  RepeatFrequency _repeatFrequency = RepeatFrequency.monthly;
  DateTime? _repeatEndDate;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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
    return switch (widget.type) {
      TransactionType.income => const Color(0xFF00C853),
      TransactionType.expense => const Color(0xFFFF3B30),
      TransactionType.transfer => const Color(0xFF007AFF),
    };
  }

  String _getTitle() {
    return switch (widget.type) {
      TransactionType.income => 'Income',
      TransactionType.expense => 'Expense',
      TransactionType.transfer => 'Transfer',
    };
  }

  void _deleteAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
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
            SafeArea(
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
            ),
            // Amount Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: null,
                          placeholder: '0',
                          placeholderStyle: TextStyle(
                            fontSize: 40,
                            color: CupertinoColors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            TextInputFormatter.withFunction((oldValue, newValue) {
                              try {
                                final text = newValue.text;
                                if (text.isEmpty) return newValue;
                                final number = double.parse(text);
                                final isValid = text.contains('.') ? text.split('.')[1].length <= 2 : true;
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
            ),
            // Form Fields
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Category Selector
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => CategoriesScreen(
                                  filterType: widget.type == TransactionType.income 
                                      ? CategoryType.income 
                                      : CategoryType.expense,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                'Category',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: isDarkMode 
                                      ? CupertinoColors.white 
                                      : CupertinoColors.black,
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
                      ),
                      const SizedBox(height: 16),
                      // Description Field
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
                        child: CupertinoTextField(
                          controller: _descriptionController,
                          padding: const EdgeInsets.all(16),
                          placeholder: 'Description',
                          decoration: null,
                          style: TextStyle(
                            color: isDarkMode 
                                ? CupertinoColors.white 
                                : CupertinoColors.black,
                          ),
                          placeholderStyle: TextStyle(
                            color: isDarkMode 
                                ? CupertinoColors.systemGrey 
                                : CupertinoColors.systemGrey2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Wallet Selector
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
                                  color: isDarkMode 
                                      ? CupertinoColors.white 
                                      : CupertinoColors.black,
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
                      ),
                      const SizedBox(height: 16),
                      // Attachment Button
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
                      ),
                      const SizedBox(height: 24),
                      // Repeat Switch
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Save Button
            Container(
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
                onPressed: _isValid ? () async {
                  await HapticService.lightImpact(ref);
                  // TODO: Handle save
                  Navigator.pop(context);
                } : null,
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
            ),
          ],
        ),
      ),
    );
  }
} 