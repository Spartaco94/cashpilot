import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier();
});

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.transactions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> add(Transaction t) async {
    final tx = Transaction(
      id: const Uuid().v4(),
      type: t.type,
      amount: t.amount,
      category: t.category,
      description: t.description,
      date: t.date,
      isRecurring: t.isRecurring,
    );
    await StorageService.transactions.add(tx);
    _load();
  }

  Future<void> update(String id, Transaction updated) async {
    final box = StorageService.transactions;
    final index = box.values.toList().indexWhere((t) => t.id == id);
    if (index >= 0) {
      await box.putAt(index, updated);
      _load();
    }
  }

  Future<void> delete(String id) async {
    final box = StorageService.transactions;
    final index = box.values.toList().indexWhere((t) => t.id == id);
    if (index >= 0) {
      await box.deleteAt(index);
      _load();
    }
  }

  void refresh() => _load();
}

enum TransactionFilter { all, income, expense }

final filterTypeProvider = StateProvider<TransactionFilter>((ref) => TransactionFilter.all);
final filterCategoryProvider = StateProvider<String?>((ref) => null);
final filterMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final all = ref.watch(transactionProvider);
  final type = ref.watch(filterTypeProvider);
  final category = ref.watch(filterCategoryProvider);
  final month = ref.watch(filterMonthProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return all.where((t) {
    if (type == TransactionFilter.income && t.type != TransactionType.income) return false;
    if (type == TransactionFilter.expense && t.type != TransactionType.expense) return false;
    if (category != null && t.category != category) return false;
    if (t.date.month != month.month || t.date.year != month.year) return false;
    if (query.isNotEmpty && !t.description.toLowerCase().contains(query) && !t.category.toLowerCase().contains(query)) return false;
    return true;
  }).toList();
});

final monthlyIncomeProvider = Provider<double>((ref) {
  final txs = ref.watch(filteredTransactionsProvider);
  return txs.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
});

final monthlyExpenseProvider = Provider<double>((ref) {
  final txs = ref.watch(filteredTransactionsProvider);
  return txs.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
});

final totalBalanceProvider = Provider<double>((ref) {
  final all = ref.watch(transactionProvider);
  return all.fold(0.0, (s, t) => t.type == TransactionType.income ? s + t.amount : s - t.amount);
});

final expenseByCategoryProvider = Provider<Map<String, double>>((ref) {
  final txs = ref.watch(filteredTransactionsProvider);
  final map = <String, double>{};
  for (final t in txs.where((t) => t.type == TransactionType.expense)) {
    map[t.category] = (map[t.category] ?? 0) + t.amount;
  }
  return map;
});
