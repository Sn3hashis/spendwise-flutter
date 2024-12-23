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
  final DateTime updatedAt;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    required this.currencyCode,
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
    DateTime? updatedAt,
  }) : this.updatedAt = updatedAt ?? DateTime.now();

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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': {
      ...category.toJson(),
      'icon': category.icon.codePoint.toString(), // Convert to string to ensure consistency
      'fontFamily': category.icon.fontFamily,
      'fontPackage': category.icon.fontPackage,
    },
    'budgetId': budgetId,
    'type': type.index,
    'attachments': attachments,
    'currencyCode': currencyCode,
    'fromWallet': fromWallet,
    'toWallet': toWallet,
    'isRepeat': isRepeat,
    'repeatFrequency': repeatFrequency?.index,
    'repeatEndDate': repeatEndDate?.toIso8601String(),
    'payeeId': payeeId,
    'fromPayee': fromPayee?.toJson(),
    'toPayee': toPayee?.toJson(),
    'note': note,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      final categoryJson = json['category'] as Map<String, dynamic>;
      
      // Handle icon data conversion
      IconData getIcon() {
        try {
          final iconData = categoryJson['icon'];
          if (iconData is int) {
            return IconData(
              iconData,
              fontFamily: categoryJson['fontFamily'] ?? 'CupertinoIcons',
              fontPackage: categoryJson['fontPackage'] ?? 'cupertino_icons',
            );
          } else if (iconData is String) {
            // Convert string to int if needed
            return IconData(
              int.parse(iconData),
              fontFamily: categoryJson['fontFamily'] ?? 'CupertinoIcons',
              fontPackage: categoryJson['fontPackage'] ?? 'cupertino_icons',
            );
          }
          return CupertinoIcons.money_dollar; // Fallback icon
        } catch (e) {
          debugPrint('Error parsing icon data: $e');
          return CupertinoIcons.money_dollar; // Fallback icon
        }
      }

      // Create category with proper icon handling
      final category = Category(
        id: categoryJson['id'] ?? '',
        name: categoryJson['name'] ?? '',
        description: categoryJson['description'] ?? '',
        icon: getIcon(),
        color: Color(categoryJson['color'] ?? 0xFF000000),
        type: CategoryType.values[categoryJson['type'] ?? 0],
        isDefault: categoryJson['isDefault'] ?? false,
      );

      return Transaction(
        id: json['id'] ?? '',
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] ?? '',
        category: category,
        date: DateTime.parse(json['date'] as String),
        type: TransactionType.values[json['type'] ?? 0],
        currencyCode: json['currencyCode'] ?? 'USD',
        attachments: List<String>.from(json['attachments'] ?? []),
        budgetId: json['budgetId'],
        fromPayee: json['fromPayee'] != null 
            ? Payee.fromJson(json['fromPayee']) 
            : null,
        toPayee: json['toPayee'] != null 
            ? Payee.fromJson(json['toPayee']) 
            : null,
        isRepeat: json['isRepeat'] ?? false,
        repeatFrequency: json['repeatFrequency'] != null 
            ? RepeatFrequency.values[json['repeatFrequency']] 
            : null,
        repeatEndDate: json['repeatEndDate'] != null 
            ? DateTime.parse(json['repeatEndDate']) 
            : null,
      );
    } catch (e) {
      debugPrint('Error parsing transaction: $e');
      rethrow;
    }
  }
}