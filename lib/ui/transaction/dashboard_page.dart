
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/expenditure.dart';
import '../../domain/entities/scheduled_expenditure.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/entities/tag.dart';
import '../../l10n/app_localizations.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/section_header.dart';
import '../helpers/shared_axis_page_route.dart';
import '../helpers/tag_icon.dart';
import '../sections/camera_scanner_page.dart';
import '../settings/settings_view_model.dart';
import 'add_transaction_view.dart';
import '../../data/services/privacy_mode_service.dart';
import '../widgets/privacy_mode_widgets.dart';
import 'expenditure_view_model.dart';
import 'scheduled_expenditure_view_model.dart';
import 'search_results_page.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;

  const DashboardAppBar({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GradientTitle(text: l10n.dashboard),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class DashboardPage extends StatelessWidget {
  final VoidCallback onViewAllTransactions;
  final VoidCallback onViewBudgets;
  final VoidCallback onNavigateToSettings;

  const DashboardPage({
    super.key,
    required this.onViewAllTransactions,
    required this.onViewBudgets,
    required this.onNavigateToSettings,
  });

  Widget buildFab(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      backgroundColor: Colors.teal.shade600,
      foregroundColor: Colors.white,
      activeBackgroundColor: Colors.teal.shade800,
      tooltip: l10n.addTransaction,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.camera_alt_outlined),
          backgroundColor: Colors.teal.shade500,
          foregroundColor: Colors.white,
          label: l10n.scanReceipt,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CameraScannerPage()),
          ),
        ),
        SpeedDialChild(
          child: const Icon(Icons.edit),
          backgroundColor: Colors.teal.shade500,
          foregroundColor: Colors.white,
          label: l10n.addManually,
          onTap: () => Navigator.of(context).push(
            SharedAxisPageRoute(
              page: const AddTransactionView(),
              transitionType: SharedAxisTransitionType.scaled,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dashboardAppBar = DashboardAppBar(l10n: l10n);
    final appBarHeight = dashboardAppBar.preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalTopOffset = appBarHeight + statusBarHeight;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: dashboardAppBar,
        body: Consumer3<
          ExpenditureViewModel,
          SettingsViewModel,
          ScheduledExpenditureViewModel
        >(
          builder: (context, expenditureVm, settingsVm, scheduledVm, child) {
            final allTimeBalance = expenditureVm.getAllTimeMoneyLeft();
            final recentTransactions = expenditureVm.expenditures.take(5).toList();
            final overBudgetTags = _getOverBudgetTags(expenditureVm);
            final upcomingScheduled = _getUpcomingScheduled(
              scheduledVm.scheduledExpenditures,
            );
            final showBackupReminder = _shouldShowBackupReminder(
              settingsVm.settings.lastBackupDate,
            );

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(8, totalTopOffset + 8, 8, 90),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _AccountBalanceCards(
                        allTimeBalance: allTimeBalance,
                        currencyCode: settingsVm.settings.primaryCurrencyCode,
                      ),
                      if (showBackupReminder)
                        _BackupReminderCard(
                          l10n: l10n,
                          onTap: onNavigateToSettings,
                        ),
                      _RecentTransactionsCard(
                        l10n: l10n,
                        transactions: recentTransactions,
                        onViewAll: onViewAllTransactions,
                      ),
                      if (overBudgetTags.isNotEmpty)
                        _AlertCard(
                          l10n: l10n,
                          title: l10n.overBudget,
                          count: overBudgetTags.length,
                          icon: Icons.warning_amber_rounded,
                          color: Colors.orange,
                          onTap: onViewBudgets,
                        ),
                      _UpcomingTransactionsCard(
                        l10n: l10n,
                        scheduled: upcomingScheduled,
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Tag> _getOverBudgetTags(ExpenditureViewModel vm) {
    return vm.tags.where((tag) {
      if (tag.budgetAmount == null || tag.budgetAmount! <= 0) return false;
      final spent = vm.getSpentAmountForTagBudget(tag);
      return spent > tag.budgetAmount!;
    }).toList();
  }

  List<ScheduledExpenditure> _getUpcomingScheduled(
    List<ScheduledExpenditure> rules,
  ) {
    final active = rules.where((r) => r.isActive).toList();
    active.sort((a, b) {
      final aDate = _nextOccurrence(a);
      final bDate = _nextOccurrence(b);
      return aDate.compareTo(bDate);
    });
    return active.take(5).toList();
  }

  DateTime _nextOccurrence(ScheduledExpenditure rule) {
    final now = DateTime.now();
    if (rule.endDate != null && rule.endDate!.isBefore(now)) {
      return DateTime(9999);
    }

    switch (rule.scheduleType) {
      case ScheduleType.fixedInterval:
        final last = rule.lastCreatedDate ?? rule.startDate;
        var candidate = last;
        while (!candidate.isAfter(now)) {
          candidate = candidate.add(Duration(days: rule.scheduleValue));
        }
        return candidate;
      case ScheduleType.dayOfMonth:
        var month = now.month;
        var year = now.year;
        var day = rule.scheduleValue.clamp(1, 28);
        var candidate = DateTime(year, month, day);
        if (!candidate.isAfter(now)) {
          month += 1;
          if (month > 12) {
            month = 1;
            year += 1;
          }
          candidate = DateTime(year, month, day);
        }
        return candidate;
      case ScheduleType.endOfMonth:
        var candidate = DateTime(now.year, now.month + 1, 0);
        if (!candidate.isAfter(now)) {
          candidate = DateTime(now.year, now.month + 2, 0);
        }
        return candidate;
      case ScheduleType.daysBeforeEndOfMonth:
        var monthEnd = DateTime(now.year, now.month + 1, 0);
        var candidate = monthEnd.subtract(Duration(days: rule.scheduleValue));
        if (!candidate.isAfter(now)) {
          monthEnd = DateTime(now.year, now.month + 2, 0);
          candidate = monthEnd.subtract(Duration(days: rule.scheduleValue));
        }
        return candidate;
    }
  }

  bool _shouldShowBackupReminder(DateTime? lastBackupDate) {
    if (lastBackupDate == null) return true;
    return DateTime.now().difference(lastBackupDate).inDays >= 7;
  }
}

class _AccountBalanceCards extends StatelessWidget {
  final double allTimeBalance;
  final String currencyCode;

  const _AccountBalanceCards({
    required this.allTimeBalance,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _BalanceCard(
      title: l10n.allTimeBalance,
      amount: allTimeBalance,
      currencyCode: currencyCode,
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currencyCode;

  const _BalanceCard({
    required this.title,
    required this.amount,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final isPrivacyMode = context.watch<SettingsViewModel>().settings.privacyModeEnabled;
    final amountColor = amount >= 0 ? Colors.green.shade800 : Colors.red.shade700;
    final formatted = NumberFormat.currency(
      name: currencyCode,
      decimalDigits: currencyCode == 'JPY' ? 0 : 2,
    ).format(amount);

    return Container(
      margin: const EdgeInsets.all(8),
      child: GlassCard(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPrivacyMode ? PrivacyModeService.maskSymbol : formatted,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackupReminderCard extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _BackupReminderCard({required this.l10n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        onTap: onTap,
        color: Colors.blue.withValues(alpha: 0.4),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Icon(
            Icons.cloud_upload_outlined,
            color: Colors.blue.shade800,
            size: 32,
          ),
          title: Text(
            l10n.backupReminderTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(l10n.backupReminderSubtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AppLocalizations l10n;
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AlertCard({
    required this.l10n,
    required this.title,
    required this.count,
    required this.icon,
    this.color = Colors.blue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Icon(icon, color: color, size: 32),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(l10n.itemsNeedAttention(count)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  final AppLocalizations l10n;
  final List<Expenditure> transactions;
  final VoidCallback onViewAll;

  const _RecentTransactionsCard({
    required this.l10n,
    required this.transactions,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final isPrivacyMode = context.watch<SettingsViewModel>().settings.privacyModeEnabled;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            SectionHeader(title: l10n.recentTransactions),
            if (transactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text(l10n.noRecentTransactions)),
              )
            else
              ...transactions.map((exp) {
                final tag = Provider.of<ExpenditureViewModel>(
                  context,
                  listen: false,
                ).getTagById(exp.mainTagId);
                return ListTile(
                  leading: tag != null ? TagIcon(tag: tag, radius: 16) : null,
                  title: PrivacyBlur(isPrivate: isPrivacyMode, child: Text(exp.articleName)),
                  subtitle: Text(
                    DateFormat.yMMMd(l10n.localeName).format(exp.date),
                  ),
                  trailing: Text(
                    isPrivacyMode
                        ? PrivacyModeService.maskSymbol
                        : NumberFormat.currency(
                            name: exp.currencyCode,
                            decimalDigits: exp.currencyCode == 'JPY' ? 0 : 2,
                          ).format(exp.amount ?? 0),
                    style: TextStyle(
                      color: exp.isIncome
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddTransactionView(expenditure: exp),
                    ),
                  ),
                );
              }),
            const Divider(height: 1, indent: 16, endIndent: 16),
            TextButton(onPressed: onViewAll, child: Text(l10n.viewAll)),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTransactionsCard extends StatelessWidget {
  final AppLocalizations l10n;
  final List<ScheduledExpenditure> scheduled;

  const _UpcomingTransactionsCard({
    required this.l10n,
    required this.scheduled,
  });

  @override
  Widget build(BuildContext context) {
    if (scheduled.isEmpty) return const SizedBox.shrink();
    final isPrivacyMode = context.watch<SettingsViewModel>().settings.privacyModeEnabled;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: GlassCard(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SectionHeader(title: l10n.upcoming),
            ...scheduled.map((rule) {
              final amountText = rule.amount != null
                  ? NumberFormat.currency(
                      name: rule.currencyCode,
                      decimalDigits: rule.currencyCode == 'JPY' ? 0 : 2,
                    ).format(rule.amount)
                  : l10n.noAmountSet;

              return ListTile(
                leading: Icon(
                  rule.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                  color: rule.isIncome ? Colors.green : Colors.red,
                ),
                title: Text(rule.name),
                trailing: Text(isPrivacyMode ? PrivacyModeService.maskSymbol : amountText),
                onTap: () {
                  final filter = SearchFilter(
                    keyword: rule.name,
                    transactionType: rule.isIncome
                        ? TransactionTypeFilter.income
                        : TransactionTypeFilter.expense,
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SearchResultsPage(filter: filter),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
