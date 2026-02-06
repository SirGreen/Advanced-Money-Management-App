import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'scheduled_expenditure_view_model.dart';
import 'expenditure_view_model.dart'; // Import this
import 'add_scheduled_expenditure_view.dart';
// import '../../domain/entities/tag.dart'; // Unused
import '../../domain/entities/scheduled_expenditure.dart';

class ScheduledExpenditureListView extends StatelessWidget {
  const ScheduledExpenditureListView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recurring Transactions"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Rules"),
              Tab(text: "History"),
            ],
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.add),
          //     onPressed: () { ... }
          //   ),
          // ],
        ),
        body: TabBarView(
          children: [
            // Tab 1: Rules
            Consumer<ScheduledExpenditureViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.scheduledExpenditures.isEmpty) {
                  return const Center(
                    child: Text("No recurring transactions set up."),
                  );
                }

                return ListView.builder(
                  itemCount: viewModel.scheduledExpenditures.length,
                  itemBuilder: (context, index) {
                    final item = viewModel.scheduledExpenditures[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(_getScheduleDescription(item)),
                      trailing: Switch(
                        value: item.isActive,
                        onChanged: (val) {
                          item.isActive = val;
                          viewModel.updateScheduledExpenditure(item);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddScheduledExpenditureView(
                              scheduledExpenditure: item,
                            ),
                          ),
                        );
                      },
                      onLongPress: () {
                        viewModel.deleteScheduledExpenditure(item.id);
                      },
                    );
                  },
                );
              },
            ),

            // Tab 2: History (Generated Instances)
            Consumer<ExpenditureViewModel>(
              builder: (context, viewModel, child) {
                final history = viewModel.recurringInstances;
                if (history.isEmpty) {
                  return const Center(
                    child: Text("No generated transactions yet."),
                  );
                }

                return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(item.articleName),
                      subtitle: Text(DateFormat.yMMMd().format(item.date)),
                      trailing: Text(
                        NumberFormat.currency(
                          symbol: '₫',
                          decimalDigits: 0,
                        ).format(item.amount),
                        style: TextStyle(
                          color: item.isIncome ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getScheduleDescription(ScheduledExpenditure item) {
    String freq = '';
    switch (item.scheduleType) {
      case ScheduleType.dayOfMonth:
        freq = 'Every month on day ${item.scheduleValue}';
        break;
      case ScheduleType.endOfMonth:
        freq = 'End of every month';
        break;
      case ScheduleType.daysBeforeEndOfMonth:
        freq = '${item.scheduleValue} days before end of month';
        break;
      case ScheduleType.fixedInterval:
        freq = 'Every ${item.scheduleValue} days';
        break;
    }
    return '${NumberFormat.currency(symbol: '₫', decimalDigits: 0).format(item.amount)} - $freq';
  }
}
