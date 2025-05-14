import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final String userId;
  final bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.userId,
    this.isDefault = false,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      color: Color(data['color'] ?? 0xFF4CAF50),
      icon: IconData(data['iconCodePoint'] ?? 0xe25c, fontFamily: 'MaterialIcons'),
      userId: data['userId'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color.value,
      'iconCodePoint': icon.codePoint,
      'userId': userId,
      'isDefault': isDefault,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    String? userId,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      userId: userId ?? this.userId,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
