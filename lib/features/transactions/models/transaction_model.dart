import 'package:flutter/material.dart';
import '../../categories/models/category_model.dart';
import 'repeat_frequency.dart';

class Transaction {
  final String id;
  final double amount;
  final String description;
  final Category category;
  final DateTime date;
  final List<String> attachments;
  final bool isRepeat;
  final RepeatFrequency? repeatFrequency;
  final DateTime? repeatEndDate;
  final String currencyCode;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.currencyCode,
    this.attachments = const [],
    this.isRepeat = false,
    this.repeatFrequency,
    this.repeatEndDate,
  });
} 