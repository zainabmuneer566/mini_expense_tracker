import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_controller.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
const _monthsFull = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// 2500 -> "Rs. 2,500", 12.5 -> "Rs. 12.50"
String formatAmount(double value) {
  final isWhole = value == value.roundToDouble();
  final parts = value.toStringAsFixed(isWhole ? 0 : 2).split('.');
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return 'Rs. ${parts.length > 1 ? '$whole.${parts[1]}' : whole}';
}

/// "04 Oct 2026"
String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

/// "October 2026"
String formatMonthYear(DateTime d) => '${_monthsFull[d.month - 1]} ${d.year}';

String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

void showSnack(ScaffoldMessengerState messenger, String message,
    {bool isError = false}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.orange.shade800 : null,
      ),
    );
}

const saveFailedMessage =
    "Saved for now, but we couldn't store it on this device.";

/// Shows the confirmation dialog and deletes the expense if confirmed.
Future<void> confirmDelete(
  BuildContext context,
  ExpenseController controller,
  Expense expense,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete expense?'),
      content: const Text('Are you sure you want to delete this expense?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFE5484D),
            minimumSize: const Size(90, 44),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  final saved = await controller.deleteExpense(expense.id);
  showSnack(
    messenger,
    saved ? 'Expense deleted successfully' : saveFailedMessage,
    isError: !saved,
  );
}
