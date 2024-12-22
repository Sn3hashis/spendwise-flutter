import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
  final bool? isDefault;

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

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: IconData(
        json['icon'] as int,
        fontFamily: json['iconFontFamily'] as String?,
        fontPackage: json['iconFontPackage'] as String?,
      ),
      color: Color(json['color'] as int),
      type: CategoryType.values.firstWhere(
        (type) => type.toString() == json['type'],
        orElse: () => CategoryType.expense,
      ),
      isDefault: json['isDefault'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon.codePoint,
    'iconFontFamily': icon.fontFamily,
    'iconFontPackage': icon.fontPackage,
    'color': color.value,
    'type': type.toString(),
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