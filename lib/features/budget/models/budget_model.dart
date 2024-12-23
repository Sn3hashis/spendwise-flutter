import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../categories/models/category_model.dart';

import '../../transactions/models/transaction_model.dart';

class Budget {
  final String id;
  final String name;
  final String categoryId;
  final Category category;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final double spent;
  final bool isRecurring;
  final RepeatFrequency recurringType;
  final double alertThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.category,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.spent = 0,
    this.isRecurring = false,
    this.recurringType = RepeatFrequency.monthly,
    this.alertThreshold = 0.8,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'],
      category: Category.fromJson(json['category']),
      amount: json['amount'].toDouble(),
      startDate: _parseDateTime(json['startDate']),
      endDate: _parseDateTime(json['endDate']),
      spent: json['spent']?.toDouble() ?? 0.0,
      isRecurring: json['isRecurring'] ?? false,
      recurringType: RepeatFrequency.values[json['recurringType'] ?? 0],
      alertThreshold: json['alertThreshold']?.toDouble() ?? 0.8,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'categoryId': categoryId,
    'category': category.toJson(),
    'amount': amount,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'spent': spent,
    'isRecurring': isRecurring,
    'recurringType': recurringType.index,
    'alertThreshold': alertThreshold,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  Budget copyWith({
    String? id,
    String? name,
    String? categoryId,
    Category? category,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    double? spent,
    bool? isRecurring,
    RepeatFrequency? recurringType,
    double? alertThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      spent: spent ?? this.spent,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isActive() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool isDateInPeriod(DateTime date) {
    return date.isAfter(startDate) && date.isBefore(endDate);
  }

  double getCurrentProgress() {
    return spent / amount;
  }

  String getSpentAmount(List<dynamic> transactions) {
    final matchingTransactions = transactions.where((t) => 
      t.category.id == categoryId &&
      isDateInPeriod(t.date)
    );
    
    final totalSpent = matchingTransactions.fold<double>(
      0, 
      (sum, t) => sum + t.amount
    );
    
    return totalSpent.toStringAsFixed(2);
  }
}