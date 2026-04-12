import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './export_view_model.dart';
import '../../domain/entities/export_config.dart';

class ExportTransactionsView extends StatefulWidget {
  const ExportTransactionsView({super.key});

  @override
  State<ExportTransactionsView> createState() => _ExportTransactionsViewState();
}

class _ExportTransactionsViewState extends State<ExportTransactionsView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<ExportViewModel>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xuất dữ liệu giao dịch'),
      ),
      body: Consumer<ExportViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info about export location
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vị trí lưu tệp',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              viewModel.exportDirectoryPath,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Preset options
                _buildPresetSection(context, viewModel),
                const SizedBox(height: 24),

                // Date range filter
                _buildDateRangeSection(context, viewModel),
                const SizedBox(height: 24),

                // Transaction type filters
                _buildTransactionTypeSection(context, viewModel),
                const SizedBox(height: 24),

                // Export format
                _buildExportFormatSection(context, viewModel),
                const SizedBox(height: 24),

                // Field selection
                _buildFieldSelectionSection(context, viewModel),
                const SizedBox(height: 24),

                // Preview
                _buildPreviewSection(context, viewModel),
                const SizedBox(height: 24),

                // Export button
                _buildExportButton(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetSection(BuildContext context, ExportViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cấu hình nhanh',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetButton(
                context,
                'Tháng này',
                () => viewModel.usePresetThisMonth(),
              ),
              const SizedBox(width: 8),
              _buildPresetButton(
                context,
                'Năm này',
                () => viewModel.usePresetThisYear(),
              ),
              const SizedBox(width: 8),
              _buildPresetButton(
                context,
                'Toàn bộ',
                () => viewModel.usePresetAllTransactions(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(
    BuildContext context,
    String label,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildDateRangeSection(BuildContext context, ExportViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khoảng thời gian',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDatePicker(
                context,
                'Từ ngày',
                viewModel.config.startDate,
                (date) {
                  viewModel.setDateRange(date, viewModel.config.endDate);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDatePicker(
                context,
                'Đến ngày',
                viewModel.config.endDate,
                (date) {
                  viewModel.setDateRange(viewModel.config.startDate, date);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              onChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate)
                      : 'Chọn ngày',
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeSection(BuildContext context, ExportViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại giao dịch',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: viewModel.config.includeExpense,
          onChanged: (value) {
            viewModel.setExpenseIncluded(value ?? true);
          },
          title: const Text('Bao gồm chi tiêu'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          value: viewModel.config.includeIncome,
          onChanged: (value) {
            viewModel.setIncomeIncluded(value ?? false);
          },
          title: const Text('Bao gồm thu nhập'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildExportFormatSection(BuildContext context, ExportViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Định dạng xuất',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                value: 'csv',
                groupValue: viewModel.config.exportFormat,
                onChanged: (value) {
                  if (value != null) viewModel.setExportFormat(value);
                },
                title: const Text('CSV'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                value: 'excel',
                groupValue: viewModel.config.exportFormat,
                onChanged: (value) {
                  if (value != null) viewModel.setExportFormat(value);
                },
                title: const Text('Excel'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFieldSelectionSection(BuildContext context, ExportViewModel viewModel) {
    const availableFields = ['date', 'amount', 'category', 'article', 'notes', 'type', 'currency'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn thông tin xuất',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableFields.map((field) {
            final isSelected = viewModel.config.selectedFields.contains(field);
            return FilterChip(
              label: Text(ExportConfig().getFieldLabel(field)),
              selected: isSelected,
              onSelected: (selected) {
                final newFields = List<String>.from(viewModel.config.selectedFields);
                if (selected) {
                  newFields.add(field);
                } else {
                  newFields.remove(field);
                }
                viewModel.setFieldSelection(newFields);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(BuildContext context, ExportViewModel viewModel) {
    final summary = viewModel.summary;
    if (summary == null) return const SizedBox();

    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xem trước',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng giao dịch',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${summary['totalTransactions']}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng chi tiêu',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    currencyFormat.format(summary['totalExpense']),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng thu nhập',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    currencyFormat.format(summary['totalIncome']),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext context, ExportViewModel viewModel) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: viewModel.isExporting ? null : () => _handleExport(context, viewModel),
            child: viewModel.isExporting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Xuất dữ liệu'),
          ),
        ),
        if (viewModel.error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error, color: Colors.red[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    viewModel.error!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (viewModel.exportedFilePath != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xuất thành công!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tệp: ${viewModel.exportedFilePath!.split('/').last}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thư mục: ${viewModel.exportDirectoryPath}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleExport(BuildContext context, ExportViewModel viewModel) async {
    await viewModel.export();
    if (mounted && viewModel.exportedFilePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xuất tệp: ${viewModel.exportedFilePath!.split('/').last}'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
    }
  }
}
