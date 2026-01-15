import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../models/expense_summary.dart';
import '../services/api_service.dart';
import '../../../core/providers/app_providers.dart';

class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ApiService _apiService;

  ExpenseNotifier(this._apiService) : super(const AsyncValue.loading()) {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final expensesData = await _apiService.getExpenses();

      final expenses = expensesData
          .map((data) => Expense.fromJson(data))
          .toList();
      state = AsyncValue.data(expenses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      // Optimistic update could be done here, but let's wait for server for simplicity
      final response = await _apiService.createExpense(expense.toJson());
      final newExpense = Expense.fromJson(response);

      final currentExpenses = state.value ?? [];
      state = AsyncValue.data([newExpense, ...currentExpenses]);
    } catch (error, stackTrace) {
      // Ideally show error toast
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      final response = await _apiService.updateExpense(
        expense.id,
        expense.toJson(),
      );
      final updatedExpense = Expense.fromJson(response);

      final currentExpenses = state.value ?? [];
      final updatedList = currentExpenses
          .map((e) => e.id == updatedExpense.id ? updatedExpense : e)
          .toList();

      state = AsyncValue.data(updatedList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _apiService.deleteExpense(expenseId);

      final currentExpenses = state.value ?? [];
      final updatedList = currentExpenses
          .where((e) => e.id != expenseId)
          .toList();
      state = AsyncValue.data(updatedList);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh() {
    _loadExpenses();
  }
}

final expenseProvider =
    StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return ExpenseNotifier(apiService);
    });

final expenseSummaryProvider = Provider<AsyncValue<ExpenseSummary>>((ref) {
  final expenses = ref.watch(expenseProvider);
  return expenses.when(
    data: (expenseList) =>
        AsyncValue.data(ExpenseSummary.fromExpenses(expenseList)),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

final filteredExpenseSummaryProvider =
    Provider.family<AsyncValue<ExpenseSummary>, String>((ref, period) {
      final expenses = ref.watch(filteredExpensesProvider(period));
      return expenses.when(
        data: (expenseList) =>
            AsyncValue.data(ExpenseSummary.fromExpenses(expenseList)),
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      );
    });

final filteredExpensesProvider =
    Provider.family<AsyncValue<List<Expense>>, String>((ref, period) {
      final expenses = ref.watch(expenseProvider);
      return expenses.when(
        data: (expenseList) {
          final now = DateTime.now();
          final filteredExpenses = expenseList.where((expense) {
            switch (period) {
              case 'daily':
                return expense.date.day == now.day &&
                    expense.date.month == now.month &&
                    expense.date.year == now.year;
              case 'weekly':
                final weekStart = now.subtract(Duration(days: now.weekday - 1));
                final weekEnd = weekStart.add(const Duration(days: 6));
                return expense.date.isAfter(
                      weekStart.subtract(const Duration(days: 1)),
                    ) &&
                    expense.date.isBefore(weekEnd.add(const Duration(days: 1)));
              case 'monthly':
                return expense.date.month == now.month &&
                    expense.date.year == now.year;
              default:
                return true;
            }
          }).toList();
          return AsyncValue.data(filteredExpenses);
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      );
    });
