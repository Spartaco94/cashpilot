import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/budget_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/budget_bar.dart';
import '../widgets/expense_chart.dart';
import '../widgets/transaction_tile.dart';
import '../theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balance = ref.watch(totalBalanceProvider);
    final income = ref.watch(monthlyIncomeProvider);
    final expense = ref.watch(monthlyExpenseProvider);
    final saving = income - expense;
    final budget = ref.watch(budgetProvider);
    final transactions = ref.watch(filteredTransactionsProvider);
    final month = ref.watch(filterMonthProvider);
    final monthLabel = DateFormat('MMMM yyyy', 'it').format(month);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CashPilot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(filterMonthProvider.notifier).state = DateTime(month.year, month.month - 1);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: Text(monthLabel, style: const TextStyle(fontSize: 14))),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              ref.read(filterMonthProvider.notifier).state = DateTime(month.year, month.month + 1);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWide)
                  Row(
                    children: [
                      Expanded(child: StatCard(title: 'Saldo Totale', amount: balance, icon: Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(title: 'Entrate', amount: income, icon: Icons.trending_up, color: AppTheme.incomeGreen)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(title: 'Uscite', amount: expense, icon: Icons.trending_down, color: AppTheme.expenseRed)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(title: 'Risparmio', amount: saving, icon: Icons.savings, color: Theme.of(context).colorScheme.secondary)),
                    ],
                  )
                else
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(title: 'Saldo', amount: balance, icon: Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                      StatCard(title: 'Entrate', amount: income, icon: Icons.trending_up, color: AppTheme.incomeGreen),
                      StatCard(title: 'Uscite', amount: expense, icon: Icons.trending_down, color: AppTheme.expenseRed),
                      StatCard(title: 'Risparmio', amount: saving, icon: Icons.savings, color: Theme.of(context).colorScheme.secondary),
                    ],
                  ),
                const SizedBox(height: 16),
                if (budget != null) BudgetBar(spent: expense, limit: budget.monthlyLimit),
                const SizedBox(height: 16),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: ExpenseChart()),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Transazioni Recenti', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...transactions.take(5).map((t) => TransactionTile(
                              transaction: t,
                              onDelete: () => ref.read(transactionProvider.notifier).delete(t.id),
                            )),
                            if (transactions.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(child: Text('Nessuna transazione', style: TextStyle(color: Colors.grey[500]))),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  const ExpenseChart(),
                  const SizedBox(height: 16),
                  Text('Transazioni Recenti', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...transactions.take(5).map((t) => TransactionTile(
                    transaction: t,
                    onDelete: () => ref.read(transactionProvider.notifier).delete(t.id),
                  )),
                  if (transactions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text('Nessuna transazione', style: TextStyle(color: Colors.grey[500]))),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
