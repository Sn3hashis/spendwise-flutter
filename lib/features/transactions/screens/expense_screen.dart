import 'package:flutter/cupertino.dart';
import 'base_transaction_screen.dart';
import '../../categories/screens/categories_screen.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseTransactionScreen(type: TransactionType.expense);
  }
} 