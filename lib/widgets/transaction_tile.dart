import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart' as cat_model;
import '../providers/category_provider.dart';
import '../theme.dart';

class TransactionTile extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({super.key, required this.transaction, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final fmt = NumberFormat.currency(locale: 'it_IT', symbol: '€');
    final dateFmt = DateFormat('dd MMM yyyy', 'it');

    cat_model.Category? cat;
    try {
      cat = categories.firstWhere((c) => c.name == transaction.category);
    } catch (_) {}

    final isIncome = transaction.type == TransactionType.income;

    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppTheme.expenseRed.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.delete_outline, color: AppTheme.expenseRed),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Elimina transazione'),
            content: const Text('Sei sicuro di voler eliminare questa transazione?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annulla')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Elimina', style: TextStyle(color: AppTheme.expenseRed))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (cat != null ? Color(cat.colorValue) : Colors.grey).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(cat?.emoji ?? '📌', style: const TextStyle(fontSize: 20))),
          ),
          title: Text(transaction.description.isNotEmpty ? transaction.description : transaction.category, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Row(
            children: [
              Text(dateFmt.format(transaction.date), style: Theme.of(context).textTheme.bodySmall),
              if (transaction.isRecurring) ...[
                const SizedBox(width: 6),
                Icon(Icons.repeat, size: 14, color: Theme.of(context).colorScheme.primary),
              ],
            ],
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'}${fmt.format(transaction.amount)}',
            style: TextStyle(
              color: isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
