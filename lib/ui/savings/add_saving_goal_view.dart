import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './saving_goal_view_model.dart';
import '../../domain/entities/saving_goal.dart';

class AddSavingGoalView extends StatefulWidget {
  final SavingGoal? goal;

  const AddSavingGoalView({super.key, this.goal});

  @override
  State<AddSavingGoalView> createState() => _AddSavingGoalViewState();
}

class _AddSavingGoalViewState extends State<AddSavingGoalView> {
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _notesController;
  DateTime? _selectedEndDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetAmountController = TextEditingController(
      text: widget.goal?.targetAmount.toString() ?? '',
    );
    _notesController = TextEditingController(text: widget.goal?.notes ?? '');
    _selectedEndDate = widget.goal?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Tạo mục tiêu mới' : 'Chỉnh sửa mục tiêu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Name
            Text(
              'Tên mục tiêu',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Vd: Tiết kiệm cho kỳ nghỉ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Target Amount
            Text(
              'Mục tiêu tiết kiệm (VNĐ)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _targetAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // End Date
            Text(
              'Hạn hoàn thành (tùy chọn)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectEndDate,
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
                      _selectedEndDate != null
                          ? DateFormat('dd/MM/yyyy').format(_selectedEndDate!)
                          : 'Chọn ngày',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            Text(
              'Ghi chú',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Thêm ghi chú cho mục tiêu này...',
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
                onPressed: _isLoading ? null : _saveSavingGoal,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.goal == null ? 'Tạo mục tiêu' : 'Cập nhật mục tiêu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (selected != null) {
      setState(() => _selectedEndDate = selected);
    }
  }

  Future<void> _saveSavingGoal() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên mục tiêu')),
      );
      return;
    }

    if (_targetAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mục tiêu tiết kiệm')),
      );
      return;
    }

    final targetAmount = double.tryParse(_targetAmountController.text);
    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mục tiêu tiết kiệm phải là số dương')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final viewModel = context.read<SavingGoalViewModel>();

      if (widget.goal == null) {
        // Create new goal
        await viewModel.createSavingGoal(
          name: _nameController.text,
          targetAmount: targetAmount,
          endDate: _selectedEndDate,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      } else {
        // Update existing goal
        final updatedGoal = widget.goal!;
        updatedGoal.name = _nameController.text;
        updatedGoal.targetAmount = targetAmount;
        updatedGoal.endDate = _selectedEndDate;
        updatedGoal.notes = _notesController.text.isEmpty ? null : _notesController.text;
        await viewModel.updateSavingGoal(updatedGoal);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.goal == null ? 'Mục tiêu được tạo' : 'Mục tiêu được cập nhật'),
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
