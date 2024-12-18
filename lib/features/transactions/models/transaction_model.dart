import 'package:flutter/material.dart';
import '../../categories/models/category_model.dart';
import '../../payees/models/payee_model.dart';

enum TransactionType {
  income,
  expense,
  transfer,
}

enum RepeatFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final Category category;
  final String? budgetId;
  final TransactionType type;
  final List<String> attachments;
  final String currencyCode;
  final String? fromWallet;
  final String? toWallet;
  final bool isRepeat;
  final RepeatFrequency? repeatFrequency;
  final DateTime? repeatEndDate;
  final String? payeeId;
  final Payee? fromPayee;
  final Payee? toPayee;
  final String? note;

  const Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.currencyCode,
    required this.type,
    this.budgetId,
    this.attachments = const [],
    this.fromWallet,
    this.toWallet,
    this.isRepeat = false,
    this.repeatFrequency,
    this.repeatEndDate,
    this.payeeId,
    this.fromPayee,
    this.toPayee,
    this.note,
  });

  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    Category? category,
    String? budgetId,
    TransactionType? type,
    List<String>? attachments,
    String? currencyCode,
    String? fromWallet,
    String? toWallet,
    bool? isRepeat,
    RepeatFrequency? repeatFrequency,
    DateTime? repeatEndDate,
    String? payeeId,
    Payee? fromPayee,
    Payee? toPayee,
    String? note,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      budgetId: budgetId ?? this.budgetId,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      currencyCode: currencyCode ?? this.currencyCode,
      fromWallet: fromWallet ?? this.fromWallet,
      toWallet: toWallet ?? this.toWallet,
      isRepeat: isRepeat ?? this.isRepeat,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
      repeatEndDate: repeatEndDate ?? this.repeatEndDate,
      payeeId: payeeId ?? this.payeeId,
      fromPayee: fromPayee ?? this.fromPayee,
      toPayee: toPayee ?? this.toPayee,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category.toJson(),
    'budgetId': budgetId,
    'type': type.toString(),
    'attachments': attachments,
    'currencyCode': currencyCode,
    'fromWallet': fromWallet,
    'toWallet': toWallet,
    'isRepeat': isRepeat,
    'repeatFrequency': repeatFrequency?.toString(),
    'repeatEndDate': repeatEndDate?.toIso8601String(),
    'payeeId': payeeId,
    'fromPayee': fromPayee?.toJson(),
    'toPayee': toPayee?.toJson(),
    'note': note,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    description: json['description'] as String,
    amount: json['amount'] as double,
    date: DateTime.parse(json['date'] as String),
    category: Category.fromJson(json['category'] as Map<String, dynamic>),
    currencyCode: json['currencyCode'] as String,
    type: TransactionType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
    budgetId: json['budgetId'] as String?,
    attachments: List<String>.from(json['attachments'] as List),
    fromWallet: json['fromWallet'] as String?,
    toWallet: json['toWallet'] as String?,
    isRepeat: json['isRepeat'] as bool? ?? false,
    repeatFrequency: json['repeatFrequency'] != null 
        ? RepeatFrequency.values.firstWhere(
            (e) => e.toString() == json['repeatFrequency'],
          )
        : null,
    repeatEndDate: json['repeatEndDate'] != null 
        ? DateTime.parse(json['repeatEndDate'] as String) 
        : null,
    payeeId: json['payeeId'] as String?,
    fromPayee: json['fromPayee'] != null 
        ? Payee.fromJson(json['fromPayee'] as Map<String, dynamic>) 
        : null,
    toPayee: json['toPayee'] != null 
        ? Payee.fromJson(json['toPayee'] as Map<String, dynamic>) 
        : null,
    note: json['note'] as String?,
  );
} 