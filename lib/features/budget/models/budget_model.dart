import 'package:flutter/material.dart';
import '../../categories/models/category_model.dart';

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

  bool isDateInPeriod(DateTime date) {
    return date.isAfter(startDate) && date.isBefore(endDate.add(const Duration(days: 1)));
  }

  bool isActive() {
    final now = DateTime.now();
    return isDateInPeriod(now);
  }
}

enum RecurringType {
  monthly,
  quarterly,
  yearly,
} 