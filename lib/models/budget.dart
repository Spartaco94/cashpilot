import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 3)
class Budget extends HiveObject {
  @HiveField(0)
  double monthlyLimit;

  @HiveField(1)
  int month;

  @HiveField(2)
  int year;

  Budget({
    required this.monthlyLimit,
    required this.month,
    required this.year,
  });
}
