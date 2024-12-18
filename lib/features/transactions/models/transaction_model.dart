import 'package:flutter/material.dart';
import '../../categories/models/category_model.dart';
import 'transaction_type.dart';
import 'repeat_frequency.dart';

class Transaction {
  final String id;
  final double amount;
  final String description;
  final Category category;
  final DateTime date;
  final String currencyCode;
  final List<String> attachments;
  final String? fromWallet;
  final String? toWallet;
  final TransactionType type;
  final bool isRepeat;
  final RepeatFrequency? repeatFrequency;
  final DateTime? repeatEndDate;

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.currencyCode,
    required this.attachments,
    this.fromWallet,
    this.toWallet,
    required this.type,
    this.isRepeat = false,
    this.repeatFrequency,
    this.repeatEndDate,
  });

  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    Category? category,
    DateTime? date,
    String? currencyCode,
    List<String>? attachments,
    String? fromWallet,
    String? toWallet,
    TransactionType? type,
    bool? isRepeat,
    RepeatFrequency? repeatFrequency,
    DateTime? repeatEndDate,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      currencyCode: currencyCode ?? this.currencyCode,
      attachments: attachments ?? this.attachments,
      fromWallet: fromWallet ?? this.fromWallet,
      toWallet: toWallet ?? this.toWallet,
      type: type ?? this.type,
      isRepeat: isRepeat ?? this.isRepeat,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
      repeatEndDate: repeatEndDate ?? this.repeatEndDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'description': description,
    'category': category.toJson(),
    'date': date.toIso8601String(),
    'currencyCode': currencyCode,
    'attachments': attachments,
    'fromWallet': fromWallet,
    'toWallet': toWallet,
    'type': type.toString(),
    'isRepeat': isRepeat,
    'repeatFrequency': repeatFrequency?.toString(),
    'repeatEndDate': repeatEndDate?.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    amount: json['amount'] as double,
    description: json['description'] as String,
    category: Category.fromJson(json['category'] as Map<String, dynamic>),
    date: DateTime.parse(json['date'] as String),
    currencyCode: json['currencyCode'] as String,
    attachments: List<String>.from(json['attachments'] as List),
    fromWallet: json['fromWallet'] as String?,
    toWallet: json['toWallet'] as String?,
    type: TransactionType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
    isRepeat: json['isRepeat'] as bool,
    repeatFrequency: RepeatFrequency.values[json['repeatFrequency'] as int],
    repeatEndDate: json['repeatEndDate'] != null ? DateTime.parse(json['repeatEndDate'] as String) : null,
  );
} 