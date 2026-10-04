import 'package:flutter/material.dart';

/// Expense categories with their icon and colour.
enum ExpenseCategory {
  food('Food', Icons.restaurant_rounded, Color(0xFFF97316)),
  transport('Transport', Icons.directions_car_rounded, Color(0xFF3B82F6)),
  shopping('Shopping', Icons.shopping_bag_rounded, Color(0xFFEC4899)),
  bills('Bills', Icons.lightbulb_rounded, Color(0xFFD99A00)),
  health('Health', Icons.favorite_rounded, Color(0xFFEF4444)),
  education('Education', Icons.menu_book_rounded, Color(0xFF8B5CF6)),
  entertainment('Entertainment', Icons.movie_rounded, Color(0xFF14B8A6)),
  other('Other', Icons.inventory_2_rounded, Color(0xFF64748B));

  const ExpenseCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static ExpenseCategory fromName(String name) => ExpenseCategory.values
      .firstWhere((c) => c.name == name, orElse: () => ExpenseCategory.other);
}

class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;

  Expense copyWith({
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category.name,
        'date': date.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: ExpenseCategory.fromName(json['category'] as String),
        date: DateTime.parse(json['date'] as String),
      );
}
