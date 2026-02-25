import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, List<Category>>((ref) {
  return CategoryNotifier();
});

class CategoryNotifier extends StateNotifier<List<Category>> {
  CategoryNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.categories.values.toList();
  }

  Future<void> add(Category cat) async {
    await StorageService.categories.add(cat);
    _load();
  }

  Future<void> delete(int index) async {
    await StorageService.categories.deleteAt(index);
    _load();
  }

  void refresh() => _load();
}
