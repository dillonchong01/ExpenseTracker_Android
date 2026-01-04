import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  ExpenseProvider() {
    loadExpenses();
    _checkAndAddRecurringExpenses();
  }

  // Check and add recurring expenses for the current month
  Future<void> _checkAndAddRecurringExpenses() async {
    final now = DateTime.now();
    
    final hasRecurring = await DatabaseHelper.instance.hasRecurringExpensesForMonth(
      now.year,
      now.month,
    );

    if (!hasRecurring) {
      final recurringExpenses = await DatabaseHelper.instance.getRecurringExpenses();
      
      final Map<String, Expense> uniqueRecurring = {};
      for (var expense in recurringExpenses) {
        final key = '${expense.name}_${expense.category}';
        if (!uniqueRecurring.containsKey(key) ||
            expense.date.isAfter(uniqueRecurring[key]!.date)) {
          uniqueRecurring[key] = expense;
        }
      }

      for (var expense in uniqueRecurring.values) {
        final newExpense = expense.copyWith(
          id: null,
          date: DateTime(now.year, now.month, 1),
        );
        await DatabaseHelper.instance.insertExpense(newExpense);
      }

      if (uniqueRecurring.isNotEmpty) {
        await loadExpenses();
      }
    }
  }

  // Load expenses for the selected month
  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    _expenses = await DatabaseHelper.instance.getExpensesByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    _isLoading = false;
    notifyListeners();
  }

  // Add a new expense
  Future<void> addExpense(Expense expense) async {
    await DatabaseHelper.instance.insertExpense(expense);

    if (expense.date.year == _selectedMonth.year &&
        expense.date.month == _selectedMonth.month) {
      await loadExpenses();
    }
  }

  // Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    await DatabaseHelper.instance.updateExpense(expense);
    await loadExpenses();
  }

  // Delete an expense
  Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    await loadExpenses();
  }

  // Change selected month
  void changeMonth(DateTime newMonth) {
    _selectedMonth = DateTime(newMonth.year, newMonth.month);
    loadExpenses();
  }

  // Get all unique categories
  Future<List<String>> getAllCategories() async {
    return await DatabaseHelper.instance.getAllCategories();
  }

  // Get all expenses across all time
  Future<List<Expense>> getAllExpensesEver() async {
    return await DatabaseHelper.instance.getAllExpenses();
  }

  // Get total spending for the current month
  double get totalSpending {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.price);
  }

  // Get spending by category for the current month
  Map<String, double> get spendingByCategory {
    final Map<String, double> categorySpending = {};
    for (var expense in _expenses) {
      categorySpending[expense.category] =
          (categorySpending[expense.category] ?? 0) + expense.price;
    }
    return categorySpending;
  }

  // Get weekly spending trend for the current month
  Future<List<double>> getWeeklySpending() async {
    final expenses = await DatabaseHelper.instance.getExpensesByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final totalDays = lastDay.day;
    final numWeeks = (totalDays / 7).ceil();
    final weeklySpending = List<double>.filled(numWeeks, 0.0);

    for (var expense in expenses) {
      final dayOfMonth = expense.date.day;
      final weekIndex = ((dayOfMonth - 1) / 7).floor();
      if (weekIndex < numWeeks) {
        weeklySpending[weekIndex] += expense.price;
      }
    }

    return weeklySpending;
  }

  // Get monthly spending trend for the last 6 months
  Future<Map<String, double>> getMonthlySpending() async {
    final Map<String, double> monthlySpending = {};
    
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month - i);
      final expenses = await DatabaseHelper.instance.getExpensesByMonth(
        date.year,
        date.month,
      );
      
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlySpending[monthKey] = expenses.fold(
        0.0,
        (sum, expense) => sum + expense.price,
      );
    }

    return monthlySpending;
  }

  // Get all recurring expenses
  Future<List<Expense>> getRecurringExpenses() async {
    return await DatabaseHelper.instance.getRecurringExpenses();
  }
}