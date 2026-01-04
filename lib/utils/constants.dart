import 'package:flutter/material.dart';

class AppConstants {
  static const List<String> expenseCategories = [
    'Food',
    'Self-Care',
    'Gifts',
    'Transportation',
    'Sweet Drinks',
    'Family',
    'Student Loan',
    'Savings',
    'Subscriptions',
    'Others',
  ];

  // ---------- ICONS ----------
  static IconData getCategoryIcon(String? category) {
    if (category == null || category.isEmpty) {
      return Icons.category;
    }

    final categoryLower = category.toLowerCase();

    switch (categoryLower) {
      case 'food':
        return Icons.restaurant;
      case 'self-care':
        return Icons.spa;
      case 'gifts':
        return Icons.card_giftcard;
      case 'transportation':
        return Icons.directions_bus;
      case 'sweet drinks':
        return Icons.local_cafe;
      case 'family':
        return Icons.family_restroom;
      case 'student loan':
        return Icons.school;
      case 'savings':
        return Icons.savings;
      case 'subscriptions': // FIXED
        return Icons.subscriptions;
      case 'others':
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  // ---------- COLORS ----------
  static Color getCategoryColor(String? category, int index) {
    final colors = [
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.green,
      Colors.amber,
      Colors.cyan,
    ];

    if (category == null || category.isEmpty) {
      return colors[index % colors.length];
    }

    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('food')) return Colors.orange;
    if (categoryLower.contains('transport')) return Colors.blue;
    if (categoryLower.contains('gift')) return Colors.pink;
    if (categoryLower.contains('self')) return Colors.purple;
    if (categoryLower.contains('subscription')) return Colors.indigo;
    if (categoryLower.contains('savings')) return Colors.green;

    return colors[index % colors.length];
  }
}