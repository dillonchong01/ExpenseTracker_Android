import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../database/database_helper.dart';

class BudgetProvider with ChangeNotifier {
  List<Budget> _budgets = [];
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  List<Budget> get budgets => _budgets;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  BudgetProvider() {
    loadBudgets();
    _checkAndAddRecurringBudgets();
  }

  // Check and add recurring budgets for the current month
  Future<void> _checkAndAddRecurringBudgets() async {
    final now = DateTime.now();

    final hasRecurring =
        await DatabaseHelper.instance.hasRecurringBudgetsForMonth(
      now.year,
      now.month,
    );

    if (!hasRecurring) {
      final recurringBudgets =
          await DatabaseHelper.instance.getRecurringBudgets();

      // Get unique recurring budgets by category (take the most recent one)
      final Map<String, Budget> uniqueRecurring = {};
      for (var budget in recurringBudgets) {
        final key = budget.category;
        if (!uniqueRecurring.containsKey(key) ||
            (budget.year > uniqueRecurring[key]!.year ||
                (budget.year == uniqueRecurring[key]!.year &&
                    budget.month > uniqueRecurring[key]!.month))) {
          uniqueRecurring[key] = budget;
        }
      }

      // Add recurring budgets to current month
      for (var budget in uniqueRecurring.values) {
        final newBudget = budget.copyWith(
          id: null,
          year: now.year,
          month: now.month,
        );
        await DatabaseHelper.instance.insertBudget(newBudget);
      }

      if (uniqueRecurring.isNotEmpty) {
        await loadBudgets();
      }
    }
  }

  // Load budgets for the selected month
  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    _budgets = await DatabaseHelper.instance.getBudgetsByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    _isLoading = false;
    notifyListeners();
  }

  // Add or update a budget
  Future<void> setBudget(String category, double amount, bool isRecurring) async {
    // Check if budget exists for this month and category
    final existingBudget =
        await DatabaseHelper.instance.getBudgetByCategoryAndMonth(
      category,
      _selectedMonth.year,
      _selectedMonth.month,
    );

    if (existingBudget != null) {
      // Update existing budget
      final updatedBudget = existingBudget.copyWith(
        amount: amount,
        isRecurring: isRecurring,
      );
      await DatabaseHelper.instance.updateBudget(updatedBudget);
    } else {
      // Insert new budget
      final budget = Budget(
        category: category,
        amount: amount,
        year: _selectedMonth.year,
        month: _selectedMonth.month,
        isRecurring: isRecurring,
      );
      await DatabaseHelper.instance.insertBudget(budget);
    }

    await loadBudgets();
  }

  // Delete a budget
  Future<void> deleteBudget(int id) async {
    await DatabaseHelper.instance.deleteBudget(id);
    await loadBudgets();
  }

  // Get budget for a specific category
  Budget? getBudgetForCategory(String category) {
    try {
      return _budgets.firstWhere((budget) => budget.category == category);
    } catch (e) {
      return null;
    }
  }

  // Check if a category has a budget
  bool hasBudget(String category) {
    return _budgets.any((budget) => budget.category == category);
  }

  // Change selected month
  void changeMonth(DateTime newMonth) {
    _selectedMonth = DateTime(newMonth.year, newMonth.month);
    loadBudgets();
  }

  // Get all recurring budgets
  Future<List<Budget>> getRecurringBudgets() async {
    return await DatabaseHelper.instance.getRecurringBudgets();
  }
}