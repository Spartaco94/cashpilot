import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class BudgetBar extends StatelessWidget {
  final double spent;
  final double limit;

  const BudgetBar({super.key, required this.spent, required this.limit});

  @override
  Widget build(BuildContext context) {
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0.0;
    final displayRatio = ratio.clamp(0.0, 1.0);
    final fmt = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    Color barColor;
    String label;
    if (ratio > 1.0) {
      barColor = AppTheme.expenseRed;
      label = 'Oltre budget!';
    } else if (ratio > 0.8) {
      barColor = AppTheme.warningOrange;
      label = 'Vicino al limite';
    } else {
      barColor = AppTheme.incomeGreen;
      label = 'Sotto budget';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget Mensile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: barColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(label, style: TextStyle(color: barColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: displayRatio.toDouble(),
                minHeight: 10,
                backgroundColor: barColor.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${fmt.format(spent)} spesi', style: Theme.of(context).textTheme.bodySmall),
                Text('di ${fmt.format(limit)}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
