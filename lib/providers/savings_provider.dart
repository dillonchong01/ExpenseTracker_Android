import 'package:flutter/foundation.dart';
import '../models/savings.dart';
import '../database/database_helper.dart';

class SavingsProvider with ChangeNotifier {
  List<Savings> _savings = [];
  double _totalSavings = 0.0;
  bool _isLoading = false;

  List<Savings> get savings => _savings;
  double get totalSavings => _totalSavings;
  bool get isLoading => _isLoading;

  SavingsProvider() {
    loadSavings();
  }

  // Load all savings
  Future<void> loadSavings() async {
    _isLoading = true;
    notifyListeners();

    _savings = await DatabaseHelper.instance.getAllSavings();
    _totalSavings = await DatabaseHelper.instance.getTotalSavings();

    _isLoading = false;
    notifyListeners();
  }

  // Add savings
  Future<void> addSavings(double amount, DateTime date, String? note) async {
    final savings = Savings(
      amount: amount,
      date: date,
      note: note,
    );
    
    await DatabaseHelper.instance.insertSavings(savings);
    await loadSavings();
  }

  // Update savings
  Future<void> updateSavings(Savings savings) async {
    await DatabaseHelper.instance.updateSavings(savings);
    await loadSavings();
  }

  // Delete savings
  Future<void> deleteSavings(int id) async {
    await DatabaseHelper.instance.deleteSavings(id);
    await loadSavings();
  }

  // Get monthly savings trend
  Future<Map<String, double>> getMonthlySavingsTrend() async {
    final Map<String, double> monthlySavings = {};
    final now = DateTime.now();
    
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      final savingsForMonth = await DatabaseHelper.instance.getSavingsByMonth(
        date.year,
        date.month,
      );
      
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlySavings[monthKey] = savingsForMonth.fold(
        0.0,
        (sum, saving) => sum + saving.amount,
      );
    }

    return monthlySavings;
  }

  // Get cumulative savings over time
  Future<Map<String, double>> getCumulativeSavings() async {
    final Map<String, double> cumulativeSavings = {};
    final now = DateTime.now();
    double cumulative = 0.0;
    
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      final savingsForMonth = await DatabaseHelper.instance.getSavingsByMonth(
        date.year,
        date.month,
      );
      
      cumulative += savingsForMonth.fold(
        0.0,
        (sum, saving) => sum + saving.amount,
      );
      
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      cumulativeSavings[monthKey] = cumulative;
    }

    return cumulativeSavings;
  }
}