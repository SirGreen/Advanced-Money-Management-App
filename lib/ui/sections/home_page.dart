import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:money_mana_app/ui/controller/expenditure_controller.dart';
import 'package:money_mana_app/ui/controller/settings_controller.dart';
import 'package:money_mana_app/data/model/expenditure.dart';
import 'package:money_mana_app/data/model/group_divider.dart';
import 'package:money_mana_app/ui/sections/add_edit_expenditure_page.dart';
import 'package:money_mana_app/ui/helpers/glass_card.dart';
import 'package:money_mana_app/ui/helpers/gradient_background.dart';
import 'package:money_mana_app/ui/helpers/shared_axis_page_route.dart';
import 'package:money_mana_app/ui/helpers/tag_icon.dart';
import ../../l10n/app_localizations.dart';

class _ExpenditureGroup {
  final GroupDivider divider;
  final List<Expenditure> expenditures;
  _ExpenditureGroup({required this.divider, required this.expenditures});
}

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return const _HomePageContent();
  }
}

class _HomePageContent extends StatefulWidget {
  const _HomePageContent();

  @override
  State<_HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<_HomePageContent> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final l10n = AppLocalizations.of(context)!;
      final settings =
          Provider.of<SettingsController>(context, listen: false).settings;
      final expenditureController =
          Provider.of<ExpenditureController>(context, listen: false);
      expenditureController.initialize(l10n, settings);
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final expenditureController =
        Provider.of<ExpenditureController>(context, listen: false);
    final settings =
        Provider.of<SettingsController>(context, listen: false).settings;
    final isFilterActive = _filterStartDate != null && _filterEndDate != null;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !expenditureController.isLoading &&
        expenditureController.hasMoreExpenditures &&
        !isFilterActive) {
      expenditureController.loadMoreExpenditures(settings);
    }
  }

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
      saveText: l10n.done,
      cancelText: l10n.cancel,
    );
    if (picked != null) {
      setState(() {
        _filterStartDate = picked.start;
        _filterEndDate = picked.end;
      });
    }
  }

  void _clearDateFilter() => setState(() {
        _filterStartDate = null;
        _filterEndDate = null;
      });

  List<_ExpenditureGroup> _buildGroupedList(List<dynamic> flatItems) {
    if (flatItems.isEmpty) return [];
    final List<_ExpenditureGroup> groupedList = [];
    List<Expenditure> currentExpenditures = [];
    for (int i = flatItems.length - 1; i >= 0; i--) {
      final item = flatItems[i];
      if (item is Expenditure) {
        currentExpenditures.insert(0, item);
      } else if (item is GroupDivider) {
        groupedList.insert(
          0,
          _ExpenditureGroup(divider: item, expenditures: currentExpenditures),
        );
        currentExpenditures = [];
      }
    }
    return groupedList;
  }

  Widget _buildExpenditureRow(
    Expenditure expenditure,
    AppLocalizations l10n,
    ExpenditureController expenditureController,
    String primaryCurrencyCode,
  ) {
    final mainTag = expenditureController.getTagById(expenditure.mainTagId);
    final amountColor =
        expenditure.isIncome ? Colors.green.shade700 : Colors.red.shade700;
    final currentLocale = l10n.localeName;
    final String amountString;
    if (expenditure.amount != null) {
      final itemCurrencyCode = expenditure.currencyCode;
      final currencySymbol = NumberFormat.simpleCurrency(
        name: itemCurrencyCode,
      ).currencySymbol;
      final formattedAmount = NumberFormat.currency(
        symbol: currencySymbol,
        decimalDigits: 2,
      ).format(expenditure.amount);
      final prefix = expenditure.isIncome ? '+' : '-';
      amountString = '$prefix$formattedAmount';
    } else {
      amountString = l10n.noAmountSet;
    }
    return InkWell(
      onTap: () => Navigator.of(context).push(
        SharedAxisPageRoute(
          page: AddEditExpenditurePage(expenditure: expenditure),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            mainTag != null
                ? TagIcon(tag: mainTag)
                : const CircleAvatar(child: Icon(Icons.help_outline)),
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
                    '${mainTag?.name ?? l10n.noTag} • '
                    '${DateFormat.yMMMd(currentLocale).format(expenditure.date)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color.fromARGB(255, 85, 84, 84),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              amountString,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTransactionListWithDividers(
    List<Expenditure> expenditures,
    AppLocalizations l10n,
    ExpenditureController expenditureController,
    String currencyCode,
  ) {
    final List<Widget> widgets = [];
    for (var i = 0; i < expenditures.length; i++) {
      widgets.add(
        _buildExpenditureRow(
          expenditures[i],
          l10n,
          expenditureController,
          currencyCode,
        ),
      );
      if (i < expenditures.length - 1) {
        widgets.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: Colors.grey.shade300,
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildActiveFilterInfo(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: ActionChip(
        avatar: Icon(
          Icons.filter_list,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: Text(
          '${DateFormat.yMMMd(l10n.localeName).format(_filterStartDate!)}'
          ' - '
          '${DateFormat.yMMMd(l10n.localeName).format(_filterEndDate!)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: _clearDateFilter,
        tooltip: l10n.clearFilter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isFilterActive =
        _filterStartDate != null && _filterEndDate != null;
    final expenditureController = context.watch<ExpenditureController>();
    final settingsController = context.watch<SettingsController>();

    final homeAppBar = HomeAppBar(
      l10n: l10n,
      isFilterActive: isFilterActive,
      onSelectDateRange: _selectDateRange,
      allTimeBalance: expenditureController.getAllTimeMoneyLeft(),
      currencyCode: settingsController.settings.primaryCurrencyCode,
    );
    final double appBarHeight = homeAppBar.preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalTopOffset = appBarHeight + statusBarHeight;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: homeAppBar,
        body: RefreshIndicator(
          onRefresh: () => expenditureController.loadInitialExpenditures(
            settingsController.settings,
          ),
          edgeOffset: totalTopOffset,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.only(top: totalTopOffset, bottom: 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isFilterActive)
                      Center(child: _buildActiveFilterInfo(l10n)),
                    Consumer2<ExpenditureController, SettingsController>(
                      builder: (
                        context,
                        expenditureController,
                        settingsController,
                        child,
                      ) {
                        if (expenditureController.isLoading &&
                            expenditureController.expenditures.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final flatItems =
                            expenditureController.getGroupedExpenditures(
                          settingsController.settings,
                          startDate: _filterStartDate,
                          endDate: _filterEndDate,
                        );
                        final groupedList = _buildGroupedList(flatItems);
                        if (groupedList.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Center(
                              child: Text(
                                isFilterActive
                                    ? l10n.noResultsFound
                                    : l10n.noTransactions,
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: groupedList.length,
                          itemBuilder: (context, index) {
                            final group = groupedList[index];
                            final item = group.divider;
                            final currencyCode = settingsController
                                .settings.primaryCurrencyCode;
                            final groupCurrencySymbol =
                                NumberFormat.simpleCurrency(
                              name: currencyCode,
                            ).currencySymbol;
                            final formattedTotal = NumberFormat.currency(
                              symbol: groupCurrencySymbol,
                              decimalDigits: 2,
                            ).format(item.totalAmount);
                            final prefix =
                                item.totalAmount >= 0 ? '+' : '';
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
                              child: Text(
                                '$prefix$formattedTotal',
                                style: amountTextStyle,
                              ),
                            );

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
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
                                        amount: '$prefix$formattedTotal',
                                        amountStyle: amountTextStyle.copyWith(
                                          color: Colors.black,
                                        ),
                                        amountWidget: amountWidget,
                                      ),
                                    ),
                                    ..._buildTransactionListWithDividers(
                                      group.expenditures,
                                      l10n,
                                      expenditureController,
                                      currencyCode,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Consumer<ExpenditureController>(
                      builder: (context, controller, child) {
                        return (controller.isLoading &&
                                controller.expenditures.isNotEmpty)
                            ? const Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 32.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
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
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final bool isFilterActive;
  final VoidCallback onSelectDateRange;
  final double allTimeBalance;
  final String currencyCode;

  const HomeAppBar({
    super.key,
    required this.l10n,
    required this.isFilterActive,
    required this.onSelectDateRange,
    required this.allTimeBalance,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = Colors.white.withValues(alpha: 0.4);
    final balanceColor =
        allTimeBalance >= 0 ? Colors.green.shade800 : Colors.red.shade700;
    final formattedBalance = NumberFormat.currency(
      name: currencyCode,
      decimalDigits: 2,
    ).format(allTimeBalance);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          centerTitle: true,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.allTimeBalance,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              Text(
                formattedBalance,
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
                  top: BorderSide(color: dividerColor, width: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        isFilterActive
                            ? Icons.filter_list
                            : Icons.filter_list_off_outlined,
                      ),
                      onPressed: onSelectDateRange,
                      tooltip: l10n.filterByDate,
                    ),
                  ],
                ),
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