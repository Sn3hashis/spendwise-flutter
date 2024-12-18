import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/haptic_service.dart';
import '../models/transaction_model.dart';
import '../models/transaction_type.dart';
import '../../../core/utils/currency_helper.dart';
import '../../../core/utils/date_helper.dart';
import '../widgets/attachment_viewer.dart';
import 'package:path/path.dart' as path;

class TransactionDetailsScreen extends ConsumerWidget {
  final Transaction transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  Widget _buildInfoRow(bool isDarkMode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.type.name.substring(0, 1).toUpperCase() +
                    transaction.type.name.substring(1),
                    style: TextStyle(
                      fontSize: 17,
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
            const SizedBox(width: 16),
            // Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category.name,
                    style: TextStyle(
                      fontSize: 17,
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
            const SizedBox(width: 16),
            // Wallet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode 
                          ? CupertinoColors.systemGrey 
                          : CupertinoColors.systemGrey2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.fromWallet ?? 'Default Wallet',
                    style: TextStyle(
                      fontSize: 17,
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
          ],
        ),
        const SizedBox(height: 16),
        // Dotted Divider
        Row(
          children: List.generate(150, (index) => Expanded(
            child: Container(
              color: index % 2 == 0 
                  ? Colors.transparent
                  : (isDarkMode 
                      ? const Color(0xFF2C2C2E) 
                      : const Color(0xFFE5E5EA)),
              height: 1,
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildAttachmentPreview(bool isDarkMode, String attachment) {
    final extension = path.extension(attachment).toLowerCase();
    
    if (extension == '.pdf') {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: isDarkMode 
              ? const Color(0xFF2C2C2E) 
              : const Color(0xFFE5E5EA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.doc_text_fill,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 8),
            Text(
              path.basename(attachment),
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode 
                    ? CupertinoColors.white 
                    : CupertinoColors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Image.file(
      File(attachment),
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  Widget _buildAttachments(BuildContext context, bool isDarkMode) {
    if (transaction.attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Attachment',
          style: TextStyle(
            fontSize: 17,
            color: isDarkMode 
                ? CupertinoColors.systemGrey 
                : CupertinoColors.systemGrey2,
          ),
        ),
        const SizedBox(height: 8),
        ...transaction.attachments.map((attachment) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => AttachmentViewer(
                    filePath: attachment,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildAttachmentPreview(isDarkMode, attachment),
            ),
          ),
        )).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final currencySymbol = getCurrencySymbol(transaction.currencyCode);
    final backgroundColor = switch (transaction.type) {
      TransactionType.income => const Color(0xFF00C853),
      TransactionType.expense => const Color(0xFFFF3B30),
      TransactionType.transfer => const Color(0xFF007AFF),
    };

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      child: Column(
        children: [
          // Header
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(
                      CupertinoIcons.back,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const Text(
                    'Detail Transaction',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      await HapticService.lightImpact(ref);
                      // TODO: Implement delete functionality
                    },
                    child: const Icon(
                      CupertinoIcons.trash,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Amount and Description
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
            child: Column(
              children: [
                Text(
                  '$currencySymbol${transaction.amount.abs()}',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontSize: 20,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatDateTime(transaction.date),
                  style: TextStyle(
                    fontSize: 17,
                    color: CupertinoColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Details
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(isDarkMode),
                    if (transaction.description.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 17,
                              color: isDarkMode 
                                  ? CupertinoColors.systemGrey 
                                  : CupertinoColors.systemGrey2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            transaction.description,
                            style: TextStyle(
                              fontSize: 17,
                              color: isDarkMode 
                                  ? CupertinoColors.white 
                                  : CupertinoColors.black,
                            ),
                          ),
                        ],
                      ),
                    _buildAttachments(context, isDarkMode),
                  ],
                ),
              ),
            ),
          ),
          // Edit Button
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
              color: backgroundColor,
              onPressed: () {
                // TODO: Navigate to edit screen
              },
              child: const Center(
                child: Text(
                  'Edit',
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