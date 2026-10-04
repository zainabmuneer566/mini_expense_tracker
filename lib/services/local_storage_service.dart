import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

/// Saves/loads expenses as a JSON string in SharedPreferences.
/// Swap this class for a Supabase service later without touching the UI.
class LocalStorageService {
  static const _key = 'expenses_v1';

  Future<List<Expense>> loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted or unreadable data: start fresh instead of crashing.
      return [];
    }
  }

  Future<bool> saveExpenses(List<Expense> expenses) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(expenses.map((e) => e.toJson()).toList());
      return await prefs.setString(_key, raw);
    } catch (_) {
      return false;
    }
  }
}
