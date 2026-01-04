import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/income_settings.dart';
import '../models/savings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Handle database upgrades
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add isRecurring column to expenses
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN isRecurring INTEGER DEFAULT 0',
      );

      // Create income_settings table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS income_settings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          monthlyIncome REAL NOT NULL,
          lastUpdated TEXT NOT NULL
        )
      ''');

      // Create savings table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS savings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          note TEXT
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Add year, month, and isRecurring columns to budgets
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN year INTEGER NOT NULL DEFAULT 2024',
      );
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN month INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE budgets ADD COLUMN isRecurring INTEGER DEFAULT 0',
      );

      // Add year and month columns to income_settings
      await db.execute(
        'ALTER TABLE income_settings ADD COLUMN year INTEGER NOT NULL DEFAULT 2024',
      );
      await db.execute(
        'ALTER TABLE income_settings ADD COLUMN month INTEGER NOT NULL DEFAULT 1',
      );

      // Update existing budgets to current month/year
      final now = DateTime.now();
      await db.execute(
        'UPDATE budgets SET year = ?, month = ? WHERE year = 2024 AND month = 1',
        [now.year, now.month],
      );

      // Update existing income_settings to current month/year
      await db.execute(
        'UPDATE income_settings SET year = ?, month = ? WHERE year = 2024 AND month = 1',
        [now.year, now.month],
      );
    }
  }

  // Create tables
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses (
        id $idType,
        name $textType,
        category $textType,
        price $realType,
        description TEXT,
        date $textType,
        isRecurring INTEGER DEFAULT 0
      )
    ''');

    // Budgets table with year, month, and isRecurring
    await db.execute('''
      CREATE TABLE budgets (
        id $idType,
        category $textType,
        amount $realType,
        year $intType,
        month $intType,
        isRecurring INTEGER DEFAULT 0
      )
    ''');

    // Income settings table with year and month
    await db.execute('''
      CREATE TABLE income_settings (
        id $idType,
        monthlyIncome $realType,
        year $intType,
        month $intType,
        lastUpdated $textType
      )
    ''');

    // Savings table
    await db.execute('''
      CREATE TABLE savings (
        id $idType,
        amount $realType,
        date $textType,
        note TEXT
      )
    ''');
  }

  // ========== EXPENSE OPERATIONS ==========

  Future<Expense> insertExpense(Expense expense) async {
    final db = await instance.database;
    final id = await db.insert('expenses', expense.toMap());
    return expense.copyWith(id: id);
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    final db = await instance.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<List<Expense>> getRecurringExpenses() async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      where: 'isRecurring = ?',
      whereArgs: [1],
      orderBy: 'date DESC',
    );
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await instance.database;
    return db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await instance.database;
    return db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> hasRecurringExpensesForMonth(int year, int month) async {
    final db = await instance.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.query(
      'expenses',
      where: 'isRecurring = ? AND date >= ? AND date <= ?',
      whereArgs: [1, startDate.toIso8601String(), endDate.toIso8601String()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ========== BUDGET OPERATIONS ==========

  Future<Budget> insertBudget(Budget budget) async {
    final db = await instance.database;
    final id = await db.insert('budgets', budget.toMap());
    return budget.copyWith(id: id);
  }

  Future<List<Budget>> getBudgetsByMonth(int year, int month) async {
    final db = await instance.database;
    final result = await db.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
      orderBy: 'category ASC',
    );
    return result.map((json) => Budget.fromMap(json)).toList();
  }

  Future<List<Budget>> getAllBudgets() async {
    final db = await instance.database;
    final result = await db.query('budgets', orderBy: 'category ASC');
    return result.map((json) => Budget.fromMap(json)).toList();
  }

  Future<Budget?> getBudgetByCategoryAndMonth(
      String category, int year, int month) async {
    final db = await instance.database;
    final result = await db.query(
      'budgets',
      where: 'category = ? AND year = ? AND month = ?',
      whereArgs: [category, year, month],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Budget.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await instance.database;
    return db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await instance.database;
    return db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Budget>> getRecurringBudgets() async {
    final db = await instance.database;
    final result = await db.query(
      'budgets',
      where: 'isRecurring = ?',
      whereArgs: [1],
    );
    return result.map((json) => Budget.fromMap(json)).toList();
  }

  Future<bool> hasRecurringBudgetsForMonth(int year, int month) async {
    final db = await instance.database;
    final result = await db.query(
      'budgets',
      where: 'isRecurring = ? AND year = ? AND month = ?',
      whereArgs: [1, year, month],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ========== INCOME SETTINGS OPERATIONS ==========

  Future<IncomeSettings> insertIncomeSettings(IncomeSettings settings) async {
    final db = await instance.database;
    final id = await db.insert('income_settings', settings.toMap());
    return settings.copyWith(id: id);
  }

  Future<IncomeSettings?> getIncomeSettingsByMonth(
      int year, int month) async {
    final db = await instance.database;
    final result = await db.query(
      'income_settings',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return IncomeSettings.fromMap(result.first);
    }
    return null;
  }

  Future<IncomeSettings?> getIncomeSettings() async {
    final db = await instance.database;
    final result = await db.query('income_settings', limit: 1);

    if (result.isNotEmpty) {
      return IncomeSettings.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateIncomeSettings(IncomeSettings settings) async {
    final db = await instance.database;
    return db.update(
      'income_settings',
      settings.toMap(),
      where: 'id = ?',
      whereArgs: [settings.id],
    );
  }

  // ========== SAVINGS OPERATIONS ==========

  Future<Savings> insertSavings(Savings savings) async {
    final db = await instance.database;
    final id = await db.insert('savings', savings.toMap());
    return savings.copyWith(id: id);
  }

  Future<List<Savings>> getAllSavings() async {
    final db = await instance.database;
    final result = await db.query('savings', orderBy: 'date DESC');
    return result.map((json) => Savings.fromMap(json)).toList();
  }

  Future<List<Savings>> getSavingsByMonth(int year, int month) async {
    final db = await instance.database;
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    final result = await db.query(
      'savings',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'date DESC',
    );

    return result.map((json) => Savings.fromMap(json)).toList();
  }

  Future<double> getTotalSavings() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM savings');

    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as double;
    }
    return 0.0;
  }

  Future<int> updateSavings(Savings savings) async {
    final db = await instance.database;
    return db.update(
      'savings',
      savings.toMap(),
      where: 'id = ?',
      whereArgs: [savings.id],
    );
  }

  Future<int> deleteSavings(int id) async {
    final db = await instance.database;
    return db.delete(
      'savings',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== CATEGORY FETCH ==========

  Future<List<String>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM expenses ORDER BY category ASC',
    );
    return result.map((row) => row['category'] as String).toList();
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}