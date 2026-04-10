import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';

import 'expenditure_view_model.dart';
import 'add_transaction_view.dart';
import 'search_page.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/tag.dart';
import '../settings/settings_view_model.dart';
import '../../data/services/privacy_mode_service.dart';
import 'scheduled_expenditure_list_view.dart';
import '../tags/manage_tags_page.dart';
import '../helpers/glass_card.dart';
import '../helpers/tag_icon.dart';
import '../helpers/shared_axis_page_route.dart';
import '../helpers/gradient_background.dart';
import '../../l10n/app_localizations.dart';

// --- UI-only data models ---

class _GroupDivider {
  final String displayTitle;
  final double totalAmount;
  _GroupDivider({required this.displayTitle, required this.totalAmount});
}

class _ExpenditureGroup {
  final _GroupDivider divider;
  final List<Expenditure> expenditures;
  _ExpenditureGroup({required this.divider, required this.expenditures});
}

// --- Responsive header (matches legacy _ResponsiveGroupHeader) ---

class _ResponsiveGroupHeader extends StatelessWidget {
  final String title;
  final TextStyle titleStyle;
  final Widget titleWidget;
  final String amount;
  final TextStyle amountStyle;
  final Widget amountWidget;

  const _ResponsiveGroupHeader({
    required this.title,
    required this.titleStyle,
    required this.titleWidget,
    required this.amount,
    required this.amountStyle,
    required this.amountWidget,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titlePainter = TextPainter(
          text: TextSpan(text: title, style: titleStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final amountPainter = TextPainter(
          text: TextSpan(text: amount, style: amountStyle),
          maxLines: 1,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final titleWidth = titlePainter.width;
        final amountWidth = amountPainter.width;
        const spacing = 16.0;
        final bool overflows =
            (titleWidth + amountWidth + spacing) > constraints.maxWidth;
        if (overflows) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              titleWidget,
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerRight, child: amountWidget),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [titleWidget, amountWidget],
          );
        }
      },
    );
  }
}

// --- Main TransactionListView widget ---

