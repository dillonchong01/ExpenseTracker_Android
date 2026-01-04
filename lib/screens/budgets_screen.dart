import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_provider.dart';
import '../models/budget.dart';
import '../widgets/add_budget_dialog.dart';
import '../widgets/income_edit_dialog.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  static const Color _steelBlueDark = Color(0xFF2E4A62);
  static const Color _steelBlueLight = Color(0xFF6B8FAF);
  static const Color _creamText = Color(0xFFFFF3D6);
  static const Color _pastelRed = Color(0xFFFFB3B3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        elevation: 0,
      ),
      body: Consumer3<BudgetProvider, ExpenseProvider, IncomeProvider>(
        builder: (context, budgetProvider, expenseProvider, incomeProvider, _) {
          if (budgetProvider.isLoading || incomeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalSpent =
              expenseProvider.selectedMonth.year ==
                          budgetProvider.selectedMonth.year &&
                      expenseProvider.selectedMonth.month ==
                          budgetProvider.selectedMonth.month
                  ? expenseProvider.totalSpending
                  : 0.0;

          final income = incomeProvider.monthlyIncome;
          final remaining = income - totalSpent;
          final remainingColor =
              remaining >= 0 ? _creamText : _pastelRed;

          return Column(
            children: [
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [_steelBlueDark, _steelBlueLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            color: Colors.white,
                            onPressed: () {
                              final current =
                                  budgetProvider.selectedMonth;
                              final newMonth = DateTime(
                                  current.year, current.month - 1);
                              budgetProvider.changeMonth(newMonth);
                              incomeProvider.changeMonth(newMonth);
                              expenseProvider.changeMonth(newMonth);
                            },
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('MMMM yyyy')
                                      .format(budgetProvider.selectedMonth),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Monthly budget overview',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            color: Colors.white,
                            onPressed: () {
                              final current =
                                  budgetProvider.selectedMonth;
                              final newMonth = DateTime(
                                  current.year, current.month + 1);
                              budgetProvider.changeMonth(newMonth);
                              incomeProvider.changeMonth(newMonth);
                              expenseProvider.changeMonth(newMonth);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Monthly Overview',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white),
                            onPressed: () => _editIncome(
                              context,
                              income,
                              budgetProvider,
                              incomeProvider,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _OverviewItem(
                              icon:
                                  Icons.account_balance_wallet,
                              label: 'Income',
                              amount: income,
                              color: Colors.white,
                            ),
                          ),
                          _VerticalSeparator(),
                          Expanded(
                            child: _OverviewItem(
                              icon: Icons.shopping_cart,
                              label: 'Spent',
                              amount: totalSpent,
                              color: Colors.white,
                            ),
                          ),
                          _VerticalSeparator(),
                          Expanded(
                            child: _OverviewItem(
                              icon: remaining >= 0
                                  ? Icons.account_balance
                                  : Icons.warning_amber_rounded,
                              label:
                                  remaining >= 0 ? 'Remaining' : 'Over',
                              amount: remaining.abs(),
                              color: remainingColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Category Budgets',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${budgetProvider.budgets.length} categories',
                      style:
                          TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: budgetProvider.budgets.isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .surface,
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withOpacity(0.7),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.06),
                                ),
                                child: Icon(
                                  Icons
                                      .account_balance_wallet_outlined,
                                  size: 46,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No budgets set',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontSize: 18,
                                      color: Colors.grey[700],
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to create your first budget',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                        itemCount:
                            budgetProvider.budgets.length,
                        itemBuilder: (context, index) {
                          final budget =
                              budgetProvider.budgets[index];
                          final spent = expenseProvider
                                  .spendingByCategory[
                              budget.category] ??
                              0.0;
                          final percentage =
                              (spent / budget.amount * 100)
                                  .clamp(0, 150)
                                  .toDouble();

                          return _BudgetCard(
                            budget: budget,
                            spent: spent,
                            percentage: percentage,
                            onEdit: () => _editBudget(
                                context,
                                budget,
                                budgetProvider),
                            onDelete: () => _deleteBudget(
                                context,
                                budget,
                                budgetProvider),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addBudget(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addBudget(BuildContext context) async {
    final provider = context.read<BudgetProvider>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const AddBudgetDialog(),
    );

    if (result != null) {
      await provider.setBudget(
        result['category'],
        result['amount'],
        result['isRecurring'] ?? false,
      );
    }
  }

  void _editBudget(
      BuildContext context, Budget budget, BudgetProvider provider) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AddBudgetDialog(budget: budget),
    );

    if (result != null) {
      await provider.setBudget(
        result['category'],
        result['amount'],
        result['isRecurring'] ?? false,
      );
    }
  }

  void _deleteBudget(
      BuildContext context, Budget budget, BudgetProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Budget'),
        content:
            Text('Are you sure you want to delete ${budget.category}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style:
                TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && budget.id != null) {
      await provider.deleteBudget(budget.id!);
    }
  }

  void _editIncome(
    BuildContext context,
    double currentIncome,
    BudgetProvider budgetProvider,
    IncomeProvider incomeProvider,
  ) async {
    final result = await showDialog<double>(
      context: context,
      builder: (_) =>
          IncomeEditDialog(currentIncome: currentIncome),
    );

    if (result != null) {
      await incomeProvider.setMonthlyIncome(result);
      context
          .read<ExpenseProvider>()
          .changeMonth(budgetProvider.selectedMonth);
    }
  }
}

class _OverviewItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _OverviewItem({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _VerticalSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withOpacity(0.25),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final double percentage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.percentage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverBudget = spent > budget.amount;
    final remaining = budget.amount - spent;

    Color getStatusColor() {
      if (isOverBudget) return Colors.red;
      if (percentage > 75) return Colors.orange;
      return Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: getStatusColor()
                            .withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.category,
                        color: getStatusColor(),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              budget.category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            if (budget.isRecurring)
                              Container(
                                margin:
                                    const EdgeInsets.only(
                                        left: 8),
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue
                                      .withOpacity(0.1),
                                  borderRadius:
                                      BorderRadius.circular(
                                          8),
                                ),
                                child: const Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Icon(Icons.repeat,
                                        size: 11,
                                        color:
                                            Colors.blue),
                                    SizedBox(width: 3),
                                    Text(
                                      'Recurring',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color:
                                            Colors.blue,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Text(
                          'Budget: \$${budget.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton(
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit,
                              size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              size: 20,
                              color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(
                                  color:
                                      Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value ==
                        'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spent',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '\$${spent.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color: isOverBudget
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOverBudget
                          ? 'Over'
                          : 'Remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '\$${remaining.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color: getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (percentage / 100)
                    .clamp(0, 1),
                minHeight: 10,
                backgroundColor:
                    Colors.grey[300],
                valueColor:
                    AlwaysStoppedAnimation<
                        Color>(getStatusColor()),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}% used',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}