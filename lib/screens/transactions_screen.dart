import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/empty_state.dart';
import '../services/csv_export.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final filterType = ref.watch(filterTypeProvider);
    final filterCat = ref.watch(filterCategoryProvider);
    
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transazioni'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Esporta CSV',
            onPressed: transactions.isEmpty ? null : () {
              CsvExportService.exportTransactions(transactions);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV esportato!')));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(hintText: 'Cerca transazione...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildChip(context, ref, 'Tutte', filterType == TransactionFilter.all, () => ref.read(filterTypeProvider.notifier).state = TransactionFilter.all),
                const SizedBox(width: 8),
                _buildChip(context, ref, 'Entrate', filterType == TransactionFilter.income, () => ref.read(filterTypeProvider.notifier).state = TransactionFilter.income),
                const SizedBox(width: 8),
                _buildChip(context, ref, 'Uscite', filterType == TransactionFilter.expense, () => ref.read(filterTypeProvider.notifier).state = TransactionFilter.expense),
                const SizedBox(width: 16),
                if (categories.isNotEmpty)
                  DropdownButton<String?>(
                    value: filterCat,
                    hint: const Text('Categoria'),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tutte')),
                      ...categories.map((c) => DropdownMenuItem(value: c.name, child: Text('${c.emoji} ${c.name}'))),
                    ],
                    onChanged: (v) => ref.read(filterCategoryProvider.notifier).state = v,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: transactions.isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long,
                    title: 'Nessuna transazione',
                    subtitle: 'Aggiungi la tua prima transazione con il pulsante +',
                    action: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Aggiungi'),
                      onPressed: () => context.push('/transactions/add'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (ctx, i) {
                      final t = transactions[i];
                      return TransactionTile(
                        transaction: t,
                        onTap: () => context.push('/transactions/edit/${t.id}'),
                        onDelete: () {
                          ref.read(transactionProvider.notifier).delete(t.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transazione eliminata')));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, WidgetRef ref, String label, bool selected, VoidCallback onTap) {
    return FilterChip(label: Text(label), selected: selected, onSelected: (_) => onTap());
  }
}
