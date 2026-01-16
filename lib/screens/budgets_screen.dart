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
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
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

          final totalBudgeted = budgetProvider.budgets.fold(
            0.0,
            (sum, budget) => sum + budget.amount,
          );

          final income = incomeProvider.monthlyIncome;
          final remaining = expenseProvider.getRemainingAmount(income);
          final remainingColor =
              remaining >= 0 ? _creamText : _pastelRed;

          return Column(
            children: [
              const SizedBox(height: 8),

              /// OVERVIEW CARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(18),
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
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// MONTH SELECTOR + SUBTITLE
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            color: Colors.white,
                            onPressed: () {
                              final current = budgetProvider.selectedMonth;
                              final newMonth =
                                  DateTime(current.year, current.month - 1);
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Monthly Budget Overview',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            color: Colors.white,
                            onPressed: () {
                              final current = budgetProvider.selectedMonth;
                              final newMonth =
                                  DateTime(current.year, current.month + 1);
                              budgetProvider.changeMonth(newMonth);
                              incomeProvider.changeMonth(newMonth);
                              expenseProvider.changeMonth(newMonth);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// REMAINING INLINE
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${remaining.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: remainingColor,
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              remaining >= 0 ? 'Remaining' : 'Exceeded',
                              style: TextStyle(
                                color: remainingColor.withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.15),
                      ),

                      const SizedBox(height: 12),

                      /// SUMMARY ROWS
                      _OverviewRow(
                        icon: Icons.account_balance_wallet,
                        label: 'Income',
                        value: income,
                        editable: true,
                        onEdit: () => _editIncome(
                          context,
                          income,
                          budgetProvider,
                          incomeProvider,
                        ),
                      ),
                      _OverviewRow(
                        icon: Icons.shopping_cart,
                        label: 'Spent',
                        value: totalSpent,
                      ),
                      _OverviewRow(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Budgeted',
                        value: totalBudgeted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// REST OF SCREEN
              Expanded(
                child: budgetProvider.budgets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 46,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No budgets yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a budget to start tracking your spending',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: budgetProvider.budgets.length,
                        itemBuilder: (context, index) {
                          final budget = budgetProvider.budgets[index];
                          final spent = expenseProvider
                                  .spendingByCategory[budget.category] ??
                              0.0;

                          return _BudgetCard(
                            budget: budget,
                            spent: spent,
                            onEdit: () =>
                                _editBudget(context, budgetProvider, budget),
                            onDelete: () =>
                                _deleteBudget(context, budgetProvider, budget),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addBudget(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Budget'),
      ),
    );
  }

  void _addBudget(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddBudgetDialog(),
    );

    if (result != null && context.mounted) {
      final budgetProvider = context.read<BudgetProvider>();
      await budgetProvider.setBudget(
        result['category'] as String,
        result['amount'] as double,
        result['isRecurring'] as bool,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget added successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _editIncome(
    BuildContext context,
    double currentIncome,
    BudgetProvider budgetProvider,
    IncomeProvider incomeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          IncomeEditDialog(currentIncome: currentIncome),
    );
  }

  void _editBudget(
    BuildContext context,
    BudgetProvider provider,
    Budget budget,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddBudgetDialog(budget: budget),
    );

    if (result != null && context.mounted) {
      await provider.setBudget(
        result['category'] as String,
        result['amount'] as double,
        result['isRecurring'] as bool,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget updated successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _deleteBudget(
    BuildContext context,
    BudgetProvider provider,
    Budget budget,
  ) {
    provider.deleteBudget(budget.id!);
  }
}

/// OVERVIEW ROW
class _OverviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final bool editable;
  final VoidCallback? onEdit;

  const _OverviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.editable = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (editable && onEdit != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onEdit,
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final double spent;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.spent,
    required this.onEdit,
    required this.onDelete,
  });

  Color getStatusColor() {
    final remaining = budget.amount - spent;
    final percentage = (spent / budget.amount) * 100;
    
    // If exactly $0.00 left, return pink
    if (remaining == 0.0) return const Color.fromARGB(255, 245, 111, 156);
    if (percentage >= 100) return Colors.red;
    if (percentage >= 80) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = budget.amount > 0 ? (spent / budget.amount) * 100 : 0.0;
    final remaining = budget.amount - spent;
    final isOverBudget = spent > budget.amount;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        budget.category,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (budget.isRecurring)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.repeat, size: 10, color: Colors.blue),
                              SizedBox(width: 2),
                              Text(
                                'Recurring',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget: \$${budget.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Spent: \$${spent.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isOverBudget ? Colors.red : Colors.grey[600],
                          fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isOverBudget ? 'Exceeded' : 'Left',
                        style: TextStyle(
                          fontSize: 10,
                          color: getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${remaining.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (percentage / 100).clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(getStatusColor()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: getStatusColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}