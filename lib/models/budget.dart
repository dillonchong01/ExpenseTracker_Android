class Budget {
  final int? id;
  final String category;
  final double amount;
  final int year;
  final int month;
  final bool isRecurring;

  Budget({
    this.id,
    required this.category,
    required this.amount,
    required this.year,
    required this.month,
    this.isRecurring = false,
  });

  // Convert Budget to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'year': year,
      'month': month,
      'isRecurring': isRecurring ? 1 : 0,
    };
  }

  // Create Budget from Map (database retrieval)
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: map['amount'] as double,
      year: map['year'] as int,
      month: map['month'] as int,
      isRecurring: (map['isRecurring'] as int?) == 1,
    );
  }

  // Copy method for updating budgets
  Budget copyWith({
    int? id,
    String? category,
    double? amount,
    int? year,
    int? month,
    bool? isRecurring,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      year: year ?? this.year,
      month: month ?? this.month,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}