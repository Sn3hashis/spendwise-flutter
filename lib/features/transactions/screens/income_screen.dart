import 'package:flutter/cupertino.dart';
import '../models/transaction_type.dart';
import 'base_transaction_screen.dart';
import '../../categories/screens/categories_screen.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseTransactionScreen(type: TransactionType.income);
  }
} 