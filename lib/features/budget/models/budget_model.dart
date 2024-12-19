import 'package:flutter/material.dart';
import '../../categories/models/category_model.dart';
import 'dart:convert';

enum RecurringType {
  daily,
  weekly,
  monthly,
  yearly,
}

class Budget {
  final String id;
  final String name;
  final double amount;
  final double spent;
  final Category category;
  final DateTime startDate;
  final DateTime endDate;
  final double alertThreshold;
  final bool isRecurring;
  final RecurringType recurringType;
  final bool hasNotified;

  Budget({
    required this.id,
    required this.name,
    required this.amount,
    this.spent = 0.0,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.alertThreshold = 0.8,
    this.isRecurring = false,
    this.recurringType = RecurringType.monthly,
    this.hasNotified = false,
  });

  double get progress => spent / amount;
  bool get shouldNotify => progress >= alertThreshold && !hasNotified;

  bool isActive() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool isDateInPeriod(DateTime date) {
    return date.isAfter(startDate) && date.isBefore(endDate);
  }

  Budget copyWith({
    String? id,
    String? name,
    double? amount,
    double? spent,
    Category? category,
    DateTime? startDate,
    DateTime? endDate,
    double? alertThreshold,
    bool? isRecurring,
    RecurringType? recurringType,
    bool? hasNotified,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertThreshold: alertThreshold ?? this.alertThreshold,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      hasNotified: hasNotified ?? this.hasNotified,
    );
  }

  // Add fromJson constructor
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      alertThreshold: (json['alertThreshold'] as num?)?.toDouble() ?? 0.8,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringType: RecurringType.values.firstWhere(
        (type) => type.toString() == json['recurringType'],
        orElse: () => RecurringType.monthly,
      ),
      hasNotified: json['hasNotified'] as bool? ?? false,
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'category': category.toJson(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'alertThreshold': alertThreshold,
      'isRecurring': isRecurring,
      'recurringType': recurringType.toString(),
      'hasNotified': hasNotified,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 