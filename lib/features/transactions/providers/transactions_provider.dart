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
    debugPrint('[TransactionsNotifier] Initializing...');
    _loadFromLocal();
    
    // Listen to currency changes
    ref.listen<Currency>(currencyProvider, (previous, next) {
      if (previous?.code != next.code) {
        debugPrint('[TransactionsNotifier] Currency changed, reloading transactions...');
        _loadFromLocal();
      }
    });
  }

  Future<void> _loadFromLocal() async {
    try {
      debugPrint('[TransactionsNotifier] Loading transactions from local storage...');
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = prefs.getStringList('transactions') ?? [];
      
      state = transactionsJson
          .map((json) => Transaction.fromJson(jsonDecode(json)))
          .toList();
      
      debugPrint('[TransactionsNotifier] Loaded ${state.length} transactions from local storage');
      
      // After loading from local, try to sync with Firebase
      _syncWithFirebase();
    } catch (e) {
      debugPrint('[TransactionsNotifier] Error loading transactions from local: $e');
    }
  }

  Future<void> _saveToLocal() async {
    try {
      debugPrint('[TransactionsNotifier] Saving transactions to local storage...');
      final prefs = await SharedPreferences.getInstance();
      final transactionsJson = state
          .map((transaction) => jsonEncode(transaction.toJson()))
          .toList();
      
      await prefs.setStringList('transactions', transactionsJson);
      debugPrint('[TransactionsNotifier] Saved ${state.length} transactions to local storage');
    } catch (e) {
      debugPrint('[TransactionsNotifier] Error saving transactions to local: $e');
    }
  }

  Future<void> _syncWithFirebase() async {
    try {
      debugPrint('[TransactionsNotifier] Starting Firebase sync...');
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('[TransactionsNotifier] No user logged in, skipping Firebase sync');
        return;
      }

      // First, try to get any newer data from Firebase
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('updatedAt', descending: true)
          .get();

      debugPrint('[TransactionsNotifier] Found ${snapshot.docs.length} transactions in Firebase');

      // Create a map of local transactions by ID
      final localTransactions = Map.fromEntries(
        state.map((t) => MapEntry(t.id, t))
      );

      // Process Firebase transactions
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        final firebaseTransaction = Transaction.fromJson(data);
        
        // If transaction exists locally, keep the newer one based on updatedAt
        if (localTransactions.containsKey(firebaseTransaction.id)) {
          final localTransaction = localTransactions[firebaseTransaction.id]!;
          if (data['updatedAt'] != null && 
              (data['updatedAt'] as Timestamp).toDate().isAfter(localTransaction.updatedAt)) {
            localTransactions[firebaseTransaction.id] = firebaseTransaction;
          }
        } else {
          // If it doesn't exist locally, add it
          localTransactions[firebaseTransaction.id] = firebaseTransaction;
        }
      }

      // Update state with merged transactions
      state = localTransactions.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // Save merged state to local storage
      await _saveToLocal();

      // Now push our changes back to Firebase
      final batch = _firestore.batch();
      final transactionsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('transactions');

      for (var transaction in state) {
        final docRef = transactionsRef.doc(transaction.id);
        final data = {
          ...transaction.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        batch.set(docRef, data, SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('[TransactionsNotifier] Successfully completed Firebase sync');
    } catch (e) {
      debugPrint('[TransactionsNotifier] Error during Firebase sync: $e');
    }
  }

  Future<void> loadTransactions() async {
    await _loadFromLocal();
  }

  Future<void> addTransaction(Transaction transaction) async {
    debugPrint('[TransactionsNotifier] Adding new transaction...');
    state = [...state, transaction];
    
    // First save locally
    await _saveToLocal();
    
    // Then try to sync with Firebase in the background
    _syncWithFirebase();
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    debugPrint('[TransactionsNotifier] Updating transaction ${updatedTransaction.id}...');
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
    debugPrint('[TransactionsNotifier] Deleting transaction $id...');
    final updatedTransactions = state.where((transaction) => transaction.id != id).toList();
    state = updatedTransactions;
    
    // First save locally
    await _saveToLocal();
    
    // Then try to sync with Firebase in the background
    _syncWithFirebase();
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