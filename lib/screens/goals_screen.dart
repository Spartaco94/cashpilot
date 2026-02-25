import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/goal_provider.dart';
import '../widgets/empty_state.dart';
import '../theme.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalProvider);
    final fmt = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Scaffold(
      appBar: AppBar(title: const Text('Obiettivi di Risparmio')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: goals.isEmpty
          ? EmptyState(
              icon: Icons.flag,
              title: 'Nessun obiettivo',
              subtitle: 'Crea un obiettivo di risparmio per iniziare a risparmiare!',
              action: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Nuovo Obiettivo'),
                onPressed: () => _showAddDialog(context, ref),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: goals.length,
              itemBuilder: (ctx, i) {
                final g = goals[i];
                final pct = g.progress;
                final color = pct >= 1.0 ? AppTheme.incomeGreen : Theme.of(context).colorScheme.primary;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                              child: Icon(pct >= 1.0 ? Icons.check_circle : Icons.flag, color: color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(g.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  Text('${fmt.format(g.current)} / ${fmt.format(g.target)}', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                            Text('${(pct * 100).toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: color.withOpacity(0.15), valueColor: AlwaysStoppedAnimation(color)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Aggiungi'),
                              onPressed: () => _showUpdateDialog(context, ref, g.id, g.current),
                            ),
                            TextButton.icon(
                              icon: Icon(Icons.delete_outline, size: 18, color: AppTheme.expenseRed),
                              label: Text('Elimina', style: TextStyle(color: AppTheme.expenseRed)),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Elimina obiettivo'),
                                    content: Text('Eliminare "${g.name}"?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
                                      TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Elimina', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  ref.read(goalProvider.notifier).delete(g.id);
                                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obiettivo eliminato')));
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuovo Obiettivo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome obiettivo')),
            const SizedBox(height: 12),
            TextField(
              controller: targetCtrl,
              decoration: const InputDecoration(labelText: 'Target (€)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              final target = double.tryParse(targetCtrl.text);
              if (nameCtrl.text.isNotEmpty && target != null && target > 0) {
                ref.read(goalProvider.notifier).add(nameCtrl.text, target);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Obiettivo creato!')));
              }
            },
            child: const Text('Crea'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, WidgetRef ref, String id, double current) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aggiungi importo'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Importo da aggiungere (€)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text);
              if (val != null && val > 0) {
                ref.read(goalProvider.notifier).updateAmount(id, current + val);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Importo aggiornato!')));
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }
}
