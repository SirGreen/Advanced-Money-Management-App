import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:money_mana_app/ui/controller/expenditure_controller.dart';
import 'package:money_mana_app/ui/controller/settings_controller.dart';
import 'package:money_mana_app/data/model/expenditure.dart';
import 'package:money_mana_app/data/model/tag.dart';
import 'package:money_mana_app/ui/helpers/glass_card.dart';
import 'package:money_mana_app/ui/helpers/gradient_background.dart';
import 'package:money_mana_app/ui/helpers/gradient_title.dart';
import 'package:money_mana_app/ui/helpers/tag_icon.dart';
import ../l10n/app_localizations.dart';

enum SortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
  nameAsc,
  nameDesc,
}

class FilteredTransactionsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Tag tag;
  final DateTimeRange dateRange;
  final AppLocalizations l10n;
  final Function(SortOption) onSortSelected;

  const FilteredTransactionsAppBar({
    super.key,
    required this.tag,
    required this.dateRange,
    required this.l10n,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          title: GradientTitle(text: tag.name),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          actions: [
            PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort),
              tooltip: l10n.sortBy,
              onSelected: onSortSelected,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: SortOption.dateDesc,
                  child: Text(l10n.dateNewestFirst),
                ),
                PopupMenuItem(
                  value: SortOption.dateAsc,
                  child: Text(l10n.dateOldestFirst),
                ),
                PopupMenuItem(
                  value: SortOption.amountDesc,
                  child: Text(l10n.amountHighestFirst),
                ),
                PopupMenuItem(
                  value: SortOption.amountAsc,
                  child: Text(l10n.amountLowestFirst),
                ),
                PopupMenuItem(
                  value: SortOption.nameAsc,
                  child: Text(l10n.nameAZ),
                ),
                PopupMenuItem(
                  value: SortOption.nameDesc,
                  child: Text(l10n.nameZA),
                ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(24.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                '${DateFormat.yMMMd(l10n.localeName).format(dateRange.start)}'
                ' - '
                '${DateFormat.yMMMd(l10n.localeName).format(dateRange.end)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 36.0);
}

class FilteredTransactionsPage extends StatefulWidget {
  final Tag tag;
  final DateTimeRange dateRange;
  final bool showIncomeOnly;

  const FilteredTransactionsPage({
    super.key,
    required this.tag,
    required this.dateRange,
    required this.showIncomeOnly,
  });

  @override
  State<FilteredTransactionsPage> createState() =>
      _FilteredTransactionsPageState();
}

class _FilteredTransactionsPageState extends State<FilteredTransactionsPage> {
  late List<Expenditure> _results;
  SortOption _currentSortOption = SortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    _loadAndSortResults();
  }

  void _loadAndSortResults() {
    final expenditureController =
        Provider.of<ExpenditureController>(context, listen: false);
    final allResults = expenditureController.getTransactionsForTagInRange(
      widget.tag,
      widget.dateRange,
    );
    setState(() {
      _results =
          allResults.where((exp) => exp.isIncome == widget.showIncomeOnly).toList();
      _sortResults();
    });
  }

  void _sortResults() {
    switch (_currentSortOption) {
      case SortOption.dateAsc:
        _results.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountDesc:
        _results.sort((a, b) => (b.amount ?? 0).compareTo(a.amount ?? 0));
        break;
      case SortOption.amountAsc:
        _results.sort((a, b) => (a.amount ?? 0).compareTo(b.amount ?? 0));
        break;
      case SortOption.nameAsc:
        _results.sort(
          (a, b) =>
              a.articleName.toLowerCase().compareTo(b.articleName.toLowerCase()),
        );
        break;
      case SortOption.nameDesc:
        _results.sort(
          (a, b) =>
              b.articleName.toLowerCase().compareTo(a.articleName.toLowerCase()),
        );
        break;
      case SortOption.dateDesc:
        _results.sort((a, b) => b.date.compareTo(a.date));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);
    final currencyCode = settingsController.settings.primaryCurrencyCode;

    final filteredAppBar = FilteredTransactionsAppBar(
      tag: widget.tag,
      dateRange: widget.dateRange,
      l10n: l10n,
      onSortSelected: (newSortOption) {
        setState(() {
          _currentSortOption = newSortOption;
          _sortResults();
        });
      },
    );

    final double appBarHeight = filteredAppBar.preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalTopOffset = appBarHeight + statusBarHeight;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: filteredAppBar,
        body: CustomScrollView(
          slivers: [
            if (_results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(top: totalTopOffset),
                  child: Center(child: Text(l10n.noTransactionsFound)),
                ),
              )
            else
              SliverPadding(
                padding:
                    EdgeInsets.fromLTRB(8, totalTopOffset + 8, 8, 8),
                sliver: SliverList.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final expenditure = _results[index];
                    final bool isExpense = !expenditure.isIncome;
                    return GlassCardContainer(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      padding: EdgeInsets.zero,
                      child: ListTile(
                        leading: TagIcon(tag: widget.tag, radius: 20),
                        title: Text(
                          expenditure.articleName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          DateFormat.yMMMd(l10n.localeName)
                              .format(expenditure.date),
                        ),
                        trailing: Text(
                          NumberFormat.currency(
                            locale: l10n.localeName,
                            name: currencyCode,
                            decimalDigits: 2,
                          ).format(expenditure.amount ?? 0.0),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isExpense
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}