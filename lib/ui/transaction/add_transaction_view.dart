import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'expenditure_view_model.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/tag.dart';
import '../helpers/currency_input_formatter.dart';

class AddTransactionView extends StatefulWidget {
  final Expenditure?
  expenditure; // If null, it's Add mode. If set, it's Edit mode.

  const AddTransactionView({super.key, this.expenditure});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final TextEditingController _amountController = TextEditingController();
  bool _isIncome = false;
  String? _selectedTagId;
  DateTime _selectedDate = DateTime.now();
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    isEditing = widget.expenditure != null;
    if (isEditing) {
      final e = widget.expenditure!;
      _amountController.text = NumberFormat.decimalPattern(
        'vi_VN',
      ).format(e.amount);
      _isIncome = e.isIncome;
      _selectedTagId = e.mainTagId;
      _selectedDate = e.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ExpenditureViewModel>(context);
    final tags = viewModel.tags;

    // Auto-select first tag only if NOT editing and no selection yet
    if (_selectedTagId == null && tags.isNotEmpty && !isEditing) {
      _selectedTagId = tags.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Transaction" : "Fast Add Transaction"),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Transaction?"),
                    content: const Text("This action cannot be undone."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CANCEL"),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context); // Close dialog
                          await viewModel.deleteExpenditure(
                            widget.expenditure!.id,
                          );
                          if (context.mounted) {
                            Navigator.pop(context); // Close Edit View
                          }
                        },
                        child: const Text(
                          "DELETE",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Amount Display
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [DecimalCurrencyInputFormatter(locale: 'vi_VN')],
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
                prefixText: "₫ ",
                hintText: "0",
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              autofocus: !isEditing, // Only autofocus on new
            ),
            const SizedBox(height: 16),

            // 2. Date Picker
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMMMEd('vi_VN').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Type Selector
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Expense"),
                    selected: !_isIncome,
                    onSelected: (selected) {
                      setState(() => _isIncome = !selected);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text("Income"),
                    selected: _isIncome,
                    onSelected: (selected) {
                      setState(() => _isIncome = selected);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Category Selector
            if (tags.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTagId,
                    isDense: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTagId = newValue;
                      });
                    },
                    items: tags.map((Tag tag) {
                      return DropdownMenuItem<String>(
                        value: tag.id,
                        child: Row(
                          children: [
                            Icon(
                              tag.iconName == 'fastfood'
                                  ? Icons.fastfood
                                  : tag.iconName == 'directions_bus'
                                  ? Icons.directions_bus
                                  : tag.iconName == 'shopping_bag'
                                  ? Icons.shopping_bag
                                  : tag.iconName == 'attach_money'
                                  ? Icons.attach_money
                                  : Icons.label,
                              color: Color(tag.colorValue),
                            ),
                            const SizedBox(width: 8),
                            Text(tag.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            const Spacer(),

            // 5. Save/Update Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final rawAmount = _amountController.text
                            .replaceAll('.', '')
                            .replaceAll(',', '');
                        final amount = double.tryParse(rawAmount);

                        if (amount == null || amount <= 0) return;
                        if (_selectedTagId == null) return;

                        if (isEditing) {
                          // Update existing
                          final updatedExpenditure = Expenditure(
                            id: widget.expenditure!.id, // Keep ID
                            articleName: _isIncome ? 'Income' : 'Expense',
                            amount: amount,
                            date: _selectedDate,
                            mainTagId: _selectedTagId!,
                            isIncome: _isIncome,
                            currencyCode: 'VND',
                          );
                          await viewModel.updateExpenditure(updatedExpenditure);
                        } else {
                          // Create new
                          await viewModel.addQuickExpenditure(
                            amount: amount,
                            isIncome: _isIncome,
                            mainTagId: _selectedTagId!,
                            date: _selectedDate,
                          );
                        }

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                child: viewModel.isLoading
                    ? const CircularProgressIndicator()
                    : Text(isEditing ? "UPDATE TRANSACTION" : "SAVE NOW"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
