import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/savings_goal.dart';
import '../services/storage_service.dart';

final goalProvider = StateNotifierProvider<GoalNotifier, List<SavingsGoal>>((ref) {
  return GoalNotifier();
});

class GoalNotifier extends StateNotifier<List<SavingsGoal>> {
  GoalNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.goals.values.toList();
  }

  Future<void> add(String name, double target) async {
    final goal = SavingsGoal(id: const Uuid().v4(), name: name, target: target);
    await StorageService.goals.add(goal);
    _load();
  }

  Future<void> updateAmount(String id, double amount) async {
    final box = StorageService.goals;
    final index = box.values.toList().indexWhere((g) => g.id == id);
    if (index >= 0) {
      final old = box.getAt(index)!;
      old.current = amount;
      await old.save();
      _load();
    }
  }

  Future<void> delete(String id) async {
    final box = StorageService.goals;
    final index = box.values.toList().indexWhere((g) => g.id == id);
    if (index >= 0) {
      await box.deleteAt(index);
      _load();
    }
  }

  void refresh() => _load();
}
