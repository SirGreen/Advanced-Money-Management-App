import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './saving_goal_view_model.dart';
import '../../domain/entities/saving_goal.dart';
import './add_contribution_view.dart';

class SavingGoalDetailView extends StatefulWidget {
  final SavingGoal goal;

  const SavingGoalDetailView({super.key, required this.goal});

  @override
  State<SavingGoalDetailView> createState() => _SavingGoalDetailViewState();
}

class _SavingGoalDetailViewState extends State<SavingGoalDetailView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      context.read<SavingGoalViewModel>().loadSavingGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.name),
      ),
      body: Consumer<SavingGoalViewModel>(
        builder: (context, viewModel, child) {
          // Refresh to get latest goal data
          final goal = viewModel.getGoalById(widget.goal.id) ?? widget.goal;
          final contributions = viewModel.getContributionsForGoal(goal.id);
          final percentComplete = (goal.progress * 100).toStringAsFixed(1);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card with Progress
                Container(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến độ',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '$percentComplete%',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: goal.progress >= 1.0 ? Colors.green : Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            goal.progress >= 1.0 ? Colors.green : Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Đã tiết kiệm',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                currencyFormat.format(goal.currentAmount),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Mục tiêu',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                currencyFormat.format(goal.targetAmount),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (goal.endDate != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Hạn: ${DateFormat('dd/MM/yyyy').format(goal.endDate!)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (goal.notes != null && goal.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          goal.notes!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Contributions Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Lịch sử đóng góp',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),

                if (contributions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Chưa có đóng góp nào',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: contributions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final contribution = contributions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currencyFormat.format(contribution.amount),
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('dd/MM/yyyy').format(contribution.date),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (contribution.note != null && contribution.note!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        contribution.note!,
                                        style: Theme.of(context).textTheme.bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuButton(
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    child: const Text('Sửa'),
                                    onTap: () => _editContribution(context, contribution, viewModel),
                                  ),
                                  PopupMenuItem(
                                    child: const Text('Xóa'),
                                    onTap: () => _deleteContribution(context, contribution, viewModel),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddContributionView(goalId: widget.goal.id),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editContribution(
    BuildContext context,
    dynamic contribution,
    dynamic viewModel,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContributionView(
          goalId: widget.goal.id,
          contribution: contribution,
        ),
      ),
    );
  }

  void _deleteContribution(
    BuildContext context,
    dynamic contribution,
    dynamic viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đóng góp'),
        content: const Text('Bạn có chắc chắn muốn xóa đóng góp này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteContribution(contribution.id, widget.goal.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đóng góp đã được xóa')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
