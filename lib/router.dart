import 'package:go_router/go_router.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/add_edit_transaction_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/settings_screen.dart';
import 'shell.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (c, s) => const DashboardScreen()),
        GoRoute(path: '/transactions', builder: (c, s) => const TransactionsScreen()),
        GoRoute(path: '/transactions/add', builder: (c, s) => const AddEditTransactionScreen()),
        GoRoute(path: '/transactions/edit/:id', builder: (c, s) => AddEditTransactionScreen(transactionId: s.pathParameters['id'])),
        GoRoute(path: '/categories', builder: (c, s) => const CategoriesScreen()),
        GoRoute(path: '/budget', builder: (c, s) => const BudgetScreen()),
        GoRoute(path: '/goals', builder: (c, s) => const GoalsScreen()),
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      ],
    ),
  ],
);
