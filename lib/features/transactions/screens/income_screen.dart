import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import 'base_transaction_screen.dart';
import '../../categories/screens/categories_screen.dart';

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BaseTransactionScreen(type: TransactionType.income);
  }
} 