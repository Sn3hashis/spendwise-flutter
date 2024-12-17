import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum CategoryType { income, expense }

class Category {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final CategoryType type;
  final bool isCustom;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.isCustom = false,
  });

  Category copyWith({
    String? name,
    String? description,
    IconData? icon,
    Color? color,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type,
      isCustom: isCustom,
    );
  }
} 