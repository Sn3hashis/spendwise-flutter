import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../categories/models/category_model.dart';

enum RecurringType {
  daily,
  weekly,
  monthly,
  yearly,
}

@immutable
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
  final DateTime updatedAt;

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
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

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
    DateTime? updatedAt,
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
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    try {
      final categoryData = json['category'] as Map<String, dynamic>?;
      if (categoryData == null) {
        throw Exception('Category data is missing in budget JSON');
      }

      final startDateData = json['startDate'];
      final endDateData = json['endDate'];
      final updatedAtData = json['updatedAt'];

      final DateTime startDate;
      final DateTime endDate;
      final DateTime updatedAt;

      if (startDateData is Timestamp) {
        startDate = startDateData.toDate();
      } else if (startDateData is String) {
        startDate = DateTime.parse(startDateData);
      } else {
        startDate = DateTime.now();
      }

      if (endDateData is Timestamp) {
        endDate = endDateData.toDate();
      } else if (endDateData is String) {
        endDate = DateTime.parse(endDateData);
      } else {
        endDate = DateTime.now().add(const Duration(days: 30)); // Default to 30 days
      }

      if (updatedAtData is Timestamp) {
        updatedAt = updatedAtData.toDate();
      } else if (updatedAtData is String) {
        updatedAt = DateTime.parse(updatedAtData);
      } else {
        updatedAt = DateTime.now();
      }

      return Budget(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
        category: Category.fromJson(categoryData),
        startDate: startDate,
        endDate: endDate,
        alertThreshold: (json['alertThreshold'] as num?)?.toDouble() ?? 0.8,
        isRecurring: json['isRecurring'] as bool? ?? false,
        recurringType: json['recurringType'] != null
            ? RecurringType.values.firstWhere(
                (type) => type.toString() == json['recurringType'],
                orElse: () => RecurringType.monthly,
              )
            : RecurringType.monthly,
        hasNotified: json['hasNotified'] as bool? ?? false,
        updatedAt: updatedAt,
      );
    } catch (e) {
      debugPrint('[Budget.fromJson] Error parsing budget: $e');
      debugPrint('[Budget.fromJson] JSON data: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'Budget(id: $id, name: $name, amount: $amount, spent: $spent, category: ${category.name}, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.name == name &&
        other.amount == amount &&
        other.spent == spent &&
        other.category == category &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.alertThreshold == alertThreshold &&
        other.isRecurring == isRecurring &&
        other.recurringType == recurringType &&
        other.hasNotified == hasNotified &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      amount,
      spent,
      category,
      startDate,
      endDate,
      alertThreshold,
      isRecurring,
      recurringType,
      hasNotified,
      updatedAt,
    );
  }
}