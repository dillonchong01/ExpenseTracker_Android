class IncomeSettings {
  final int? id;
  final double monthlyIncome;
  final int year;
  final int month;
  final DateTime lastUpdated;

  IncomeSettings({
    this.id,
    required this.monthlyIncome,
    required this.year,
    required this.month,
    required this.lastUpdated,
  });

  // Convert IncomeSettings to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthlyIncome': monthlyIncome,
      'year': year,
      'month': month,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Create IncomeSettings from Map (database retrieval)
  factory IncomeSettings.fromMap(Map<String, dynamic> map) {
    return IncomeSettings(
      id: map['id'] as int?,
      monthlyIncome: map['monthlyIncome'] as double,
      year: map['year'] as int,
      month: map['month'] as int,
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    );
  }

  // Copy method for updating income settings
  IncomeSettings copyWith({
    int? id,
    double? monthlyIncome,
    int? year,
    int? month,
    DateTime? lastUpdated,
  }) {
    return IncomeSettings(
      id: id ?? this.id,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      year: year ?? this.year,
      month: month ?? this.month,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}