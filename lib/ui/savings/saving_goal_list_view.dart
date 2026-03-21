import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import './saving_goal_view_model.dart';
import '../../domain/entities/saving_goal.dart';
import './saving_goal_detail_view.dart';
import './add_saving_goal_view.dart';
import '../transaction/expenditure_view_model.dart';
import '../tags/tag_detail_page.dart';
import '../tags/tag_view_model.dart';

class SavingGoalListView extends StatefulWidget {
  const SavingGoalListView({super.key});

  @override
  State<SavingGoalListView> createState() => _SavingGoalListViewState();
}

class _SavingGoalListViewState extends State<SavingGoalListView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<SavingGoalViewModel>().loadSavingGoals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.wallet), text: 'Ngân sách'),
              Tab(icon: Icon(Icons.savings), text: 'Mục tiêu'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBudgetTab(context),
                _buildSavingGoalsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab(BuildContext context) {
    return Consumer<ExpenditureViewModel>(
      builder: (context, viewModel, child) {
        final budgetTags = viewModel.tags
            .where((t) => t.budgetAmount != null && t.budgetAmount! > 0)
            .toList();

        if (budgetTags.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa thiết lập ngân sách',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vào cài đặt Danh mục để đặt giới hạn',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.loadExpenditures(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgetTags.length,
            itemBuilder: (context, index) {
              final tag = budgetTags[index];
              final spent = viewModel.getSpentAmountForTagBudget(tag);
              final limit = tag.budgetAmount!;
              final percent = (spent / limit).clamp(0.0, 1.0);

              Color barColor = Colors.green;
              if (percent >= 1.0) {
                barColor = Colors.red;
              } else if (percent >= 0.8) {
                barColor = Colors.orange;
              }

              final format = NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TagDetailPage(tag: tag),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.label,
                              size: 24,
                              color: Color(tag.colorValue),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tag.name,
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (percent >= 1.0)
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Xóa ngân sách'),
                                    content: Text(
                                      'Bạn có chắc chắn muốn xóa ngân sách của "${tag.name}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          tag.budgetAmount = null;
                                          tag.budgetInterval = 'None';
                                          await context
                                              .read<TagViewModel>()
                                              .edit(tag);
                                          if (!context.mounted) return;
                                          await context
                                              .read<ExpenditureViewModel>()
                                              .loadExpenditures();
                                          if (ctx.mounted) {
                                            Navigator.pop(ctx);
                                          }
                                        },
                                        child: const Text(
                                          'Xóa',
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
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 12,
                            color: barColor,
                            backgroundColor: barColor.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đã chi:\n${format.format(spent)}',
                              style: TextStyle(
                                color: barColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(percent * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: barColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Giới hạn:\n${format.format(limit)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSavingGoalsTab(BuildContext context) {
    return Consumer<SavingGoalViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.savingGoals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.savings, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có mục tiêu tiết kiệm',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn nút + để tạo mục tiêu đầu tiên của bạn',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.loadSavingGoals(),
          child: ListView.builder(
            itemCount: viewModel.savingGoals.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final goal = viewModel.savingGoals[index];
              return _buildGoalCard(context, goal, viewModel);
            },
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    SavingGoal goal,
    SavingGoalViewModel viewModel,
  ) {
    final percentComplete = (goal.progress * 100).toStringAsFixed(1);
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavingGoalDetailView(goal: goal),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (goal.notes != null && goal.notes!.isNotEmpty)
                          Text(
                            goal.notes!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Chỉnh sửa'),
                        onTap: () => _showEditDialog(context, goal, viewModel),
                      ),
                      PopupMenuItem(
                        child: const Text('Xóa'),
                        onTap: () =>
                            _showDeleteConfirm(context, goal, viewModel),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiến độ',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: goal.progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              goal.progress >= 1.0
                                  ? Colors.green
                                  : Colors.deepPurple,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$percentComplete% - ${currencyFormat.format(goal.currentAmount)} / ${currencyFormat.format(goal.targetAmount)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (goal.endDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Hạn: ${DateFormat('dd/MM/yyyy').format(goal.endDate!)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    SavingGoal goal,
    SavingGoalViewModel viewModel,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSavingGoalView(goal: goal)),
    );
  }

  void _showDeleteConfirm(
    BuildContext context,
    SavingGoal goal,
    SavingGoalViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mục tiêu'),
        content: Text(
          'Bạn có chắc chắn muốn xóa "${goal.name}"? Tất cả tiền đóng góp sẽ bị xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteSavingGoal(goal.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
