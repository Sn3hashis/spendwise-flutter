import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final double amount;
  final String description;
  final Category category;
  final DateTime date;
  final TransactionType type;
  final List<String> attachments;
  final String currencyCode;
  final String? fromWallet;
  final String? toWallet;
  final DateTime updatedAt;
  final String? note;
  final String? messageId;
  final String? payeeId;
  final Payee? fromPayee;
  final Payee? toPayee;
  final bool isRepeat;
  final RepeatFrequency? repeatFrequency;
  final DateTime? repeatEndDate;
  final String? budgetId;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.type,
    required this.attachments,
    required this.currencyCode,
    this.fromWallet,
    this.toWallet,
    required this.updatedAt,
    this.note,
    this.messageId,
    this.payeeId,
    this.fromPayee,
    this.toPayee,
    this.isRepeat = false,
    this.repeatFrequency,
    this.repeatEndDate,
    this.budgetId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category': category.toJson(),
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'attachments': attachments,
      'currencyCode': currencyCode,
      'fromWallet': fromWallet,
      'toWallet': toWallet,
      'updatedAt': updatedAt.toIso8601String(),
      'note': note,
      'messageId': messageId,
      'payeeId': payeeId,
      'fromPayee': fromPayee?.toJson(),
      'toPayee': toPayee?.toJson(),
      'isRepeat': isRepeat,
      'repeatFrequency': repeatFrequency?.toString().split('.').last,
      'repeatEndDate': repeatEndDate?.toIso8601String(),
      'budgetId': budgetId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      return Transaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String,
        category: Category.fromJson(json['category'] as Map<String, dynamic>),
        date: (json['date'] is Timestamp)
            ? (json['date'] as Timestamp).toDate()
            : DateTime.parse(json['date'] as String),
        type: TransactionType.values.firstWhere(
          (e) => e.toString() == 'TransactionType.${json['type']}',
          orElse: () => TransactionType.expense,
        ),
        attachments:
            (json['attachments'] as List<dynamic>?)?.cast<String>() ?? [],
        currencyCode: json['currencyCode'] as String? ?? 'INR',
        fromWallet: json['fromWallet'] as String?,
        toWallet: json['toWallet'] as String?,
        updatedAt: (json['updatedAt'] is Timestamp)
            ? (json['updatedAt'] as Timestamp).toDate()
            : DateTime.parse(json['updatedAt'] as String),
        note: json['note'] as String?,
        messageId: json['messageId'] as String?,
        payeeId: json['payeeId'] as String?,
        fromPayee: json['fromPayee'] != null
            ? Payee.fromJson(json['fromPayee'] as Map<String, dynamic>)
            : null,
        toPayee: json['toPayee'] != null
            ? Payee.fromJson(json['toPayee'] as Map<String, dynamic>)
            : null,
        isRepeat: json['isRepeat'] as bool? ?? false,
        repeatFrequency: json['repeatFrequency'] != null
            ? RepeatFrequency.values.firstWhere(
                (e) =>
                    e.toString() ==
                    'RepeatFrequency.${json['repeatFrequency']}',
                orElse: () => RepeatFrequency.monthly,
              )
            : null,
        repeatEndDate: json['repeatEndDate'] != null
            ? (json['repeatEndDate'] is Timestamp)
                ? (json['repeatEndDate'] as Timestamp).toDate()
                : DateTime.parse(json['repeatEndDate'] as String)
            : null,
        budgetId: json['budgetId'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing transaction: $e');
      rethrow;
    }
  }

  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    Category? category,
    DateTime? date,
    TransactionType? type,
    List<String>? attachments,
    String? currencyCode,
    String? fromWallet,
    String? toWallet,
    DateTime? updatedAt,
    String? note,
    String? messageId,
    String? payeeId,
    Payee? fromPayee,
    Payee? toPayee,
    bool? isRepeat,
    RepeatFrequency? repeatFrequency,
    DateTime? repeatEndDate,
    String? budgetId,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
      attachments: attachments ?? this.attachments,
      currencyCode: currencyCode ?? this.currencyCode,
      fromWallet: fromWallet ?? this.fromWallet,
      toWallet: toWallet ?? this.toWallet,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
      messageId: messageId ?? this.messageId,
      payeeId: payeeId ?? this.payeeId,
      fromPayee: fromPayee ?? this.fromPayee,
      toPayee: toPayee ?? this.toPayee,
      isRepeat: isRepeat ?? this.isRepeat,
      repeatFrequency: repeatFrequency ?? this.repeatFrequency,
      repeatEndDate: repeatEndDate ?? this.repeatEndDate,
      budgetId: budgetId ?? this.budgetId,
    );
  }
}
