import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_controller.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_card.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({
    super.key,
    required this.controller,
    required this.onAdd,
  });

  final ExpenseController controller;
  final VoidCallback onAdd;

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ExpenseCategory? _category; // null = All
  int _monthKey = 0; // 0 = all months, otherwise year*100+month

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Expense> _filtered() {
    final q = _query.trim().toLowerCase();
    return widget.controller.expenses.where((e) {
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.category.label.toLowerCase().contains(q);
      final matchesCategory = _category == null || e.category == _category;
      final matchesMonth =
          _monthKey == 0 || e.date.year * 100 + e.date.month == _monthKey;
      return matchesQuery && matchesCategory && matchesMonth;
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _query = '';
      _category = null;
      _monthKey = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final months = controller.availableMonths;
        // If the selected month no longer has expenses, fall back to "all".
        if (_monthKey != 0 &&
            !months.any((m) => m.year * 100 + m.month == _monthKey)) {
          _monthKey = 0;
        }
        final items = _filtered();
        final filteredTotal = items.fold(0.0, (s, e) => s + e.amount);
        final hasFilters =
            _query.isNotEmpty || _category != null || _monthKey != 0;

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const Text(
                'All Expenses',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search by title or category',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _query = '';
                          }),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: 'All',
                      selected: _category == null,
                      color: AppColors.primary,
                      onTap: () => setState(() => _category = null),
                    ),
                    for (final c in ExpenseCategory.values)
                      _FilterChip(
                        label: c.label,
                        icon: c.icon,
                        selected: _category == c,
                        color: c.color,
                        onTap: () => setState(() => _category = c),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${items.length} ${items.length == 1 ? 'expense' : 'expenses'}'
                      ' • ${formatAmount(filteredTotal)}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (months.isNotEmpty)
                    PopupMenuButton<int>(
                      tooltip: 'Filter by month',
                      onSelected: (v) => setState(() => _monthKey = v),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                            value: 0, child: Text('All months')),
                        for (final m in months)
                          PopupMenuItem(
                            value: m.year * 100 + m.month,
                            child: Text(formatMonthYear(m)),
                          ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _monthKey == 0
                                ? Colors.grey.shade300
                                : AppColors.primary,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              _monthKey == 0
                                  ? 'All months'
                                  : formatMonthYear(DateTime(
                                      _monthKey ~/ 100, _monthKey % 100)),
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (controller.isEmpty)
                EmptyState(
                  title: 'No expenses yet',
                  message:
                      'Start tracking your spending by adding your first expense.',
                  buttonLabel: 'Add Expense',
                  onPressed: widget.onAdd,
                )
              else if (items.isEmpty) ...[
                const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No matching expenses',
                  message: 'Try a different search or clear your filters.',
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off_rounded),
                    label: const Text('Clear filters'),
                  ),
                ),
              ] else
                for (final e in items)
                  ExpenseCard(expense: e, controller: controller),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: icon == null
            ? null
            : Icon(icon, size: 16, color: selected ? Colors.white : color),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: color,
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? color : Colors.grey.shade300),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.textDark,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
