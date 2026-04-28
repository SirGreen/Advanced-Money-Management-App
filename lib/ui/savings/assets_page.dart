
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/saving_account.dart';
import '../../domain/entities/saving_goal.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/entities/tag.dart';
import '../../l10n/app_localizations.dart';
import '../../data/services/privacy_mode_service.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/shared_axis_page_route.dart';
import '../helpers/tag_icon.dart';
import '../tags/tag_view_model.dart';
import '../settings/settings_view_model.dart';
import '../transaction/expenditure_view_model.dart';
import 'add_edit_budget_page.dart';
import 'add_edit_saving_account_view.dart';
import 'add_edit_saving_goal_page.dart';
import 'saving_account_view_model.dart';
import 'saving_goal_view_model.dart';

enum BudgetSortOption { overbudget, percent, amount, name }

class AssetsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final VoidCallback onRefresh;
  final TabBar? tabBar;
  final bool showSortButton;
  final VoidCallback? onSortPressed;

  const AssetsAppBar({
    super.key,
    required this.l10n,
    required this.onRefresh,
    this.tabBar,
    this.showSortButton = false,
    this.onSortPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GradientTitle(text: l10n.assets),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
      ),
      actions: [
        if (showSortButton)
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: onSortPressed,
            tooltip: l10n.sortBy,
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: l10n.refresh,
        ),
      ],
      bottom: tabBar,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (tabBar?.preferredSize.height ?? 0));
}

class AssetsPage extends StatefulWidget {
  final TabController tabController;

  const AssetsPage({super.key, required this.tabController});

