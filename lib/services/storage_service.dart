import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';

class StorageService {
  static const String transactionsBox = 'transactions';
  static const String categoriesBox = 'categories';
  static const String budgetsBox = 'budgets';
  static const String goalsBox = 'goals';
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(SavingsGoalAdapter());

    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<Category>(categoriesBox);
    await Hive.openBox<Budget>(budgetsBox);
    await Hive.openBox<SavingsGoal>(goalsBox);
    await Hive.openBox(settingsBox);

    await _seedDefaultCategories();
  }

  static Future<void> _seedDefaultCategories() async {
    final box = Hive.box<Category>(categoriesBox);
    if (box.isEmpty) {
      final defaults = [
        Category(name: 'Stipendio', emoji: '💰', colorValue: 0xFF4CAF50, isDefault: true),
        Category(name: 'Freelance', emoji: '💻', colorValue: 0xFF2196F3, isDefault: true),
        Category(name: 'Affitto', emoji: '🏠', colorValue: 0xFFFF5722, isDefault: true),
        Category(name: 'Spesa', emoji: '🛒', colorValue: 0xFFFF9800, isDefault: true),
        Category(name: 'Trasporti', emoji: '🚗', colorValue: 0xFF9C27B0, isDefault: true),
        Category(name: 'Ristoranti', emoji: '🍕', colorValue: 0xFFE91E63, isDefault: true),
        Category(name: 'Salute', emoji: '💊', colorValue: 0xFF00BCD4, isDefault: true),
        Category(name: 'Intrattenimento', emoji: '🎬', colorValue: 0xFF673AB7, isDefault: true),
        Category(name: 'Abbigliamento', emoji: '👕', colorValue: 0xFF795548, isDefault: true),
        Category(name: 'Bollette', emoji: '⚡', colorValue: 0xFFFFC107, isDefault: true),
        Category(name: 'Altro', emoji: '📌', colorValue: 0xFF607D8B, isDefault: true),
      ];
      for (final cat in defaults) {
        await box.add(cat);
      }
    }
  }

  // Transactions
  static Box<Transaction> get transactions => Hive.box<Transaction>(transactionsBox);
  static Box<Category> get categories => Hive.box<Category>(categoriesBox);
  static Box<Budget> get budgets => Hive.box<Budget>(budgetsBox);
  static Box<SavingsGoal> get goals => Hive.box<SavingsGoal>(goalsBox);
  static Box get settings => Hive.box(settingsBox);

  static Future<void> resetAll() async {
    await transactions.clear();
    await categories.clear();
    await budgets.clear();
    await goals.clear();
    await settings.clear();
    await _seedDefaultCategories();
  }
}
