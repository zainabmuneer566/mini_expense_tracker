import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import 'local_storage_service.dart';

/// Holds all expense data and calculations. Screens listen to it and rebuild
/// automatically whenever something changes.
class ExpenseController extends ChangeNotifier {
  ExpenseController(this._storage);

  final LocalStorageService _storage;
  List<Expense> _expenses = [];

  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isEmpty => _expenses.isEmpty;
  int get count => _expenses.length;
  List<Expense> get recent => _expenses.take(4).toList();

  double get total => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  double monthTotal(DateTime month) => _expenses
      .where((e) => e.date.year == month.year && e.date.month == month.month)
      .fold(0.0, (sum, e) => sum + e.amount);

  Map<ExpenseCategory, double> get categoryTotals {
    final map = <ExpenseCategory, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Map<ExpenseCategory, int> get categoryCounts {
    final map = <ExpenseCategory, int>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + 1;
    }
    return map;
  }

  /// Months that have at least one expense, newest first (day set to 1).
  List<DateTime> get availableMonths {
    final set = <int>{
      for (final e in _expenses) e.date.year * 100 + e.date.month,
    };
    final keys = set.toList()..sort((a, b) => b.compareTo(a));
    return keys.map((k) => DateTime(k ~/ 100, k % 100)).toList();
  }

  Future<void> load() async {
    _expenses = await _storage.loadExpenses();
    _sort();
    notifyListeners();
  }

  /// Each method returns false only if saving to the device failed.
  Future<bool> addExpense(Expense expense) async {
    _expenses.add(expense);
    _sort();
    notifyListeners();
    return _storage.saveExpenses(_expenses);
  }

  Future<bool> updateExpense(Expense updated) async {
    final index = _expenses.indexWhere((e) => e.id == updated.id);
    if (index == -1) return false;
    _expenses[index] = updated;
    _sort();
    notifyListeners();
    return _storage.saveExpenses(_expenses);
  }

  Future<bool> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    return _storage.saveExpenses(_expenses);
  }

  void _sort() {
    _expenses.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
  }
}
