import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/budget_bar.dart';
import '../theme.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);
    final expense = ref.watch(monthlyExpenseProvider);
    final fmt = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Scaffold(
      appBar: AppBar(title: const Text('Budget')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      budget != null ? fmt.format(budget.monthlyLimit) : 'Non impostato',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Budget mensile', style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (budget != null) BudgetBar(spent: expense, limit: budget.monthlyLimit),
            const SizedBox(height: 16),
            if (budget != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Riepilogo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _row('Budget', fmt.format(budget.monthlyLimit)),
                      _row('Speso', fmt.format(expense)),
                      _row('Rimanente', fmt.format(budget.monthlyLimit - expense),
                        color: budget.monthlyLimit - expense >= 0 ? AppTheme.incomeGreen : AppTheme.expenseRed),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(budget != null ? 'Modifica Budget' : 'Imposta Budget', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(labelText: 'Importo mensile (€)', prefixIcon: Icon(Icons.euro)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        final val = double.tryParse(_ctrl.text);
                        if (val != null && val > 0) {
                          ref.read(budgetProvider.notifier).set(val);
                          _ctrl.clear();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget aggiornato!')));
                        }
                      },
                      child: const Text('Salva Budget'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
