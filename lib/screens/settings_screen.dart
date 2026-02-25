import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../services/storage_service.dart';
import '../theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                  title: const Text('Tema'),
                  subtitle: Text(themeMode == ThemeMode.dark ? 'Scuro' : 'Chiaro'),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Versione'),
                  subtitle: const Text('CashPilot v1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Generato da'),
                  subtitle: const Text('Jarviss AI'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppTheme.expenseRed.withOpacity(0.1),
            child: ListTile(
              leading: Icon(Icons.warning_amber, color: AppTheme.expenseRed),
              title: Text('Reset Dati', style: TextStyle(color: AppTheme.expenseRed, fontWeight: FontWeight.bold)),
              subtitle: const Text('Elimina tutte le transazioni, budget e obiettivi'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Reset Dati'),
                    content: const Text('Sei sicuro? Tutti i dati verranno eliminati permanentemente.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annulla')),
                      TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: Text('Reset', style: TextStyle(color: AppTheme.expenseRed)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await StorageService.resetAll();
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dati resettati!')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
