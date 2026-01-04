import 'package:flutter/foundation.dart';
import '../models/income_settings.dart';
import '../database/database_helper.dart';

class IncomeProvider with ChangeNotifier {
  IncomeSettings? _incomeSettings;
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  IncomeSettings? get incomeSettings => _incomeSettings;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;
  double get monthlyIncome => _incomeSettings?.monthlyIncome ?? 0.0;

  IncomeProvider() {
    loadIncomeSettings();
  }

  // Load income settings for the selected month
  Future<void> loadIncomeSettings() async {
    _isLoading = true;
    notifyListeners();

    _incomeSettings =
        await DatabaseHelper.instance.getIncomeSettingsByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    _isLoading = false;
    notifyListeners();
  }

  // Set monthly income for the selected month
  Future<void> setMonthlyIncome(double amount) async {
    // Check if income exists for this month
    final existingIncome =
        await DatabaseHelper.instance.getIncomeSettingsByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    if (existingIncome != null) {
      // Update existing income
      final updatedIncome = existingIncome.copyWith(
        monthlyIncome: amount,
        lastUpdated: DateTime.now(),
      );
      await DatabaseHelper.instance.updateIncomeSettings(updatedIncome);
    } else {
      // Insert new income
      final settings = IncomeSettings(
        monthlyIncome: amount,
        year: _selectedMonth.year,
        month: _selectedMonth.month,
        lastUpdated: DateTime.now(),
      );
      await DatabaseHelper.instance.insertIncomeSettings(settings);
    }

    await loadIncomeSettings();
  }

  // Change selected month
  void changeMonth(DateTime newMonth) {
    _selectedMonth = DateTime(newMonth.year, newMonth.month);
    loadIncomeSettings();
  }

  // Check if income is set for the current month
  bool get hasIncome =>
      _incomeSettings != null && _incomeSettings!.monthlyIncome > 0;
}