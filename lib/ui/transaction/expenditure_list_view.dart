import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'expenditure_view_model.dart';
import 'add_transaction_view.dart';
import '../../domain/entities/tag.dart';
import '../settings/settings_view_model.dart';
import '../../data/services/privacy_mode_service.dart';
import '../helpers/tag_icon_mapper.dart';

class ExpenditureListView extends StatelessWidget {
  const ExpenditureListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenditureViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return viewModel.expenditures.isEmpty
            ? const Center(
                child: Text("No transactions yet. Tap + to add one!"),
              )
            : ListView.builder(
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
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Transaction?"),
                          content: const Text("This action cannot be undone."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(ctx); // Close dialog
                                await viewModel.deleteExpenditure(
                                  expenditure.id,
                                );
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
                        getIconForTag(tag.iconName ?? 'other'),
                        color: Color(tag.colorValue),
                      ),
                    ),
                    title: Text(tag.name),
                    subtitle: Text(
                      DateFormat.yMMMd('vi_VN').format(expenditure.date),
                    ),
                    trailing: Consumer<SettingsViewModel>(
                      builder: (context, settingsViewModel, _) {
                        final formattedAmount =
                            '${expenditure.isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(expenditure.amount ?? 0)}';
                        final displayAmount =
                            settingsViewModel.settings.privacyModeEnabled
                                ? PrivacyModeService.maskSymbol
                                : formattedAmount;

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayAmount,
                              style: TextStyle(
                                color: expenditure.isIncome
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (settingsViewModel
                                .settings
                                .privacyModeEnabled) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.lock,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  );
                },
              );
      },
    );
  }
}
