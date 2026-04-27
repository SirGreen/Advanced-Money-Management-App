import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './export_view_model.dart';
import '../../domain/entities/export_config.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/section_header.dart';

class ExportTransactionsView extends StatefulWidget {
  const ExportTransactionsView({super.key});

  @override
  State<ExportTransactionsView> createState() => _ExportTransactionsViewState();
}

class _ExportTransactionsViewState extends State<ExportTransactionsView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ExportViewModel>(
      builder: (context, viewModel, child) {
        final topPadding =
            MediaQuery.of(context).padding.top + kToolbarHeight + 8;
        final bottomPadding =
            MediaQuery.of(context).padding.bottom + 90;

        return BackGround(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: _buildAppBar(),
            body: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(12, topPadding, 12, bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationCard(viewModel),
                  const SizedBox(height: 12),
                  _buildPresetSection(context, viewModel),
                  const SizedBox(height: 12),
                  _buildDateRangeSection(context, viewModel),
                  const SizedBox(height: 12),
                  _buildTransactionTypeSection(viewModel),
                  const SizedBox(height: 12),
                  _buildExportFormatSection(viewModel),
                  const SizedBox(height: 12),
                  _buildFieldSelectionSection(viewModel),
                  const SizedBox(height: 12),
                  _buildPreviewSection(context, viewModel),
                  const SizedBox(height: 16),
                  _buildExportButton(context, viewModel),
                  if (viewModel.error != null) ...[
                    const SizedBox(height: 12),
                    _buildErrorCard(viewModel),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: GradientTitle(text: 'Xuất dữ liệu'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
    );
  }

  Widget _buildLocationCard(ExportViewModel viewModel) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      color: Colors.blue.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(Icons.folder_outlined, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vị trí lưu tệp',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.exportDirectoryPath,
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetSection(BuildContext context, ExportViewModel viewModel) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Cấu hình nhanh'),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildPresetChip('Tháng này', viewModel.usePresetThisMonth),
              const SizedBox(width: 8),
              _buildPresetChip('Năm này', viewModel.usePresetThisYear),
              const SizedBox(width: 8),
              _buildPresetChip('Toàn bộ', viewModel.usePresetAllTransactions),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onPressed) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.teal.shade400),
          foregroundColor: Colors.teal.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }

  Widget _buildDateRangeSection(BuildContext context, ExportViewModel viewModel) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Khoảng thời gian'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildDatePicker(
                  context,
                  'Từ ngày',
                  viewModel.config.startDate,
                  (date) => viewModel.setDateRange(date, viewModel.config.endDate),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDatePicker(
                  context,
                  'Đến ngày',
                  viewModel.config.endDate,
                  (date) => viewModel.setDateRange(viewModel.config.startDate, date),
                ),
              ),
            ],
          ),
        ],
      ),
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
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate)
                      : 'Chọn ngày',
                  style: const TextStyle(fontSize: 13),
                ),
                Icon(Icons.calendar_today, size: 16, color: Colors.teal.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeSection(ExportViewModel viewModel) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Loại giao dịch'),
          CheckboxListTile(
            value: viewModel.config.includeExpense,
            onChanged: (v) => viewModel.setExpenseIncluded(v ?? true),
            title: const Text('Bao gồm chi tiêu'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.teal.shade600,
          ),
          CheckboxListTile(
            value: viewModel.config.includeIncome,
            onChanged: (v) => viewModel.setIncomeIncluded(v ?? false),
            title: const Text('Bao gồm thu nhập'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: Colors.teal.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildExportFormatSection(ExportViewModel viewModel) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Định dạng xuất'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  value: 'csv',
                  groupValue: viewModel.config.exportFormat,
                  onChanged: (v) { if (v != null) viewModel.setExportFormat(v); },
                  title: const Text('CSV'),
                  activeColor: Colors.teal.shade600,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  value: 'excel',
                  groupValue: viewModel.config.exportFormat,
                  onChanged: (v) { if (v != null) viewModel.setExportFormat(v); },
                  title: const Text('Excel'),
                  activeColor: Colors.teal.shade600,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSelectionSection(ExportViewModel viewModel) {
    const availableFields = [
      'date', 'amount', 'category', 'article', 'notes', 'type', 'currency',
    ];

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Chọn thông tin xuất'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableFields.map((field) {
              final isSelected = viewModel.config.selectedFields.contains(field);
              return FilterChip(
                label: Text(ExportConfig().getFieldLabel(field)),
                selected: isSelected,
                selectedColor: Colors.teal.withValues(alpha: 0.25),
                checkmarkColor: Colors.teal.shade800,
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
      ),
    );
  }

  Widget _buildPreviewSection(BuildContext context, ExportViewModel viewModel) {
    final summary = viewModel.summary;
    if (summary == null) return const SizedBox.shrink();
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Xem trước'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                context,
                label: 'Tổng GD',
                value: '${summary['totalTransactions']}',
                color: Colors.teal.shade700,
              ),
              _buildSummaryItem(
                context,
                label: 'Tổng chi',
                value: currencyFormat.format(summary['totalExpense'] ?? 0),
                color: Colors.red.shade700,
              ),
              _buildSummaryItem(
                context,
                label: 'Tổng thu',
                value: currencyFormat.format(summary['totalIncome'] ?? 0),
                color: Colors.green.shade700,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildExportButton(BuildContext context, ExportViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: viewModel.isExporting ? null : () => _handleExport(context, viewModel),
        icon: viewModel.isExporting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.download_rounded),
        label: Text(
          viewModel.isExporting ? 'Đang xuất...' : 'Xuất dữ liệu',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildErrorCard(ExportViewModel viewModel) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      color: Colors.red.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              viewModel.error!,
              style: TextStyle(color: Colors.red.shade800, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(BuildContext context, ExportViewModel viewModel) async {
    await viewModel.export();
    if (!mounted) return;
    if (viewModel.exportedFilePath != null) {
      _showSuccessDialog(context, viewModel);
    }
  }

  void _showSuccessDialog(BuildContext context, ExportViewModel viewModel) {
    final fileName = viewModel.exportedFilePath!.split('/').last;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.green.withValues(alpha: 0.15),
          child: Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 36),
        ),
        title: const Text(
          'Xuất thành công!',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            _dialogRow(
              icon: Icons.insert_drive_file_outlined,
              label: 'Tệp',
              value: fileName,
            ),
            const SizedBox(height: 8),
            _dialogRow(
              icon: Icons.folder_outlined,
              label: 'Thư mục',
              value: viewModel.exportDirectoryPath,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              viewModel.clearExportedFile();
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _dialogRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.teal.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}