  Widget buildFab(BuildContext context, int tabIndex) {
    final l10n = AppLocalizations.of(context)!;
    Widget page;
    String tooltip;

    switch (tabIndex) {
      case 0:
        page = const AddEditBudgetPage();
        tooltip = l10n.addBudget;
        break;
      case 1:
        page = const AddEditSavingAccountView();
        tooltip = l10n.addSavingAccount;
        break;
      case 2:
      default:
        page = const AddEditSavingGoalPage();
        tooltip = l10n.addSavingGoal;
        break;
    }

    return FloatingActionButton(
      backgroundColor: Colors.teal.shade600,
      foregroundColor: Colors.white,
      onPressed: () => Navigator.of(context).push(
        SharedAxisPageRoute(
          page: page,
          transitionType: SharedAxisTransitionType.scaled,
        ),
      ),
      tooltip: tooltip,
      child: const Icon(Icons.add),
    );
  }

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  BudgetSortOption _sortOption = BudgetSortOption.overbudget;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<SavingGoalViewModel>().loadSavingGoals();
      context.read<SavingAccountViewModel>().loadSavingAccounts();
    });
  }

  void _showSortOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.warning_amber_rounded),
              title: Text(l10n.sortByOverbudget),
              onTap: () {
                setState(() => _sortOption = BudgetSortOption.overbudget);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.percent),
              title: Text(l10n.sortByPercent),
              onTap: () {
                setState(() => _sortOption = BudgetSortOption.percent);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.paid_outlined),
              title: Text(l10n.sortByAmount),
              onTap: () {
                setState(() => _sortOption = BudgetSortOption.amount);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: Text(l10n.sortByName),
              onTap: () {
                setState(() => _sortOption = BudgetSortOption.name);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabBar = TabBar(
      controller: widget.tabController,
      tabs: [
        Tab(icon: const Icon(Icons.wallet_outlined), text: l10n.budgets),
        Tab(icon: const Icon(Icons.savings_outlined), text: l10n.accounts),
        Tab(icon: const Icon(Icons.flag_outlined), text: l10n.goals),
      ],
      indicatorColor: Theme.of(context).colorScheme.primary,
      labelColor: Theme.of(context).colorScheme.primary,
      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final appBar = AssetsAppBar(
      l10n: l10n,
      onRefresh: () async {
        switch (widget.tabController.index) {
          case 0:
            await context.read<ExpenditureViewModel>().loadExpenditures();
            break;
          case 1:
            await context.read<SavingAccountViewModel>().loadSavingAccounts();
            break;
          case 2:
            await context.read<SavingGoalViewModel>().loadSavingGoals();
            break;
        }
      },
      tabBar: tabBar,
      showSortButton: widget.tabController.index == 0,
      onSortPressed: _showSortOptions,
    );

    final appBarHeight = appBar.preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalTopOffset = appBarHeight + statusBarHeight;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: TabBarView(
          controller: widget.tabController,
          children: [
            _buildBudgetsList(context, totalTopOffset),
            _buildSavingAccountsList(context, totalTopOffset),
            _buildSavingGoalsList(context, totalTopOffset),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetsList(BuildContext context, double topPadding) {
    final l10n = AppLocalizations.of(context)!;
    final vm = context.watch<ExpenditureViewModel>();
    final isPrivacyMode = context.watch<SettingsViewModel>().settings.privacyModeEnabled;

    final statuses = vm.tags
        .where((t) => t.budgetAmount != null && t.budgetAmount! > 0)
        .map((tag) {
          final period = _getCurrentBudgetPeriod(tag.budgetInterval);
          final filter = vm.getFilteredExpenditures(
            SearchFilter(
              tags: [tag],
              startDate: period.start,
              endDate: period.end,
              transactionType: TransactionTypeFilter.expense,
            ),
          );
          final spent = filter.fold<double>(0, (sum, e) => sum + (e.amount ?? 0));
          final budget = tag.budgetAmount ?? 0;
          final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.5) : 0.0;
          return _BudgetStatus(
            spent: spent,
            budget: budget,
            progress: progress,
            isOverBudget: spent > budget,
            resetDate: period.end,
            transactionCount: filter.length,
          ).withTag(tag);
        })
        .toList();

    statuses.sort((a, b) {
      if (a.isOverBudget && !b.isOverBudget) return -1;
      if (!a.isOverBudget && b.isOverBudget) return 1;
      switch (_sortOption) {
        case BudgetSortOption.percent:
          return b.progress.compareTo(a.progress);
        case BudgetSortOption.amount:
          return b.spent.compareTo(a.spent);
        case BudgetSortOption.name:
          return a.tag.name.toLowerCase().compareTo(b.tag.name.toLowerCase());
        case BudgetSortOption.overbudget:
          final overA = a.spent - a.budget;
          final overB = b.spent - b.budget;
          return overB.compareTo(overA);
      }
    });

    return RefreshIndicator(
      onRefresh: () => context.read<ExpenditureViewModel>().loadExpenditures(),
      edgeOffset: topPadding,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(8, topPadding + 8, 8, 120),
            sliver: statuses.isEmpty
                ? SliverToBoxAdapter(
                    child: _EmptyStateMessage(message: l10n.noBudgetsSet),
                  )
                : SliverList.builder(
                    itemCount: statuses.length,
                    itemBuilder: (context, index) => _BudgetCard(
                      tag: statuses[index].tag,
                      status: statuses[index],
                      isPrivacyMode: isPrivacyMode,
                      onDelete: () => _deleteBudget(context, statuses[index].tag),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingAccountsList(BuildContext context, double topPadding) {
    final l10n = AppLocalizations.of(context)!;
    final isPrivacyMode = context.watch<SettingsViewModel>().settings.privacyModeEnabled;
    return Consumer<SavingAccountViewModel>(
      builder: (context, vm, child) {
        return RefreshIndicator(
          onRefresh: () => vm.loadSavingAccounts(),
          edgeOffset: topPadding,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 120),
                sliver: vm.savingAccounts.isEmpty
                    ? SliverToBoxAdapter(
                        child: _EmptyStateMessage(message: l10n.noSavingAccounts),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _SavingAccountCard(
                            account: vm.savingAccounts[index],
                            isPrivacyMode: isPrivacyMode,
                          );
                        }, childCount: vm.savingAccounts.length),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavingGoalsList(BuildContext context, double topPadding) {
    final l10n = AppLocalizations.of(context)!;
    final isPrivacyMode = context.watch<SettingsViewModel>().settings.privacyModeEnabled;
    return Consumer<SavingGoalViewModel>(
      builder: (context, vm, child) {
        return RefreshIndicator(
          onRefresh: () => vm.loadSavingGoals(),
          edgeOffset: topPadding,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, topPadding + 16, 16, 120),
                sliver: vm.savingGoals.isEmpty
                    ? SliverToBoxAdapter(
                        child: _EmptyStateMessage(message: l10n.noSavingGoals),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _SavingGoalCard(
                            goal: vm.savingGoals[index],
                            isPrivacyMode: isPrivacyMode,
                          );
                        }, childCount: vm.savingGoals.length),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteBudget(BuildContext context, Tag tag) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteBudget),
        content: Text(l10n.confirmDeleteBudget(tag.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final tagVm = context.read<TagViewModel>();
              final expenditureVm = context.read<ExpenditureViewModel>();
              tag.budgetAmount = null;
              tag.budgetInterval = 'None';
              await tagVm.edit(tag);
              if (!mounted) return;
              await expenditureVm.loadExpenditures();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  DateTimeRange _getCurrentBudgetPeriod(String interval) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate;

    switch (interval) {
      case 'Weekly':
        final daysToSubtract = now.weekday - 1;
        startDate = DateTime(now.year, now.month, now.day - daysToSubtract);
        endDate = startDate.add(const Duration(days: 6));
        break;
      case 'Yearly':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
      case 'Monthly':
      default:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
    }

    return DateTimeRange(
      start: DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0),
      end: DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59),
    );
  }
}

class _BudgetStatus {
  final double spent;
  final double budget;
  final double progress;
  final bool isOverBudget;
  final DateTime resetDate;
  final int transactionCount;
  late Tag tag;

  _BudgetStatus({
    required this.spent,
    required this.budget,
    required this.progress,
    required this.isOverBudget,
    required this.resetDate,
    required this.transactionCount,
  });

  _BudgetStatus withTag(Tag value) {
    tag = value;
    return this;
  }
}

class _EmptyStateMessage extends StatelessWidget {
  final String message;

  const _EmptyStateMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ),
    );
  }
}

class _SavingAccountCard extends StatelessWidget {
  final SavingAccount account;
  final bool isPrivacyMode;

  const _SavingAccountCard({required this.account, required this.isPrivacyMode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyCode = context.read<SettingsViewModel>().settings.primaryCurrencyCode;
    final format = NumberFormat.currency(
      locale: l10n.localeName,
      name: currencyCode,
      decimalDigits: currencyCode == 'JPY' ? 0 : 2,
    );

    final futureValue = account.endDate == null
        ? null
        : account.getEstimatedFutureValue(account.endDate!);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditSavingAccountView(account: account),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: 0.5),
                  child: Icon(
                    Icons.savings_outlined,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.name, style: Theme.of(context).textTheme.titleMedium),
                      if (account.notes != null && account.notes!.isNotEmpty)
                        Text(
                          account.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isPrivacyMode ? PrivacyModeService.maskSymbol : format.format(account.balance),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
            if (futureValue != null && futureValue > account.balance)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.estimatedValueAt(
                            DateFormat.yMMMd(l10n.localeName).format(account.endDate!),
                          ),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade800,
                              ),
                        ),
                        Text(
                          isPrivacyMode ? PrivacyModeService.maskSymbol : format.format(futureValue),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SavingGoalCard extends StatelessWidget {
  final SavingGoal goal;
  final bool isPrivacyMode;

  const _SavingGoalCard({required this.goal, required this.isPrivacyMode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyCode = context.read<SettingsViewModel>().settings.primaryCurrencyCode;
    final format = NumberFormat.currency(
      locale: l10n.localeName,
      name: currencyCode,
      decimalDigits: currencyCode == 'JPY' ? 0 : 2,
    );

    final isCompleted = goal.progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddEditSavingGoalPage(goal: goal)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCompleted ? Icons.task_alt : Icons.flag_outlined,
                  color: isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(goal.name, style: Theme.of(context).textTheme.titleLarge),
                ),
                if (isCompleted)
                  Chip(
                    avatar: const Icon(Icons.check, size: 16),
                    label: Text(l10n.completed),
                    backgroundColor: Colors.green.withValues(alpha: 0.7),
                    labelStyle: const TextStyle(color: Colors.green),
                    side: BorderSide.none,
                  ),
              ],
            ),
            if (goal.notes != null && goal.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 36),
                child: Text(
                  goal.notes!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPrivacyMode
                      ? '${PrivacyModeService.maskSymbol} / ${PrivacyModeService.maskSymbol}'
                      : '${format.format(goal.currentAmount)} / ${format.format(goal.targetAmount)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${(goal.progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Tag tag;
  final _BudgetStatus status;
  final bool isPrivacyMode;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.tag,
    required this.status,
    required this.isPrivacyMode,
    required this.onDelete,
  });

  Future<void> _showBudgetAnalysis(BuildContext context, Tag tag) async {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(l10n.analyzing),
            ],
          ),
        ),
      ),
    );

    final analysis = await context.read<ExpenditureViewModel>().analyzeBudgetForTag(tag);

    if (!context.mounted) return;
    Navigator.of(context).pop();

    if (analysis != null) {
      showDialog(
        context: context,
        builder: (_) => _AnalysisResultDialog(analysis: analysis),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.analysisFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyCode = context.read<SettingsViewModel>().settings.primaryCurrencyCode;
    final format = NumberFormat.currency(
      locale: l10n.localeName,
      name: currencyCode,
      decimalDigits: currencyCode == 'JPY' ? 0 : 2,
    );

    final progressColor =
        status.isOverBudget ? Colors.orange.shade800 : Theme.of(context).colorScheme.primary;

    final remainingAmount = status.budget - status.spent;
    final remainingColor = remainingAmount >= 0 ? Colors.green.shade800 : Colors.red.shade700;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: GlassCard(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => AddEditBudgetPage(tag: tag)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TagIcon(tag: tag, radius: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tag.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        l10n.resetsOn(DateFormat.MMMd(l10n.localeName).format(status.resetDate)),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.auto_awesome_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => _showBudgetAnalysis(context, tag),
                  tooltip: l10n.budgetAnalysis,
                ),
                if (status.isOverBudget)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade800,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey),
                  onPressed: onDelete,
                  tooltip: l10n.deleteBudget,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: status.progress.clamp(0.0, 1.0),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              backgroundColor: progressColor.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPrivacyMode
                      ? '${PrivacyModeService.maskSymbol} / ${PrivacyModeService.maskSymbol}'
                      : '${format.format(status.spent)} / ${format.format(status.budget)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${(status.progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.transactions(status.transactionCount),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  isPrivacyMode
                      ? PrivacyModeService.maskSymbol
                      : status.isOverBudget
                          ? l10n.overBudgetBy(format.format(remainingAmount.abs()))
                          : l10n.remaining(format.format(remainingAmount)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: remainingColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisResultDialog extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const _AnalysisResultDialog({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final canMeetBudget = analysis['can_meet_budget'] ?? false;
    final confidence = (analysis['confidence_score'] ?? 0.0) * 100;
    final summary = analysis['analysis_summary'] ?? l10n.noAnalysisSummary;
    final suggestions = List<String>.from(analysis['suggestions'] ?? []);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.insights, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(l10n.budgetAnalysis),
        ],
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            Text(
              canMeetBudget ? l10n.onTrackToMeetBudget : l10n.atRiskOfExceedingBudget,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: canMeetBudget ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(l10n.confidence(confidence.toStringAsFixed(0))),
            const SizedBox(height: 16),
            Text(summary),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(l10n.suggestions, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...suggestions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(s)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
