import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../widgets/empty_state.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categorie')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: categories.isEmpty
          ? const EmptyState(icon: Icons.category, title: 'Nessuna categoria', subtitle: 'Aggiungi una categoria per iniziare')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (ctx, i) {
                final cat = categories[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Color(cat.colorValue).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: Center(child: Text(cat.emoji, style: const TextStyle(fontSize: 20))),
                    ),
                    title: Text(cat.name),
                    subtitle: Text(cat.isDefault ? 'Default' : 'Custom'),
                    trailing: cat.isDefault
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Elimina categoria'),
                                  content: Text('Eliminare "${cat.name}"?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
                                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Elimina', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                ref.read(categoryProvider.notifier).delete(i);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Categoria eliminata')));
                                }
                              }
                            },
                          ),
                  ),
                );
              },
            ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final emojiCtrl = TextEditingController(text: '📌');
    Color selectedColor = Colors.blue;
    final colors = [Colors.red, Colors.pink, Colors.purple, Colors.deepPurple, Colors.indigo, Colors.blue, Colors.cyan, Colors.teal, Colors.green, Colors.amber, Colors.orange, Colors.brown];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nuova Categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 12),
              TextField(controller: emojiCtrl, decoration: const InputDecoration(labelText: 'Emoji')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: colors.map((c) => GestureDetector(
                  onTap: () => setState(() => selectedColor = c),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: selectedColor == c ? Border.all(color: Colors.white, width: 3) : null,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annulla')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  ref.read(categoryProvider.notifier).add(Category(
                    name: nameCtrl.text,
                    emoji: emojiCtrl.text.isNotEmpty ? emojiCtrl.text : '📌',
                    colorValue: selectedColor.value,
                  ));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Categoria aggiunta!')));
                }
              },
              child: const Text('Aggiungi'),
            ),
          ],
        ),
      ),
    );
  }
}
