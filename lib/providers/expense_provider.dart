import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;
  String? _selectedCategory;

  List<Expense> get expenses => _expenses;
  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;
  String? get selectedCategory => _selectedCategory;

  ExpenseProvider() {
    loadExpenses();
    _checkAndAddRecurringExpenses();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<Expense> get filteredExpenses {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return _expenses;
    }
    return _expenses.where((e) => e.category == _selectedCategory).toList();
  }

  // NEW: Get expenses grouped by date (most recent first)
  Map<DateTime, List<Expense>> getExpensesGroupedByDate() {
    final Map<DateTime, List<Expense>> grouped = {};
    
    for (var expense in filteredExpenses) {
      // Normalize date to midnight for grouping
      final dateKey = DateTime(expense.date.year, expense.date.month, expense.date.day);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(expense);
    }
    
    // Sort each day's expenses by time (most recent first)
    grouped.forEach((date, expenses) {
      expenses.sort((a, b) => b.date.compareTo(a.date));
    });
    
    return grouped;
  }

  // NEW: Get sorted dates (most recent first)
  List<DateTime> getSortedDates() {
    final dates = getExpensesGroupedByDate().keys.toList();
    dates.sort((a, b) => b.compareTo(a));
    return dates;
  }

  // NEW: Get total savings for the selected month
  double getTotalSavingsForMonth() {
    final savingsExpenses = _expenses.where((e) => e.category == 'Savings');
    return savingsExpenses.fold(0.0, (sum, expense) => sum + expense.price);
  }

  // NEW: Get remaining amount (requires income to be passed in)
  double getRemainingAmount(double income) {
    final totalSpent = totalSpending;
    final savings = _expenses
        .where((e) => e.category == 'Savings')
        .fold(0.0, (sum, expense) => sum + expense.price);
    
    return income - totalSpent - savings;
  }

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

  Future<void> addExpense(Expense expense) async {
    await DatabaseHelper.instance.insertExpense(expense);

    if (expense.date.year == _selectedMonth.year &&
        expense.date.month == _selectedMonth.month) {
      await loadExpenses();
    }
  }

  Future<void> updateExpense(Expense expense) async {
    await DatabaseHelper.instance.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(int id) async {
    await DatabaseHelper.instance.deleteExpense(id);
    await loadExpenses();
  }

  void changeMonth(DateTime newMonth) {
    _selectedMonth = DateTime(newMonth.year, newMonth.month);
    loadExpenses();
  }

  Future<List<String>> getAllCategories() async {
    return await DatabaseHelper.instance.getAllCategories();
  }

  Future<List<Expense>> getAllExpensesEver() async {
    return await DatabaseHelper.instance.getAllExpenses();
  }

  double get totalSpending {
    return _expenses
        .where((expense) => expense.category != 'Savings')
        .fold(0.0, (sum, expense) => sum + expense.price);
  }

  Map<String, double> get spendingByCategory {
    final Map<String, double> categorySpending = {};
    for (var expense in _expenses) {
      if (expense.category != 'Savings') {
        categorySpending[expense.category] =
            (categorySpending[expense.category] ?? 0) + expense.price;
      }
    }
    return categorySpending;
  }

  Future<List<double>> getWeeklySpending() async {
    final expenses = await DatabaseHelper.instance.getExpensesByMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );

    final nonRecurringExpenses = expenses
        .where((e) => !e.isRecurring && e.category != 'Savings')
        .toList();

    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final totalDays = lastDay.day;
    final numWeeks = (totalDays / 7).ceil();
    final weeklySpending = List<double>.filled(numWeeks, 0.0);

    for (var expense in nonRecurringExpenses) {
      final dayOfMonth = expense.date.day;
      final weekIndex = ((dayOfMonth - 1) / 7).floor();
      if (weekIndex < numWeeks) {
        weeklySpending[weekIndex] += expense.price;
      }
    }

    return weeklySpending;
  }

  Future<Map<String, double>> getMonthlySpending() async {
    final Map<String, double> monthlySpending = {};
    
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(_selectedMonth.year, _selectedMonth.month - i);
      final expenses = await DatabaseHelper.instance.getExpensesByMonth(
        date.year,
        date.month,
      );
      
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      monthlySpending[monthKey] = expenses
          .where((e) => e.category != 'Savings')
          .fold(0.0, (sum, expense) => sum + expense.price);
    }

    return monthlySpending;
  }

  Future<List<Expense>> getRecurringExpenses() async {
    return await DatabaseHelper.instance.getRecurringExpenses();
  }
}