import 'package:hive/hive.dart';

part 'savings_goal.g.dart';

@HiveType(typeId: 4)
class SavingsGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double target;

  @HiveField(3)
  double current;

  @HiveField(4)
  DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.target,
    this.current = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0;
}
