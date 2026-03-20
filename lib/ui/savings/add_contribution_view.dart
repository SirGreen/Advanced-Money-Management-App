import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './saving_goal_view_model.dart';
import '../../domain/entities/saving_contribution.dart';

class AddContributionView extends StatefulWidget {
  final String goalId;
  final SavingContribution? contribution;

  const AddContributionView({
    super.key,
    required this.goalId,
    this.contribution,
  });

  @override
  State<AddContributionView> createState() => _AddContributionViewState();
}

class _AddContributionViewState extends State<AddContributionView> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.contribution?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(
      text: widget.contribution?.note ?? '',
    );
    _selectedDate = widget.contribution?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contribution == null ? 'Thêm tiết kiệm' : 'Sửa tiết kiệm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount
            Text(
              'Số tiền (VNĐ)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixText: '₫ ',
              ),
            ),
            const SizedBox(height: 24),

            // Date
            Text(
              'Ngày',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Note
            Text(
              'Ghi chú',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Vd: Lương tháng này, hoàn thành xong dự án...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveContribution,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.contribution == null ? 'Thêm tiết kiệm' : 'Cập nhật'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() => _selectedDate = selected);
    }
  }

  Future<void> _saveContribution() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền phải là số dương')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final viewModel = context.read<SavingGoalViewModel>();

      if (widget.contribution == null) {
        // Add new contribution
        await viewModel.addContribution(
          goalId: widget.goalId,
          amount: amount,
          date: _selectedDate,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        );
      } else {
        // Update existing contribution
        final updatedContribution = widget.contribution!;
        updatedContribution.amount = amount;
        updatedContribution.date = _selectedDate;
        updatedContribution.note =
            _noteController.text.isEmpty ? null : _noteController.text;
        await viewModel.updateContribution(updatedContribution);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.contribution == null
                ? 'Tiết kiệm được thêm'
                : 'Tiết kiệm được cập nhật'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
