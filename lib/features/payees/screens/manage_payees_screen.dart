import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../models/payee_model.dart';
import '../providers/payees_provider.dart';
import 'add_payee_screen.dart';
import 'payee_transactions_screen.dart';

class ManagePayeesScreen extends ConsumerWidget {
  const ManagePayeesScreen({super.key});

  Widget _buildPayeeItem(BuildContext context, WidgetRef ref, Payee payee, bool isDarkMode) {
    return Dismissible(
      key: Key(payee.id),
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
          return await _showDeleteConfirmation(context, ref, payee);
        } else {
          // Edit action
          await Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AddPayeeScreen(payee: payee),
            ),
          );
          return false; // Don't dismiss, just show edit screen
        }
      },
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => PayeeTransactionsScreen(payee: payee),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDarkMode 
                    ? const Color(0xFF2C2C2E) 
                    : const Color(0xFFE5E5EA),
              ),
            ),
          ),
          child: Row(
            children: [
              // User DP
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode 
                      ? CupertinoColors.systemGrey6.darkColor 
                      : CupertinoColors.systemGrey6,
                  image: payee.imageUrl != null
                      ? DecorationImage(
                          image: FileImage(File(payee.imageUrl!)),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            debugPrint('Error loading image: $exception');
                          },
                        )
                      : null,
                ),
                child: payee.imageUrl == null
                    ? Center(
                        child: Text(
                          payee.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Row(
                  children: [
                    // Name and Contact Info Column
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payee.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode 
                                  ? CupertinoColors.white 
                                  : CupertinoColors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (payee.email != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              payee.email!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode 
                                    ? CupertinoColors.systemGrey 
                                    : CupertinoColors.systemGrey2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (payee.phone != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              payee.phone!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode 
                                    ? CupertinoColors.systemGrey 
                                    : CupertinoColors.systemGrey2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Action Buttons Column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (payee.email != null)
                          CupertinoButton(
                            minSize: 0,
                            padding: const EdgeInsets.all(8),
                            onPressed: () {
                              // TODO: Handle email action
                            },
                            child: Icon(
                              CupertinoIcons.mail_solid,
                              size: 22,
                              color: isDarkMode 
                                  ? CupertinoColors.systemBlue 
                                  : CupertinoColors.activeBlue,
                            ),
                          ),
                        if (payee.phone != null)
                          CupertinoButton(
                            minSize: 0,
                            padding: const EdgeInsets.all(8),
                            onPressed: () {
                              // TODO: Handle WhatsApp action
                            },
                            child: Icon(
                              CupertinoIcons.chat_bubble_2_fill,
                              size: 22,
                              color: isDarkMode 
                                  ? CupertinoColors.systemGreen 
                                  : const Color(0xFF25D366),
                            ),
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
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, WidgetRef ref, Payee payee) async {
    bool delete = false;
    
    await showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Payee'),
        content: Text('Are you sure you want to delete ${payee.name}?'),
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

    if (delete && context.mounted) {
      _showDeletedMessage(context);
      
      // Delete after showing the success message
      await Future.delayed(const Duration(milliseconds: 600), () {
        if (context.mounted) {
          ref.read(payeesProvider.notifier).deletePayee(payee.id);
        }
      });
    }

    return delete;
  }

  void _showDeletedMessage(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CupertinoAlertDialog(
        title: Text('Success'),
        content: Text('Payee deleted successfully'),
      ),
    );

    // Auto dismiss after 500ms
    Timer(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final payees = ref.watch(payeesProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: const Text('Manage Payees'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const AddPayeeScreen(),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              height: screenWidth * 0.6,
              width: screenWidth,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Lottie.asset(
                'assets/animations/manage_payees.json',
                fit: BoxFit.fill,
                repeat: true,
                reverse: true,
                options: LottieOptions(
                  enableMergePaths: true,
                ),
              ),
            ),
            if (payees.isEmpty)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No payees added yet',
                      style: TextStyle(
                        fontSize: 17,
                        color: isDarkMode 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.systemGrey2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first payee',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDarkMode 
                            ? CupertinoColors.systemGrey 
                            : CupertinoColors.systemGrey2,
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: payees.length,
                  itemBuilder: (context, index) => _buildPayeeItem(
                    context,
                    ref,
                    payees[index],
                    isDarkMode,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 