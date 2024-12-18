import 'package:flutter/material.dart';

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
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    CategoryType? type,
    bool? isCustom,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon.codePoint,
    'color': color.value,
    'type': type.toString(),
    'isCustom': isCustom,
  };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    icon: IconData(json['icon'] as int, fontFamily: 'CupertinoIcons'),
    color: Color(json['color'] as int),
    type: CategoryType.values.firstWhere(
      (e) => e.toString() == json['type'],
    ),
    isCustom: json['isCustom'] as bool? ?? false,
  );
} 