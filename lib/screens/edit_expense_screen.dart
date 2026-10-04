import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_controller.dart';
import 'add_expense_screen.dart';

/// Edit uses the same form as Add, pre-filled with the existing expense,
/// so there is only one form to maintain.
class EditExpenseScreen extends StatelessWidget {
  const EditExpenseScreen({
    super.key,
    required this.controller,
    required this.expense,
  });

  final ExpenseController controller;
  final Expense expense;

  @override
  Widget build(BuildContext context) =>
      AddExpenseScreen(controller: controller, expense: expense);
}
