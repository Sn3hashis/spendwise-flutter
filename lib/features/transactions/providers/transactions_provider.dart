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
  
  TransactionsNotifier(this.ref) : super([]) {
    _loadTransactions();
    
    // Listen to currency changes
    ref.listen<Currency>(currencyProvider, (previous, next) {
      if (previous?.code != next.code) {
        _loadTransactions();
      }
    });
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList('transactions') ?? [];
    
    state = transactionsJson
        .map((json) => Transaction.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions
        .map((transaction) => jsonEncode(transaction.toJson()))
        .toList()
        .cast<String>();
    
    await prefs.setStringList('transactions', transactionsJson);
    
    // Sync with Firebase in the background
    _syncWithFirebase(transactions);
  }

  Future<void> _syncWithFirebase(List<Transaction> transactions) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get the batch reference
      final batch = _firestore.batch();
      
      // Reference to user's transactions subcollection
      final userTransactionsRef = _firestore
          .collection('transactions')
          .doc(user.uid)
          .collection('user_transactions');

      // Delete all existing transactions first
      final existingDocs = await userTransactionsRef.get();
      for (var doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      // Add all current transactions
      for (var transaction in transactions) {
        final docRef = userTransactionsRef.doc(transaction.id);
        batch.set(docRef, {
          ...transaction.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Commit the batch
      await batch.commit();
    } catch (e) {
      debugPrint('Error syncing transactions with Firebase: $e');
      // Don't throw - this is background sync
    }
  }

  Future<void> restoreTransactionsFromFirebase() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await _firestore
          .collection('transactions')
          .doc(user.uid)
          .collection('user_transactions')
          .get();

      final transactions = snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();

      // Update local storage and state
      state = transactions;
      await _saveTransactions(transactions);
    } catch (e) {
      debugPrint('Error restoring transactions from Firebase: $e');
      // Don't throw - fall back to local data
    }
  }

  void addTransaction(Transaction transaction) {
    final currentCurrency = ref.read(currencyProvider).code;
    final updatedTransaction = transaction.copyWith(
      currencyCode: currentCurrency,
    );
    final updatedTransactions = [...state, updatedTransaction];
    
    state = updatedTransactions;
    _saveTransactions(updatedTransactions);
  }

  void deleteTransaction(String id) {
    final updatedTransactions = state.where((transaction) => 
      transaction.id != id
    ).toList();
    
    state = updatedTransactions;
    _saveTransactions(updatedTransactions);
  }

  void updateTransaction(Transaction updatedTransaction) {
    final updatedTransactions = state.map((transaction) => 
      transaction.id == updatedTransaction.id 
          ? updatedTransaction 
          : transaction
    ).toList();
    
    state = updatedTransactions;
    _saveTransactions(updatedTransactions);
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
    );
  }
}

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  return TransactionsNotifier(ref);
}); 