import 'package:flutter/material.dart';
import 'screens/add_expense_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expense_list_screen.dart';
import 'services/expense_controller.dart';
import 'services/local_storage_service.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = ExpenseController(LocalStorageService());
  await controller.load();
  runApp(MiniExpenseApp(controller: controller));
}

class MiniExpenseApp extends StatelessWidget {
  const MiniExpenseApp({super.key, required this.controller});

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: HomeShell(controller: controller),
    );
  }
}

/// Bottom navigation between Dashboard and Expense List, plus the Add button.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final ExpenseController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _openAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            controller: widget.controller,
            onSeeAll: () => setState(() => _index = 1),
            onAdd: _openAdd,
          ),
          ExpenseListScreen(controller: widget.controller, onAdd: _openAdd),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAdd,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Expenses',
          ),
        ],
      ),
    );
  }
}
