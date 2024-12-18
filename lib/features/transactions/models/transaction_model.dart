import 'package:flutter/material.dart';
import '../../categories/models/category_model.dart';
import 'transaction_type.dart';
import 'repeat_frequency.dart';
import '../../payees/models/payee_model.dart';

class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final Category category;
  final List<String> attachments;
  final String currencyCode;
  final String? fromWallet;
  final String? toWallet;
  final TransactionType type;
  final bool isRepeat;
  final RepeatFrequency? repeatFrequency;
  final DateTime? repeatEndDate;
  final String? payeeId;
  final Payee? fromPayee;
  final Payee? toPayee;
  final String? note;

  const Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.category,
    required this.currencyCode,
    required this.type,
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
    double? amount,
    DateTime? date,
    String? description,
    Category? category,
    String? currencyCode,
    TransactionType? type,
    List<String>? attachments,
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
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      currencyCode: currencyCode ?? this.currencyCode,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
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
    'amount': amount,
    'date': date.toIso8601String(),
    'description': description,
    'category': category.toJson(),
    'currencyCode': currencyCode,
    'type': type.toString(),
    'attachments': attachments,
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
    amount: json['amount'] as double,
    date: DateTime.parse(json['date'] as String),
    description: json['description'] as String,
    category: Category.fromJson(json['category'] as Map<String, dynamic>),
    currencyCode: json['currencyCode'] as String,
    type: TransactionType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
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
    fromPayee: json['fromPayee'] != null ? Payee.fromJson(json['fromPayee'] as Map<String, dynamic>) : null,
    toPayee: json['toPayee'] != null ? Payee.fromJson(json['toPayee'] as Map<String, dynamic>) : null,
    note: json['note'] as String?,
  );
} 