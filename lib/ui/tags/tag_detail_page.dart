import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/tag.dart';
import '../../l10n/app_localizations.dart';
import '../transaction/expenditure_view_model.dart';
import 'add_edit_tag_page.dart';
import 'tag_view_model.dart';

class TagDetailPage extends StatelessWidget {
  final String tagId;
  const TagDetailPage({required this.tagId, super.key});

  IconData _iconForName(String? name) {
    switch (name) {
      case 'fastfood':
        return Icons.fastfood;
      case 'movie':
        return Icons.movie;
      case 'directions_car':
        return Icons.directions_car;
      default:
        return Icons.label;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TagViewModel>(
      builder: (context, tagVm, child) {
        final tag = tagVm.tags.firstWhere(
          (t) => t.id == tagId,
          orElse: () => throw Exception('Tag not found'),
        );

        return Scaffold(
          appBar: AppBar(title: Text(l10n.tags)),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(tag.colorValue),
                      child: Icon(_iconForName(tag.iconName), color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(tag.name, style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                if (tag.budgetAmount != null && tag.budgetAmount! > 0)
                  Consumer<ExpenditureViewModel>(
                    builder: (context, vm, child) {
                      final spent = vm.getSpentAmountForTagBudget(tag);
                      final budget = tag.budgetAmount!;
                      final percent = (spent / budget).clamp(0.0, 1.0);
                      Color barColor = Colors.green;
                      if (percent >= 1.0) {
                        barColor = Colors.red;
                      } else if (percent >= 0.8) {
                        barColor = Colors.orange;
                      }

                      final spentStr = NumberFormat.currency(
                        locale: 'vi',
                        symbol: 'đ',
                        decimalDigits: 0,
                      ).format(spent);
                      final budgetStr = NumberFormat.currency(
                        locale: 'vi',
                        symbol: 'đ',
                        decimalDigits: 0,
                      ).format(budget);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            'Ngân sách ${tag.budgetInterval == 'Weekly' ? 'hàng tuần' : 'hàng tháng'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: percent,
                            color: barColor,
                            backgroundColor: Colors.grey[300],
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đã tiêu: $spentStr',
                                style: TextStyle(
                                  color: barColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('Giới hạn: $budgetStr'),
                            ],
                          ),
                          if (percent >= 1.0)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'CẢNH BÁO: Đã VƯỢT ngân sách!',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (percent >= 0.8)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'CHÚ Ý: Sắp đạt giới hạn (80%+)',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 24),
                if (tag.isDefault)
                  const Text('Danh mục mặc định, không thể chỉnh sửa.')
                else
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditTagPage(tag: tag),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.edit),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
