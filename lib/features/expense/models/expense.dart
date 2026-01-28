class Expense {
  final String id;
  final String name;
  final double amount;
  final String category;
  final String note;
  final DateTime createdAt;
  final DateTime date;
  final String currency;

  const Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.note,
    required this.createdAt,
    required this.date,
    required this.currency,
  });

  // factory Expense.fromJson(Map<String, dynamic> json) {
  //   return Expense(
  //     id: json['id'] as String,
  //     name: json['name'] as String? ?? 'Expense',
  //     amount: double.tryParse(json['amount'].toString()) ?? 0.0,
  //     category: json['category'] as String,
  //     note: json['note'] as String? ?? '',
  //     createdAt: DateTime.parse(json['created_at'] as String),
  //     date: DateTime.parse(json['expense_date'] as String),
  //     currency: json['currency'] as String? ?? 'USD',
  //   );
  // }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      amount: double.parse(json['amount'].toString()),
      category: json['category'],
      note: json['note'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      date: DateTime.parse(json['expense_date']),
      currency: 'MMK',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'name': name,
      'amount': amount.round(),
      'category': category,
      'note': note,
      // 'created_at': createdAt.toIso8601String(),
      // 'expense_date': date.toIso8601String(),
      // 'currency': currency,
    };
  }

  Expense copyWith({
    String? id,
    String? name,
    double? amount,
    String? category,
    String? note,
    DateTime? createdAt,
    DateTime? date,
    String? currency,
  }) {
    return Expense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      date: date ?? this.date,
      currency: currency ?? this.currency,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense &&
        other.id == id &&
        other.amount == amount &&
        other.category == category &&
        other.note == note &&
        other.createdAt == createdAt &&
        other.date == date &&
        other.currency == currency;
  }

  @override
  int get hashCode {
    return Object.hash(id, amount, category, note, createdAt, date, currency);
  }

  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, category: $category, note: $note, createdAt: $createdAt, date: $date, currency: $currency)';
  }
}
