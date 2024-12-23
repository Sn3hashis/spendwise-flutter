import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../categories/models/category_model.dart';

import '../../transactions/models/transaction_model.dart';

enum BudgetType {
  expense,
  income
}

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
  final BudgetType type;
  final String notes;

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
    required this.type,
    this.notes = '',
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
    try {
      // Validate required fields
      if (json['id'] == null || json['categoryId'] == null || json['category'] == null) {
        throw Exception('Missing required fields');
      }

      // Determine budget type from either stored type or category type
      BudgetType determineBudgetType(Map<String, dynamic> json) {
        if (json['type'] != null) {
          return BudgetType.values[json['type'] as int];
        }
        
        if (json['category'] != null) {
          final category = Category.fromJson(json['category']);
          return category.type == CategoryType.income 
              ? BudgetType.income 
              : BudgetType.expense;
        }
        
        return BudgetType.expense;
      }

      return Budget(
        id: json['id'],
        name: json['name'] ?? 'Untitled Budget',
        categoryId: json['categoryId'],
        category: Category.fromJson(json['category']),
        amount: (json['amount'] ?? 0).toDouble(),
        startDate: _parseDateTime(json['startDate'] ?? DateTime.now()),
        endDate: _parseDateTime(json['endDate'] ?? DateTime.now()),
        spent: (json['spent'] ?? 0).toDouble(),
        isRecurring: json['isRecurring'] ?? false,
        recurringType: RepeatFrequency.values[json['recurringType'] ?? 0],
        alertThreshold: (json['alertThreshold'] ?? 0.8).toDouble(),
        createdAt: _parseDateTime(json['createdAt'] ?? DateTime.now()),
        updatedAt: _parseDateTime(json['updatedAt'] ?? DateTime.now()),
        type: determineBudgetType(json),
        notes: json['notes'] ?? '',
      );
    } catch (e) {
      throw Exception('Invalid budget data: $e');
    }
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
    'type': type.index,
    'notes': notes,
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
    BudgetType? type,
    String? notes,
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
      type: type ?? this.type,
      notes: notes ?? this.notes,
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

  bool isGoal() {
    return isRecurring;
  }
}