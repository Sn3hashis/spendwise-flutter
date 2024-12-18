import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../features/settings/providers/settings_provider.dart';
import '../../../core/services/attachment_service.dart';
import '../../categories/models/category_model.dart';
import '../models/transaction_type.dart';
import '../models/transaction_model.dart';
import '../providers/transactions_provider.dart';
import 'base_transaction_screen.dart';
import '../models/repeat_frequency.dart';
import '../widgets/repeat_dialog.dart';
import '../../payees/models/payee_model.dart';
import '../../payees/providers/payees_provider.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isValid = false;
  List<String> _attachments = [];
  String? _fromWallet;
  String? _toWallet;
  bool _isRepeat = false;
  RepeatFrequency _repeatFrequency = RepeatFrequency.monthly;
  DateTime? _repeatEndDate;
  Payee? _fromPayee;
  Payee? _toPayee;

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
                 double.parse(_amountController.text) > 0 &&
                 _toPayee != null;
    });
  }

  void _deleteAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _showPayeeSelection(bool isFromPayee) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(isFromPayee ? 'Select From Payee' : 'Select To Payee'),
        message: const Text('Choose a payee for the transfer'),
        actions: [
          ...ref.read(payeesProvider).map(
                (payee) => CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() {
                      if (isFromPayee) {
                        _fromPayee = payee;
                      } else {
                        _toPayee = payee;
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(payee.name),
                      if ((isFromPayee && payee == _fromPayee) || 
                          (!isFromPayee && payee == _toPayee))
                        const Icon(
                          CupertinoIcons.check_mark,
                          color: CupertinoColors.activeBlue,
                        ),
                    ],
                  ),
                ),
              ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (!_isValid) return;

    await HapticService.lightImpact(ref);

    final amount = double.parse(_amountController.text);
    
    final transaction = Transaction(
      id: DateTime.now().toString(),
      amount: amount,
      description: _descriptionController.text,
      category: Category(
        id: 'transfer',
        name: 'Transfer',
        description: 'Money transfer between accounts',
        icon: CupertinoIcons.arrow_right_arrow_left,
        color: const Color(0xFF7F3DFF),
        type: CategoryType.transfer,
      ),
      date: DateTime.now(),
      currencyCode: ref.read(settingsProvider).currency,
      attachments: _attachments,
      fromPayee: _fromPayee,
      toPayee: _toPayee,
      type: TransactionType.transfer,
      isRepeat: _isRepeat,
      repeatFrequency: _isRepeat ? _repeatFrequency : null,
      repeatEndDate: _repeatEndDate,
    );

    if (mounted) {
      ref.read(transactionsProvider.notifier).addTransaction(transaction);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    const themeColor = Color(0xFF007AFF);
    final backgroundColor = isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight;
    final cardColor = isDarkMode ? AppTheme.cardDark : AppTheme.cardLight;
    final borderColor = isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final textColor = isDarkMode ? CupertinoColors.white : CupertinoColors.black;
    final secondaryTextColor = isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2;
    final currencySymbol = getCurrencySymbol(ref.watch(settingsProvider).currency);

    return CupertinoPageScaffold(
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
                  const Expanded(
                    child: Text(
                      'Transfer',
                      style: TextStyle(
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
          // Amount Section
          Padding(
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
                      currencySymbol,
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
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // From and To Row
                    Row(
                      children: [
                        // From
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _showPayeeSelection(true),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'From',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _fromPayee?.name ?? 'Bank',
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    color: secondaryTextColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Arrow Icon
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF7F3DFF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.arrow_right_arrow_left,
                              color: Color(0xFF7F3DFF),
                              size: 16,
                            ),
                          ),
                        ),
                        // To
                        Expanded(
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => _showPayeeSelection(false),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'To',
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: secondaryTextColor,
                                          ),
                                        ),
                                        if (_toPayee != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            _toPayee!.name,
                                            style: TextStyle(
                                              fontSize: 17,
                                              color: textColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_right,
                                    color: secondaryTextColor,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Description
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: CupertinoTextField(
                        controller: _descriptionController,
                        padding: const EdgeInsets.all(16),
                        placeholder: 'Description',
                        decoration: null,
                        style: TextStyle(color: textColor),
                        placeholderStyle: TextStyle(color: secondaryTextColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Add attachment
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: _attachments.isEmpty
                          ? CupertinoButton(
                              padding: const EdgeInsets.all(16),
                              onPressed: () async {
                                await HapticService.lightImpact(ref);
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
                                    color: textColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add attachment',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: textColor,
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
                                                color: cardColor,
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: borderColor),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  CupertinoIcons.add_circled,
                                                  size: 30,
                                                  color: textColor,
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
                    const SizedBox(height: 32),
                    // Add Repeat Switch before the Save button
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
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
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    _isRepeat 
                                        ? '${_repeatFrequency.name.substring(0, 1).toUpperCase()}${_repeatFrequency.name.substring(1)} until ${_repeatEndDate?.toString().split(' ')[0] ?? 'No end date'}'
                                        : 'Repeat transaction',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: secondaryTextColor,
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Continue Button
          Container(
            color: backgroundColor,
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).padding.bottom + 24,
              top: 16,
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 16),
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xFF7F3DFF),
              onPressed: _isValid ? _saveTransaction : null,
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
    );
  }
} 