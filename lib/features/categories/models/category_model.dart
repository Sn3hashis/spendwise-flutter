import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

enum CategoryType {
  income,
  expense,
  transfer,
}

class Category {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final CategoryType type;
  final bool isDefault;  // Important for identifying default categories

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,  // Default to false for user-created categories
  });

  // Determine if custom based on both isDefault and id
  bool get isCustom {
    // If isDefault is explicitly set, use that
    if (isDefault != null) return !isDefault!;
    
    // Otherwise, check if this is one of our known default category IDs
    const defaultIds = {
      // Income Categories
      'salary', 'freelance', 'investments', 'rental', 'business', 'other_income',
      // Expense Categories
      'food', 'transportation', 'housing', 'utilities', 'insurance', 'healthcare',
      'savings', 'entertainment', 'shopping', 'education', 'debt', 'other_expense',
      // Transfer Category
      'transfer'
    };
    return !defaultIds.contains(id);
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    IconData getIcon() {
      // Handle different icon storage formats
      if (json['icon'] is int) {
        return IconData(
          json['icon'],
          fontFamily: json['fontFamily'] ?? 'CupertinoIcons',
          fontPackage: json['fontPackage'] ?? 'cupertino_icons',
        );
      }
      // Fallback to default icon if something goes wrong
      return CupertinoIcons.money_dollar;
    }

    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: getIcon(),
      color: Color(json['color'] ?? 0xFF000000),
      type: CategoryType.values[json['type'] ?? 0],
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon.codePoint,  // Store icon as code point
    'fontFamily': icon.fontFamily,
    'fontPackage': icon.fontPackage,
    'color': color.value,
    'type': type.index,
    'isDefault': isDefault,
  };

  Category copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    CategoryType? type,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}