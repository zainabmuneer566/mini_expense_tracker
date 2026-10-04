import 'package:flutter/material.dart';
import '../services/expense_controller.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';
import '../widgets/category_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.controller,
    required this.onSeeAll,
    required this.onAdd,
  });

  final ExpenseController controller;
  final VoidCallback onSeeAll;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final now = DateTime.now();
        final total = controller.total;
        final monthTotal = controller.monthTotal(now);

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            children: [
              Text(
                '${greeting()} 👋',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Track your spending smartly',
                style: TextStyle(color: AppColors.textMuted, fontSize: 15),
              ),
              const SizedBox(height: 20),
              _TotalCard(total: total, month: now, monthTotal: monthTotal),
              const SizedBox(height: 16),
              if (controller.isEmpty)
                EmptyState(
                  title: 'No expenses yet',
                  message:
                      'Start tracking your spending by adding your first expense.',
                  buttonLabel: 'Add Expense',
                  onPressed: onAdd,
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.account_balance_wallet_rounded,
                        label: 'Total',
                        value: formatAmount(total),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.calendar_today_rounded,
                        label: 'This Month',
                        value: formatAmount(monthTotal),
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        icon: Icons.receipt_long_rounded,
                        label: 'Expenses',
                        value: '${controller.count}',
                        color: const Color(0xFFF97316),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const _SectionTitle('Spending by category'),
                const SizedBox(height: 12),
                ..._categoryCards(),
                const SizedBox(height: 14),
                _SectionTitle(
                  'Recent expenses',
                  actionLabel: 'See all',
                  onAction: onSeeAll,
                ),
                const SizedBox(height: 12),
                for (final e in controller.recent)
                  ExpenseCard(expense: e, controller: controller),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _categoryCards() {
    final totals = controller.categoryTotals;
    final counts = controller.categoryCounts;
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final grand = controller.total;
    return [
      for (final entry in entries)
        CategoryCard(
          category: entry.key,
          total: entry.value,
          count: counts[entry.key] ?? 0,
          fraction: grand == 0 ? 0 : entry.value / grand,
        ),
    ];
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.total,
    required this.month,
    required this.monthTotal,
  });

  final double total;
  final DateTime month;
  final double monthTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Expenses',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatAmount(total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_note_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    formatMonthYear(month),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  formatAmount(monthTotal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        if (actionLabel != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}
