import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/budget.dart';
import '../utils/constants.dart';

class AddBudgetDialog extends StatefulWidget {
  final Budget? budget;

  const AddBudgetDialog({super.key, this.budget});

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;

  String _selectedCategory = AppConstants.expenseCategories.first;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();

    _amountController = TextEditingController(
      text: widget.budget?.amount.toStringAsFixed(2) ?? '',
    );

    final initialCategory = widget.budget?.category;
    _selectedCategory = AppConstants.expenseCategories.contains(initialCategory)
        ? initialCategory!
        : AppConstants.expenseCategories.first;

    _isRecurring = widget.budget?.isRecurring ?? false;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.budget != null;

    final String safeCategory =
        AppConstants.expenseCategories.contains(_selectedCategory)
            ? _selectedCategory
            : AppConstants.expenseCategories.first;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (same structure as expense dialog)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color:
                            Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Budget' : 'Add Budget',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Category (NOW MATCHES EXPENSE DIALOG)
                DropdownButtonFormField<String>(
                  value: safeCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(
                      AppConstants.getCategoryIcon(safeCategory),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                  ),
                  items: AppConstants.expenseCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: isEdit
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Amount (NOW ALIGNED)
                TextFormField(
                  controller: _amountController,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Monthly Amount',
                    prefixIcon:
                        const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    filled: true,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Recurring switch (same visual weight as expense)
                SwitchListTile(
                  title: const Text('Recurring Budget'),
                  subtitle: const Text('Repeats every month'),
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                    });
                  },
                  secondary: const Icon(Icons.repeat),
                ),

                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, {
                            'category': safeCategory,
                            'amount':
                                double.parse(_amountController.text),
                            'isRecurring': _isRecurring,
                          });
                        }
                      },
                      icon: Icon(isEdit ? Icons.check : Icons.add),
                      label: Text(isEdit ? 'Update' : 'Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}