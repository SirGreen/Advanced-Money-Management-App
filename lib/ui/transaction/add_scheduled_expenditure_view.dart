import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'scheduled_expenditure_view_model.dart';
import '../transaction/expenditure_view_model.dart'; // For tags
import '../../domain/entities/scheduled_expenditure.dart';
import '../../domain/services/recurring_transaction_service.dart'; // Import this
import '../helpers/currency_input_formatter.dart';

class AddScheduledExpenditureView extends StatefulWidget {
  final ScheduledExpenditure? scheduledExpenditure;
  const AddScheduledExpenditureView({super.key, this.scheduledExpenditure});

  @override
  State<AddScheduledExpenditureView> createState() =>
      _AddScheduledExpenditureViewState();
}

class _AddScheduledExpenditureViewState
    extends State<AddScheduledExpenditureView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _scheduleValueController = TextEditingController(text: '1');

  bool _isIncome = false;
  String? _selectedTagId;
  ScheduleType _scheduleType = ScheduleType.dayOfMonth;
  DateTime _startDate = DateTime.now();
  int? _reminderDaysBefore;

  bool get isEditing => widget.scheduledExpenditure != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final e = widget.scheduledExpenditure!;
      _nameController.text = e.name;
      _amountController.text = NumberFormat.decimalPattern(
        'vi_VN',
      ).format(e.amount);
      _isIncome = e.isIncome;
      _selectedTagId = e.mainTagId;
      _startDate = e.startDate;
      _scheduleType = e.scheduleType;
      _scheduleValueController.text = e.scheduleValue.toString();
      _reminderDaysBefore = e.reminderDaysBefore;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expViewModel = Provider.of<ExpenditureViewModel>(
      context,
    ); // To get tags
    final tags = expViewModel.tags;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Recurring" : "New Recurring"),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Recurring Rule?"),
                    content: const Text(
                      "This will stop future auto-creation.\nPast transactions created by this rule remain.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CANCEL"),
                      ),
                      TextButton(
                        onPressed: () async {
                          // 1. Close Dialog
                          Navigator.pop(context);

                          // 2. Cancel Notification
                          final recurringService =
                              Provider.of<RecurringTransactionService>(
                                context,
                                listen: false,
                              );
                          await recurringService.cancelReminderFor(
                            widget.scheduledExpenditure!,
                          );

                          if (!context.mounted) return;

                          // 3. Delete from DB
                          final viewModel =
                              Provider.of<ScheduledExpenditureViewModel>(
                                context,
                                listen: false,
                              );
                          await viewModel.deleteScheduledExpenditure(
                            widget.scheduledExpenditure!.id,
                          );

                          // 4. Close View
                          if (context.mounted) {
                            Navigator.pop(context);
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Amount",
                prefixText: "₫ ",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [DecimalCurrencyInputFormatter(locale: 'vi_VN')],
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),

            // Tag
            DropdownButtonFormField<String>(
              // value: _selectedTagId, // Remove deprecated
              initialValue:
                  _selectedTagId, // Wait, value IS correct for state-controlled.
              // Actually, the warning says: 'value' is deprecated and shouldn't be used. Use initialValue instead.
              // IF it's a FormField that maintains its own state.
              // But here we are using setState to update _selectedTagId.
              // So 'value' IS correct for a controlled input.
              // However, the lint says otherwise. Let's try to trust the lint OR
              // check if we can switch to standard DropdownButton if we manage state manually.
              // But wait, DropdownButtonFormField is useful for validation.

              // Let's re-read the lint: "'value' is deprecated... This feature was deprecated after v3.33.0-1.0.pre."
              // In newer Flutter, DropdownButtonFormField STILL has 'value'.
              // This might be a very new deprecation or a specific package issue.
              // Let's safe fix: If the user says it's deprecated, let's look at the docs or assume it wants us to use `initialValue` and NOT update it via `value` prop continuously?
              // But if we use `initialValue`, `setState` won't update the widget if the variable changes externally?
              // Actually, standard pattern is `value`.
              // Maybe the issue is we are mixing FormField features?

              // Let's look at the code again.
              // value: _selectedTagId
              // onChanged: (v) => setState(...)

              // If I change to initialValue: _selectedTagId, it won't react to changes?
              // Let's assume the lint is strict. I will try to ignore it or if I MUST fix it.

              // Actually, I'll fix the Compilation Error first. The lint is "Info" severity.
              // I will IGNORE the lint for now to prioritize the compilation error.
              // The user specifically pointed it out though.

              // Let's try to just fix the logic error first.
              decoration: const InputDecoration(
                labelText: "Category",
                border: OutlineInputBorder(),
              ),
              items: tags
                  .map(
                    (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedTagId = v),
              validator: (v) => v == null ? "Required" : null,
            ),
            const SizedBox(height: 16),

            // Schedule Type
            DropdownButtonFormField<ScheduleType>(
              initialValue: _scheduleType,
              decoration: const InputDecoration(
                labelText: "Frequency",
                border: OutlineInputBorder(),
              ),
              items: ScheduleType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.toString().split('.').last),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _scheduleType = v!),
            ),
            const SizedBox(height: 16),

            // Schedule Value (Day of Month or Interval)
            TextFormField(
              controller: _scheduleValueController,
              decoration: const InputDecoration(
                labelText: "Day / Interval Value",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),

            // Start Date
            ListTile(
              title: const Text("Start Date"),
              subtitle: Text(DateFormat.yMMMd().format(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
            ),

            // Reminder
            DropdownButtonFormField<int?>(
              initialValue: _reminderDaysBefore,
              decoration: const InputDecoration(
                labelText: "Remind me before",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notifications),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text("No reminder")),
                const DropdownMenuItem(value: 0, child: Text("On the day")),
                const DropdownMenuItem(value: 1, child: Text("1 day before")),
                const DropdownMenuItem(value: 3, child: Text("3 days before")),
                const DropdownMenuItem(value: 7, child: Text("1 week before")),
              ],
              onChanged: (v) => setState(() => _reminderDaysBefore = v),
            ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _save(context);
                }
              },
              child: const Text("SAVE RECURRING TRANSACTION"),
            ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) async {
    final viewModel = Provider.of<ScheduledExpenditureViewModel>(
      context,
      listen: false,
    );
    final rawAmount = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '');
    final amount = double.parse(rawAmount);

    final item = ScheduledExpenditure(
      id: isEditing ? widget.scheduledExpenditure!.id : const Uuid().v4(),
      name: _nameController.text,
      amount: amount,
      mainTagId: _selectedTagId!,
      subTagIds: [],
      scheduleType: _scheduleType,
      scheduleValue: int.parse(_scheduleValueController.text),
      startDate: _startDate,
      isActive: true,
      isIncome: _isIncome,
      currencyCode: 'VND',
      reminderDaysBefore: _reminderDaysBefore,
    );

    if (isEditing) {
      await viewModel.updateScheduledExpenditure(item);
    } else {
      await viewModel.addScheduledExpenditure(item);
    }

    // Trigger check for new transactions immediately
    if (context.mounted) {
      final recurringService = Provider.of<RecurringTransactionService>(
        context,
        listen: false,
      );
      final count = await recurringService.checkAndCreateTransactions();

      if (count > 0 && context.mounted) {
        // Refresh Dashboard
        Provider.of<ExpenditureViewModel>(
          context,
          listen: false,
        ).loadExpenditures();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Created $count new transaction(s).")),
        );
      }

      // Schedule Notification
      await recurringService.scheduleReminderFor(item);
      if (item.reminderDaysBefore != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reminder scheduled successfully!")),
          );
        }
      }
    }

    if (context.mounted) Navigator.pop(context);
  }
}
