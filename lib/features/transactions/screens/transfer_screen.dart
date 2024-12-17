import 'package:flutter/cupertino.dart';
import 'base_transaction_screen.dart';

class TransferScreen extends StatelessWidget {
  const TransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BaseTransactionScreen(type: TransactionType.transfer);
  }
} 