import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../services/expense_controller.dart';
import '../utils/app_colors.dart';
import '../utils/helpers.dart';

/// Add form. When [expense] is given, the same form works as the Edit form.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, required this.controller, this.expense});

  final ExpenseController controller;
  final Expense? expense;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  ExpenseCategory? _category;
  late DateTime _date;
  bool _saving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(
      text: e == null
          ? ''
          : (e.amount == e.amount.roundToDouble()
              ? e.amount.toStringAsFixed(0)
              : e.amount.toString()),
    );
    _category = e?.category;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());

    final bool saved;
    if (_isEditing) {
      saved = await widget.controller.updateExpense(
        widget.expense!.copyWith(
          title: title,
          amount: amount,
          category: _category,
          date: _date,
        ),
      );
    } else {
      saved = await widget.controller.addExpense(
        Expense(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: title,
          amount: amount,
          category: _category!,
          date: _date,
        ),
      );
    }

    showSnack(
      messenger,
      saved
          ? (_isEditing
              ? 'Expense updated successfully'
              : 'Expense added successfully')
          : saveFailedMessage,
      isError: !saved,
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Expense' : 'Add Expense')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('Title'),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Grocery Shopping',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter an expense title.'
                      : null,
                ),
                const SizedBox(height: 20),
                const _Label('Amount'),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(14),
                      child: Text(
                        'Rs.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  validator: (v) {
                    final text = v?.trim() ?? '';
                    if (text.isEmpty) return 'Please enter an amount.';
                    final value = double.tryParse(text);
                    if (value == null || value <= 0) {
                      return 'Amount must be greater than 0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const _Label('Category'),
                FormField<ExpenseCategory>(
                  initialValue: _category,
                  validator: (v) =>
                      v == null ? 'Please select a category.' : null,
                  builder: (state) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in ExpenseCategory.values)
                            ChoiceChip(
                              avatar: Icon(
                                c.icon,
                                size: 18,
                                color: _category == c ? Colors.white : c.color,
                              ),
                              label: Text(c.label),
                              selected: _category == c,
                              selectedColor: c.color,
                              backgroundColor: Colors.white,
                              showCheckmark: false,
                              side: BorderSide(
                                color: _category == c
                                    ? c.color
                                    : Colors.grey.shade300,
                              ),
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _category == c
                                    ? Colors.white
                                    : AppColors.textDark,
                              ),
                              onSelected: (_) {
                                setState(() => _category = c);
                                state.didChange(c);
                              },
                            ),
                        ],
                      ),
                      if (state.hasError)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 4),
                          child: Text(
                            state.errorText!,
                            style: const TextStyle(
                                color: AppColors.danger, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const _Label('Date'),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                    child: Text(
                      formatDate(_date),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: Icon(
                      _isEditing ? Icons.check_rounded : Icons.save_rounded),
                  label: Text(_isEditing ? 'Save Changes' : 'Save Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      );
}
