import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CategoryType { income, expense }

class Category {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final String userId;
  final bool isDefault;
  final CategoryType type;

  Category({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.userId,
    this.isDefault = false,
    required this.type,
  });

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      color: Color(data['color'] ?? 0xFF4CAF50),
      icon: _getIconFromCodePoint(data['iconCodePoint'] ?? 0xe25c),
      userId: data['userId'] ?? '',
      isDefault: data['isDefault'] ?? false,
      type:
          data['type'] == 'income' ? CategoryType.income : CategoryType.expense,
    );
  }

  // Static method to safely get IconData from codePoint
  static IconData _getIconFromCodePoint(int codePoint) {
    // Map of common icon code points to ensure they're available
    const Map<int, IconData> iconMap = {
      // Material Icons - Common icons
      0xe25c: Icons.category,
      0xe56c: Icons.restaurant,
      0xe1a3: Icons.directions_car,
      0xe02f: Icons.movie,
      0xe8b0: Icons.receipt,
      0xe59c: Icons.shopping_bag,
      0xe3f0: Icons.local_hospital,
      0xe80c: Icons.school,
      0xe263: Icons.attach_money,
      0xe1b1: Icons.card_giftcard,
      0xe8e5: Icons.trending_up,
      0xe8f9: Icons.work,
      0xe5d3: Icons.more_horiz,
      0xe88a: Icons.home,
      0xe59d: Icons.shopping_cart,
      0xe1a5: Icons.local_grocery_store,
      0xe539: Icons.flight,
      0xe549: Icons.hotel,
      0xe227: Icons.account_balance,
      0xe870: Icons.credit_card,
      0xe5d9: Icons.local_laundry_service,
      0xe91d: Icons.pets,
      0xe322: Icons.child_care,
      0xe56d: Icons.local_bar,
      0xe56e: Icons.local_cafe,
      0xe571: Icons.local_mall,
      0xe572: Icons.local_pharmacy,
      0xe8cc: Icons.sports_basketball,
    };

    // Return mapped icon or default category icon
    return iconMap[codePoint] ?? Icons.category;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color.value,
      'iconCodePoint': icon.codePoint,
      'userId': userId,
      'isDefault': isDefault,
      'type': type == CategoryType.income ? 'income' : 'expense',
    };
  }

  Category copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    String? userId,
    bool? isDefault,
    CategoryType? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      userId: userId ?? this.userId,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
    );
  }
}

// Helper class for predefined categories with safe icons
class CategoryHelper {
  static const List<Map<String, dynamic>> defaultExpenseCategories = [
    {
      'name': 'Makanan',
      'color': 0xFFE57373, // Colors.red
      'icon': Icons.restaurant,
      'type': 'expense',
    },
    {
      'name': 'Transportasi',
      'color': 0xFF134B70, // secondaryColor
      'icon': Icons.directions_car,
      'type': 'expense',
    },
    {
      'name': 'Hiburan',
      'color': 0xFF9C27B0, // Colors.purple
      'icon': Icons.movie,
      'type': 'expense',
    },
    {
      'name': 'Tagihan',
      'color': 0xFFFF9800, // Colors.orange
      'icon': Icons.receipt,
      'type': 'expense',
    },
    {
      'name': 'Belanja',
      'color': 0xFFE91E63, // Colors.pink
      'icon': Icons.shopping_bag,
      'type': 'expense',
    },
    {
      'name': 'Kesehatan',
      'color': 0xFF508C9B, // accentColor
      'icon': Icons.local_hospital,
      'type': 'expense',
    },
    {
      'name': 'Pendidikan',
      'color': 0xFF2196F3, // Colors.blue
      'icon': Icons.school,
      'type': 'expense',
    },
  ];

  static const List<Map<String, dynamic>> defaultIncomeCategories = [
    {
      'name': 'Gaji',
      'color': 0xFF4CAF50, // Colors.green
      'icon': Icons.attach_money,
      'type': 'income',
    },
    {
      'name': 'Bonus',
      'color': 0xFF8BC34A, // Colors.lightGreen
      'icon': Icons.card_giftcard,
      'type': 'income',
    },
    {
      'name': 'Investasi',
      'color': 0xFF009688, // Colors.teal
      'icon': Icons.trending_up,
      'type': 'income',
    },
    {
      'name': 'Freelance',
      'color': 0xFF3F51B5, // Colors.indigo
      'icon': Icons.work,
      'type': 'income',
    },
    {
      'name': 'Lainnya',
      'color': 0xFF9E9E9E, // Colors.grey
      'icon': Icons.more_horiz,
      'type': 'income',
    },
  ];

  static List<Map<String, dynamic>> getAllDefaultCategories() {
    return [...defaultExpenseCategories, ...defaultIncomeCategories];
  }
}
