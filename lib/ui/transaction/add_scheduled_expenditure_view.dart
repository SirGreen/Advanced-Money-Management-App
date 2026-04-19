import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'scheduled_expenditure_view_model.dart';
import '../transaction/expenditure_view_model.dart'; // For tags
import '../../domain/entities/scheduled_expenditure.dart';
import '../../domain/services/recurring_transaction_service.dart'; // Import this
import '../helpers/currency_input_formatter.dart';
import '../helpers/tag_icon_mapper.dart';

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
  Set<String> _selectedTagIds = {};
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
      _selectedTagIds = {e.mainTagId, ...e.subTagIds};
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Categories (Select One or More)",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    final isSelected = _selectedTagIds.contains(tag.id);
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getIconForTag(tag.iconName ?? 'other'),
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : Color(tag.colorValue),
                          ),
                          const SizedBox(width: 6),
                          Text(tag.name),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTagIds.add(tag.id);
                          } else {
                            _selectedTagIds.remove(tag.id);
                          }
                        });
                      },
                      backgroundColor: Color(tag.colorValue).withAlpha(30),
                      selectedColor: Color(tag.colorValue),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
                if (_selectedTagIds.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Please select at least one category",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
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
    FocusScope.of(context).unfocus();
    if (_selectedTagIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one category")),
      );
      return;
    }

    final viewModel = Provider.of<ScheduledExpenditureViewModel>(
      context,
      listen: false,
    );
    
    final amount = DecimalCurrencyInputFormatter.parse(
      _amountController.text,
      currencyCode: 'VND', // Hardcoded to VND in this view's original logic
    );

    final mainTagId = _selectedTagIds.first;
    final subTagIds =
        _selectedTagIds.where((id) => id != mainTagId).toList();

    final item = ScheduledExpenditure(
      id: isEditing ? widget.scheduledExpenditure!.id : const Uuid().v4(),
      name: _nameController.text,
      amount: amount,
      mainTagId: mainTagId,
      subTagIds: subTagIds,
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
