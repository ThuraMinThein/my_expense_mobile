import 'expense.dart';

class ExpenseSummary {
  final double total;
  final double average;
  final int count;
  final Map<String, double> categoryTotals;
  final Map<DateTime, double> dailyTotals;

  const ExpenseSummary({
    required this.total,
    required this.average,
    required this.count,
    required this.categoryTotals,
    required this.dailyTotals,
  });

  factory ExpenseSummary.empty() {
    return const ExpenseSummary(
      total: 0.0,
      average: 0.0,
      count: 0,
      categoryTotals: {},
      dailyTotals: {},
    );
  }

  factory ExpenseSummary.fromExpenses(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return ExpenseSummary.empty();
    }

    final total = expenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0.0) + expense.amount;
    }

    final dailyTotals = <DateTime, double>{};
    for (final expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      dailyTotals[date] = (dailyTotals[date] ?? 0.0) + expense.amount;
    }

    return ExpenseSummary(
      total: total,
      average: total / expenses.length,
      count: expenses.length,
      categoryTotals: categoryTotals,
      dailyTotals: dailyTotals,
    );
  }

  ExpenseSummary copyWith({
    double? total,
    double? average,
    int? count,
    Map<String, double>? categoryTotals,
    Map<DateTime, double>? dailyTotals,
  }) {
    return ExpenseSummary(
      total: total ?? this.total,
      average: average ?? this.average,
      count: count ?? this.count,
      categoryTotals: categoryTotals ?? this.categoryTotals,
      dailyTotals: dailyTotals ?? this.dailyTotals,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseSummary &&
        other.total == total &&
        other.average == average &&
        other.count == count &&
        other.categoryTotals == categoryTotals &&
        other.dailyTotals == dailyTotals;
  }

  @override
  int get hashCode {
    return Object.hash(total, average, count, categoryTotals, dailyTotals);
  }

  @override
  String toString() {
    return 'ExpenseSummary(total: $total, average: $average, count: $count, categoryTotals: $categoryTotals, dailyTotals: $dailyTotals)';
  }
}
