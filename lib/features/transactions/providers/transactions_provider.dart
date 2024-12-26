import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/transaction_model.dart';
import '../../categories/models/category_model.dart';
import '../../../core/providers/currency_provider.dart';
import '../../../core/models/currency_model.dart';
import '../../../core/utils/currency_converter.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' hide Category;

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Ref ref;
  final Set<String> _deletedIds = {};
  bool _isInitialized = false;

  TransactionsNotifier(this.ref) : super([]) {
    debugPrint('[TransactionsNotifier] Initializing...');
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    await _loadDeletedIds();
    await loadTransactions();
    _isInitialized = true;
  }

  Future<void> loadTransactions() async {
    try {
      debugPrint('[TransactionsNotifier] Loading transactions...');
      await _loadFromLocal();
      await _syncWithFirebase();
    } catch (e) {
      debugPrint('[TransactionsNotifier] Error loading transactions: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      debugPrint('[TransactionsNotifier] Loading from local storage...');
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getStringList('transactions') ?? [];

      if (transactionsJson.isEmpty) {
        debugPrint('[TransactionsNotifier] No local transactions found');
        return;
      }

      final loadedTransactions = transactionsJson
          .map((json) => Transaction.fromJson(jsonDecode(json)))
          .where((transaction) => !_deletedIds.contains(transaction.id))
          .toList();

      state = loadedTransactions;
      debugPrint(
          '[TransactionsNotifier] Loaded ${state.length} local transactions');
    } catch (e) {
      debugPrint('[TransactionsNotifier] Error loading from local: $e');
    }
  }

  Future<void> _syncWithFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('[TransactionsNotifier] No user logged in');
        return;
      }

      debugPrint('[TransactionsNotifier] Starting Firebase sync...');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .get();

      final firebaseTransactions = <Transaction>[];

      for (var doc in snapshot.docs) {
        try {
          if (!_deletedIds.contains(doc.id)) {
            final data = doc.data();
            data['id'] = doc.id; // Ensure ID is included
            final transaction = Transaction.fromJson(data);
            firebaseTransactions.add(transaction);
          }
        } catch (e) {
          debugPrint(
              '[TransactionsNotifier] Error parsing transaction ${doc.id}: $e');
          continue;
        }
      }

      debugPrint(
          '[TransactionsNotifier] Found ${firebaseTransactions.length} Firebase transactions');

      // Create a map of transactions by ID for easier merging
      final transactionMap = {
        for (var t in [...state, ...firebaseTransactions]) t.id: t
      };

      state = transactionMap.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      await _saveToLocal();
      debugPrint(
          '[TransactionsNotifier] Sync complete. Total transactions: ${state.length}');
    } catch (e, stackTrace) {
      debugPrint('[TransactionsNotifier] Firebase sync error: $e');
      debugPrint(stackTrace.toString());
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      state = [...state, transaction];
      await _saveToLocal();

      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(transaction.id)
            .set(transaction.toJson());
      }
    } catch (e) {
      debugPrint('[TransactionsNotifier] Error adding transaction: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      debugPrint('[TransactionsNotifier] Saving to local storage...');
      final prefs = await SharedPreferences.getInstance();

      final transactionsJson =
          state.map((transaction) => jsonEncode(transaction.toJson())).toList();

      await prefs.setStringList('transactions', transactionsJson);
      debugPrint(
          '[TransactionsNotifier] Saved ${state.length} transactions locally');
    } catch (e) {
      debugPrint('[TransactionsNotifier] Error saving to local: $e');
    }
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    debugPrint(
        '[TransactionsNotifier] Updating transaction ${updatedTransaction.id}...');
    final updatedTransactions = state.map((transaction) {
      return transaction.id == updatedTransaction.id
          ? updatedTransaction
          : transaction;
    }).toList();

    state = updatedTransactions;

    // First save locally
    await _saveToLocal();

    // Then try to sync with Firebase in the background
    _syncWithFirebase();
  }

  Future<void> deleteTransaction(String id) async {
    try {
      debugPrint('[TransactionsNotifier] Deleting transaction $id...');
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .doc(id)
            .delete();
      }

      // Add to deleted IDs set and save
      _deletedIds.add(id);
      await _saveDeletedIds();

      // Update local state
      final updatedTransactions = state.where((t) => t.id != id).toList();
      state = updatedTransactions;
      await _saveToLocal();
      debugPrint('[TransactionsNotifier] Successfully deleted transaction');
    } catch (e) {
      debugPrint('[TransactionsNotifier] Error deleting transaction: $e');
    }
  }

  Future<void> _loadDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = prefs.getStringList('deleted_transactions') ?? [];
    _deletedIds.addAll(deletedIds);
  }

  Future<void> _saveDeletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('deleted_transactions', _deletedIds.toList());
  }

  Transaction createTransaction({
    required double amount,
    required String description,
    required Category category,
    required DateTime date,
    String? note,
  }) {
    final currentCurrency = ref.read(currencyProvider).code;

    return Transaction(
      id: DateTime.now().toString(),
      amount: amount,
      description: description,
      category: category,
      date: date,
      note: note,
      currencyCode: currentCurrency,
      type: amount < 0 ? TransactionType.expense : TransactionType.income,
      attachments: const [],
      updatedAt: DateTime.now(),
    );
  }

  Future<void> syncWithFirebase() => _syncWithFirebase();
}

final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier(ref);
});
