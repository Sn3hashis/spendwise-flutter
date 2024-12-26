import 'package:flutter/cupertino.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'dart:math' as math;
import 'dart:io' show InternetAddress, SocketException;
import '../models/transaction_model.dart';
import '../../categories/models/category_model.dart';
import '../providers/transactions_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';
import 'dart:convert';

class SmsTransactionService {
  final SmsQuery _query = SmsQuery();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref;
  sqflite.Database? _database;

  SmsTransactionService(this.ref);

  Future<sqflite.Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<sqflite.Database> _initDatabase() async {
    final dbPath = await sqflite.getDatabasesPath();
    final path = join(dbPath, 'transactions.db');

    return await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pending_transactions(
            id TEXT PRIMARY KEY,
            data TEXT,
            messageId TEXT,
            synced INTEGER
          )
        ''');
      },
    );
  }

  Future<bool> requestSmsPermission() async {
    final permission = await Permission.sms.status;
    if (permission.isDenied) {
      final result = await Permission.sms.request();
      return result.isGranted;
    }
    return permission.isGranted;
  }

  Future<List<Transaction>> parseTransactionSms() async {
    if (!await requestSmsPermission()) {
      debugPrint('❌ SMS permission denied');
      throw 'SMS permission denied';
    }

    debugPrint('✅ SMS permission granted');
    final List<Transaction> transactions = [];
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    // Bank sender patterns
    final bankPatterns = [
      'HDFCBK',
      'ICICIT',
      'SBIUPI',
      'AXISBK',
      'IDFCFB',
      'YESBNK',
      'AD-SBI',
      'AD-ICI',
      'VM-HDFC',
      'AX-AXIS',
      'JD-AXIS',
      'VD-IDFC',
      'JX-YES',
      'VD-HDFC',
    ];

    debugPrint('🔍 Starting SMS scan for bank messages...');

    try {
      // Get all messages first
      final allMessages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 100, // Increase if needed
      );

      debugPrint('📨 Found ${allMessages.length} total messages');

      // Filter messages by bank patterns
      for (var message in allMessages) {
        if (message.address == null || message.body == null) continue;

        final address = message.address!.toUpperCase();
        final isFromBank =
            bankPatterns.any((pattern) => address.contains(pattern));

        if (isFromBank) {
          debugPrint('📱 Processing message from: ${message.address}');
          try {
            final transaction = await _parseMessageToTransaction(message);
            if (transaction != null) {
              final exists = await _checkTransactionExists(
                  user.uid, message.id.toString());
              if (!exists) {
                debugPrint(
                    '💰 New transaction found: ${transaction.amount} ${transaction.currencyCode} from ${message.address}');
                debugPrint('📝 Message body: ${message.body}');
                transactions.add(transaction);
              }
            }
          } catch (e) {
            debugPrint('⚠️ Error parsing message from ${message.address}: $e');
            continue;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error querying SMS: $e');
    }

    debugPrint(
        '✅ SMS scan complete. Found ${transactions.length} new transactions');
    return transactions;
  }

  Future<Transaction?> _parseMessageToTransaction(SmsMessage message) async {
    final messageBody = message.body?.toUpperCase() ?? '';

    // Enhanced patterns for Indian bank SMS
    final amountPattern = RegExp(r'(?:RS|INR)[.\s]*([0-9,]+\.?[0-9]*)');
    final debitPattern =
        RegExp(r'(?:DEBITED|PAID|SPENT|WITHDRAWN|DEBIT|DR|TXN)');
    final creditPattern = RegExp(r'(?:CREDITED|RECEIVED|CREDIT|CR)');
    final accountPattern =
        RegExp(r'(?:A/C\s*|ACCOUNT\s*|CARD\s*)[X\d]*(\d{4})');
    final upiPattern = RegExp(r'(?:UPI-|@|VPA\s*)[^\s/]*');
    final merchantPattern = RegExp(
        r'(?:AT|TO|FROM)\s+([^.]*?)(?=\s+(?:ON|BY|USING|REF|UPI|NEFT|IMPS|\.|\Z))');

    // Extract amount
    final amountMatch = amountPattern.firstMatch(messageBody);
    if (amountMatch == null) return null;

    final amountStr = amountMatch.group(1)?.replaceAll(',', '') ?? '0';
    final amount = double.tryParse(amountStr) ?? 0;
    if (amount == 0) return null;

    // Determine transaction type
    TransactionType type;
    if (debitPattern.hasMatch(messageBody)) {
      type = TransactionType.expense;
    } else if (creditPattern.hasMatch(messageBody)) {
      type = TransactionType.income;
    } else {
      return null;
    }

    // Extract description
    String description = '';
    final merchantMatch = merchantPattern.firstMatch(messageBody);
    final upiMatch = upiPattern.firstMatch(messageBody);

    if (merchantMatch != null) {
      description = merchantMatch.group(1)?.trim() ?? '';
    } else if (upiMatch != null) {
      description = upiMatch.group(0)?.trim() ?? '';
    }

    if (description.isEmpty) {
      description = type == TransactionType.expense ? 'Payment' : 'Received';
    }

    // Extract account/card number
    final accountMatch = accountPattern.firstMatch(messageBody);
    final accountNumber = accountMatch?.group(1) ?? '';

    debugPrint('💳 Parsed transaction: ${type.name} - $amount - $description');

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: type == TransactionType.expense ? -amount : amount,
      description: description,
      category: _getDefaultCategory(type),
      date: message.date ?? DateTime.now(),
      type: type,
      attachments: const [],
      currencyCode: 'INR',
      fromWallet: accountNumber.isNotEmpty ? 'XXXX$accountNumber' : null,
      updatedAt: DateTime.now(),
      note: messageBody,
      messageId: message.id.toString(),
    );

    await _storeTransactionLocally(transaction);
    return transaction;
  }

  Future<void> _storeTransactionLocally(Transaction transaction) async {
    final db = await database;
    final transactionMap = {
      'id': transaction.id,
      'data': jsonEncode(transaction.toJson()),
      'messageId': transaction.messageId,
      'synced': 0,
    };
    await db.insert(
      'pending_transactions',
      transactionMap,
      conflictAlgorithm: sqflite.ConflictAlgorithm.replace,
    );
  }

  Future<void> syncPendingTransactions() async {
    if (!await _hasInternetConnection()) return;

    final db = await database;
    final pending = await db.query(
      'pending_transactions',
      where: 'synced = ?',
      whereArgs: [0],
    );

    for (final record in pending) {
      try {
        final data =
            jsonDecode(record['data'] as String) as Map<String, dynamic>;
        final transaction = Transaction.fromJson(data);

        await ref
            .read(transactionsProvider.notifier)
            .addTransaction(transaction);

        await db.update(
          'pending_transactions',
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [record['id']],
        );
      } catch (e) {
        debugPrint('Error syncing transaction: $e');
      }
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Category _getDefaultCategory(TransactionType type) {
    return Category(
      id: const Uuid().v4(),
      name: type == TransactionType.expense ? 'Bank Expense' : 'Bank Income',
      description: 'Auto-categorized from bank SMS',
      icon: type == TransactionType.expense
          ? CupertinoIcons.money_dollar_circle
          : CupertinoIcons.money_dollar_circle_fill,
      color: type == TransactionType.expense
          ? const Color(0xFFFF3B30)
          : const Color(0xFF34C759),
      type: type == TransactionType.expense
          ? CategoryType.expense
          : CategoryType.income,
      isDefault: true,
    );
  }

  Future<bool> _checkTransactionExists(String userId, String messageId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('messageId', isEqualTo: messageId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> syncSmsTransactions() async {
    try {
      final transactions = await parseTransactionSms();
      final transactionsNotifier = ref.read(transactionsProvider.notifier);

      for (var transaction in transactions) {
        await transactionsNotifier.addTransaction(transaction);
      }

      debugPrint('Successfully synced ${transactions.length} SMS transactions');
    } catch (e) {
      debugPrint('Error syncing SMS transactions: $e');
      rethrow;
    }
  }
}

final smsTransactionServiceProvider = Provider((ref) {
  return SmsTransactionService(ref);
});
