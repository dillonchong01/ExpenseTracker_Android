class Savings {
  final int? id;
  final double amount;
  final DateTime date;
  final String? note;

  Savings({
    this.id,
    required this.amount,
    required this.date,
    this.note,
  });

  // Convert Savings to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  // Create Savings from Map (database retrieval)
  factory Savings.fromMap(Map<String, dynamic> map) {
    return Savings(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      note: map['note'] as String?,
    );
  }

  // Copy method for updating savings
  Savings copyWith({
    int? id,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return Savings(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}