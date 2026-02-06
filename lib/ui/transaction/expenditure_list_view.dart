import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'expenditure_view_model.dart';
import 'add_transaction_view.dart'; // Import AddTransactionView
import '../../domain/entities/tag.dart';

class ExpenditureListView extends StatelessWidget {
  const ExpenditureListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenditureViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.expenditures.isEmpty) {
          return const Center(
            child: Text("No transactions yet. Tap + to add one!"),
          );
        }

        return ListView.builder(
          itemCount: viewModel.expenditures.length,
          itemBuilder: (context, index) {
            final expenditure = viewModel.expenditures[index];
            final tag = viewModel.tags.firstWhere(
              (t) => t.id == expenditure.mainTagId,
              orElse: () => Tag(
                id: 'unknown',
                name: 'Unknown',
                colorValue: Colors.grey.toARGB32(),
              ),
            );

            return ListTile(
              // Tap to Edit
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AddTransactionView(expenditure: expenditure),
                  ),
                );
              },
              // Long Press to Delete
              onLongPress: () {
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
                          await viewModel.deleteExpenditure(expenditure.id);
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
              leading: CircleAvatar(
                backgroundColor: Color(tag.colorValue).withValues(alpha: 0.2),
                child: Icon(
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
              ),
              title: Text(tag.name),
              subtitle: Text(
                DateFormat.yMMMd('vi_VN').format(expenditure.date),
              ),
              trailing: Text(
                '${expenditure.isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(expenditure.amount ?? 0)}',
                style: TextStyle(
                  color: expenditure.isIncome ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
