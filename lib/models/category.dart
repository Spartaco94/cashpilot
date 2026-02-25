import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String emoji;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  bool isDefault;

  Category({
    required this.name,
    required this.emoji,
    required this.colorValue,
    this.isDefault = false,
  });
}