class TransactionListView extends StatefulWidget {
  const TransactionListView({super.key});

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  Future<void> _selectDateRange() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _filterStartDate != null && _filterEndDate != null
          ? DateTimeRange(start: _filterStartDate!, end: _filterEndDate!)
          : null,
      helpText: l10n.selectDateRange,
    );
    if (picked != null) {
      setState(() {
        _filterStartDate = picked.start;
        _filterEndDate = picked.end;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _filterStartDate = null;
      _filterEndDate = null;
    });
  }

  List<_ExpenditureGroup> _buildGroupedList(List<Expenditure> expenditures) {
    if (expenditures.isEmpty) return [];

    // Filter by date range if active
    final filtered = expenditures.where((e) {
      if (_filterStartDate == null || _filterEndDate == null) return true;
      return e.date.isAfter(
            _filterStartDate!.subtract(const Duration(days: 1)),
          ) &&
          e.date.isBefore(_filterEndDate!.add(const Duration(days: 1)));
    }).toList();

    if (filtered.isEmpty) return [];

    final Map<String, List<Expenditure>> grouped = {};
    for (final exp in filtered) {
      final key = DateFormat('MMMM yyyy').format(exp.date);
      grouped.putIfAbsent(key, () => []).add(exp);
    }

    // Sort by date key descending
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    final List<_ExpenditureGroup> groups = [];
    for (final key in sortedKeys) {
      final exps = grouped[key]!;
      double total = 0;
      for (final e in exps) {
        total += (e.isIncome ? 1 : -1) * (e.amount ?? 0);
      }

      groups.add(
        _ExpenditureGroup(
          divider: _GroupDivider(displayTitle: key, totalAmount: total),
          expenditures: exps,
        ),
      );
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = Provider.of<ExpenditureViewModel>(context);
    final settingsViewModel = Provider.of<SettingsViewModel>(context);
    final isPrivacyMode = settingsViewModel.settings.privacyModeEnabled;

    final double totalBalance = viewModel.getAllTimeMoneyLeft();
    final bool isFilterActive =
        _filterStartDate != null && _filterEndDate != null;

    final homeAppBar = HomeAppBar(
      l10n: l10n,
      isFilterActive: isFilterActive,
      onSelectDateRange: _selectDateRange,
      allTimeBalance: totalBalance,
      currencyCode: settingsViewModel.settings.primaryCurrencyCode,
      isPrivacyMode: isPrivacyMode,
    );

    final double appBarHeight = homeAppBar.preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalTopOffset = appBarHeight + statusBarHeight;

    final groupedList = _buildGroupedList(viewModel.expenditures);

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: homeAppBar,
        body: RefreshIndicator(
          onRefresh: () async => await viewModel.loadExpenditures(),
          edgeOffset: totalTopOffset,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(8, totalTopOffset + 16, 8, 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isFilterActive)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: ActionChip(
                            avatar: const Icon(Icons.filter_list, size: 16),
                            label: Text(
                              '${DateFormat('dd/MM/yy').format(_filterStartDate!)} - ${DateFormat('dd/MM/yy').format(_filterEndDate!)}',
                            ),
                            onPressed: _clearDateFilter,
                          ),
                        ),
                      ),
                    if (viewModel.isLoading && viewModel.expenditures.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else if (groupedList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isFilterActive
                                  ? l10n.noResultsFound
                                  : l10n.noTransactions,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: groupedList.length,
                        itemBuilder: (context, index) {
                          final group = groupedList[index];
                          final item = group.divider;

                          final formattedTotal = NumberFormat.currency(
                            locale: Localizations.localeOf(context).toString(),
                            symbol: NumberFormat.simpleCurrency(name: settingsViewModel.settings.primaryCurrencyCode).currencySymbol,
                            decimalDigits: 0, // Defaulting to 0 for safety or we can refine this
                          ).format(item.totalAmount.abs());
                          final prefix = item.totalAmount >= 0 ? '+' : '-';
                          final displayTotal = isPrivacyMode
                              ? PrivacyModeService.maskSymbol
                              : '$prefix$formattedTotal';

                          final titleTextStyle = Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              );
                          final titleGradient = LinearGradient(
                            colors: [
                              Colors.green.shade900,
                              Colors.green.shade600,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          );
                          final titleWidget = ShaderMask(
                            shaderCallback: (bounds) =>
                                titleGradient.createShader(bounds),
                            child: Text(
                              item.displayTitle.toUpperCase(),
                              style: titleTextStyle,
                            ),
                          );

                          final amountTextStyle = Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              );
                          final amountGradient = item.totalAmount >= 0
                              ? LinearGradient(
                                  colors: [
                                    Colors.green.shade800,
                                    Colors.green.shade500,
                                  ],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.red.shade800,
                                    Colors.red.shade500,
                                  ],
                                );
                          final amountWidget = ShaderMask(
                            shaderCallback: (bounds) =>
                                amountGradient.createShader(bounds),
                            child: Text(displayTotal, style: amountTextStyle),
                          );

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GlassCard(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GlassCard(
                                    color: const Color.fromARGB(
                                      255,
                                      109,
                                      250,
                                      96,
                                    ).withValues(alpha: 0.15),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    child: _ResponsiveGroupHeader(
                                      title: item.displayTitle.toUpperCase(),
                                      titleStyle: titleTextStyle.copyWith(
                                        color: Colors.black,
                                      ),
                                      titleWidget: titleWidget,
                                      amount: displayTotal,
                                      amountStyle: amountTextStyle.copyWith(
                                        color: Colors.black,
                                      ),
                                      amountWidget: amountWidget,
                                    ),
                                  ),
                                  ...(() {
                                    final List<Widget> children = [];
                                    for (
                                      int i = 0;
                                      i < group.expenditures.length;
                                      i++
                                    ) {
                                      children.add(
                                        _buildExpenditureRow(
                                          context,
                                          group.expenditures[i],
                                          viewModel,
                                          isPrivacyMode,
                                        ),
                                      );
                                      if (i < group.expenditures.length - 1) {
                                        children.add(
                                          const Divider(
                                            height: 1,
                                            thickness: 0.5,
                                            indent:
                                                72, // Align with text after icon
                                            endIndent: 16,
                                          ),
                                        );
                                      }
                                    }
                                    return [Column(children: children)];
                                  })(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenditureRow(
    BuildContext context,
    Expenditure expenditure,
    ExpenditureViewModel viewModel,
    bool isPrivacyMode,
  ) {
    final tag =
        viewModel.getTagById(expenditure.mainTagId) ??
        Tag(id: 'unknown', name: 'Unknown', colorValue: Colors.grey.toARGB32());
    final l10n = AppLocalizations.of(context)!;

    final amountColor = expenditure.isIncome
        ? Colors.green.shade700
        : Colors.red.shade700;

    Widget amountWidget;
    if (expenditure.amount == null || expenditure.amount == 0) {
      amountWidget = Text(
        l10n.noAmountSet,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    } else {
      final currencySymbol = NumberFormat.simpleCurrency(
        name: expenditure.currencyCode,
      ).currencySymbol;

      final formattedAmount =
          '${expenditure.isIncome ? '+' : '-'}${NumberFormat.currency(locale: Localizations.localeOf(context).toString(), symbol: currencySymbol, decimalDigits: expenditure.currencyCode == 'JPY' ? 0 : 2).format(expenditure.amount)}';

      amountWidget = Text(
        isPrivacyMode ? PrivacyModeService.maskSymbol : formattedAmount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: amountColor,
        ),
      );
    }

    return InkWell(
      onTap: () => Navigator.of(context).push(
        SharedAxisPageRoute(
          page: AddTransactionView(expenditure: expenditure),
          transitionType: SharedAxisTransitionType.scaled,
        ),
      ),
      onLongPress: () => _showDeleteDialog(context, viewModel, expenditure),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            TagIcon(tag: tag),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expenditure.articleName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tag.name} • ${DateFormat.yMMMd('en_US').format(expenditure.date)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color.fromARGB(255, 85, 84, 84),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            amountWidget,
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    ExpenditureViewModel viewModel,
    Expenditure expenditure,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await viewModel.deleteExpenditure(expenditure.id);
            },
            child: Text(
              l10n.delete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Specialized HomeAppBar ---

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final bool isFilterActive;
  final VoidCallback onSelectDateRange;
  final double allTimeBalance;
  final String currencyCode;
  final bool isPrivacyMode;

  const HomeAppBar({
    super.key,
    required this.l10n,
    required this.isFilterActive,
    required this.onSelectDateRange,
    required this.allTimeBalance,
    required this.currencyCode,
    required this.isPrivacyMode,
  });

  @override
  Widget build(BuildContext context) {
    final balanceColor = allTimeBalance >= 0
        ? Colors.green.shade800
        : Colors.red.shade700;
    final currencySymbol = NumberFormat.simpleCurrency(
      name: currencyCode,
    ).currencySymbol;

    final formattedBalance = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: currencySymbol,
      decimalDigits: currencyCode == 'JPY' ? 0 : 2,
    ).format(allTimeBalance);
    final displayBalance = isPrivacyMode
        ? PrivacyModeService.maskSymbol
        : formattedBalance;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.allTimeMoneyLeft.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              Text(
                displayBalance,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: balanceColor,
                ),
              ),
            ],
          ),
          elevation: 0,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: Icon(
                      isFilterActive
                          ? Icons.filter_list
                          : Icons.filter_list_off_outlined,
                    ),
                    onPressed: onSelectDateRange,
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchPage()),
                    ),
                  ),
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) {
                      if (value == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ScheduledExpenditureListView(),
                          ),
                        );
                      } else if (value == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageTagsPage(),
                          ),
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.event_repeat,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.manageScheduled),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.label_outline,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 12),
                            Text(l10n.manageTags),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 2);
}
