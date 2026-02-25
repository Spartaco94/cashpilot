import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, Budget?>((ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<Budget?> {
  BudgetNotifier() : super(null) {
    _load();
  }

  void _load() {
    final now = DateTime.now();
    final box = StorageService.budgets;
    try {
      state = box.values.firstWhere((b) => b.month == now.month && b.year == now.year);
    } catch (_) {
      state = null;
    }
  }

  Future<void> set(double limit) async {
    final now = DateTime.now();
    final box = StorageService.budgets;
    final index = box.values.toList().indexWhere((b) => b.month == now.month && b.year == now.year);
    final budget = Budget(monthlyLimit: limit, month: now.month, year: now.year);
    if (index >= 0) {
      await box.putAt(index, budget);
    } else {
      await box.add(budget);
    }
    _load();
  }

  void refresh() => _load();
}
