import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart' as cat_model;

class ExpenseChart extends ConsumerWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseMap = ref.watch(expenseByCategoryProvider);
    final categories = ref.watch(categoryProvider);

    if (expenseMap.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[600]),
                const SizedBox(height: 12),
                Text('Nessuna spesa questo mese', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    }

    final total = expenseMap.values.fold(0.0, (s, v) => s + v);
    final entries = expenseMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spese per Categoria', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: entries.map((e) {
                    cat_model.Category? cat;
                    try { cat = categories.firstWhere((c) => c.name == e.key); } catch (_) {}
                    final pct = (e.value / total * 100);
                    return PieChartSectionData(
                      value: e.value,
                      title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
                      color: cat != null ? Color(cat.colorValue) : Colors.grey,
                      radius: 50,
                      titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: entries.map((e) {
                cat_model.Category? cat;
                try { cat = categories.firstWhere((c) => c.name == e.key); } catch (_) {}
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: cat != null ? Color(cat.colorValue) : Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text('${cat?.emoji ?? ''} ${e.key}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
