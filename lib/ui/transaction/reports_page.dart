import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'expenditure_view_model.dart';
import '../settings/settings_view_model.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/report_data.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/tag_icon.dart';
import '../../l10n/app_localizations.dart';

class ReportsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final VoidCallback onResetDate;
  final VoidCallback onSelectDate;
  final DateTimeRange dateRange;

  const ReportsAppBar({
    super.key,
    required this.l10n,
    required this.onResetDate,
    required this.onSelectDate,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: AppBar(
          title: Text(l10n.manageScheduled),
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
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: onSelectDate,
              tooltip: l10n.selectDateRange,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: onResetDate,
              tooltip: l10n.end,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(24.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                '${DateFormat.yMMMd(l10n.localeName).format(dateRange.start)} - ${DateFormat.yMMMd(l10n.localeName).format(dateRange.end)}',
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

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    _dateRange = _calculateDefaultDateRange();
  }

  static DateTimeRange _calculateDefaultDateRange() {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = endDate.subtract(const Duration(days: 29));
    return DateTimeRange(start: startDate, end: endDate);
  }

  void _selectDateRange() async {
    final l10n = AppLocalizations.of(context)!;
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: l10n.selectDateRange,
      saveText: l10n.end,
      cancelText: l10n.cancel,
    );
    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _resetDateRange() {
    setState(() {
      _dateRange = _calculateDefaultDateRange();
    });
  }

  void _navigateToFilteredList(
    BuildContext context,
    Tag tag,
    DateTimeRange dateRange, {
    required bool isIncomeOnly,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FilteredTransactionsPage(
          tag: tag,
          dateRange: dateRange,
          showIncomeOnly: isIncomeOnly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expenditureViewModel =
        Provider.of<ExpenditureViewModel>(context, listen: false);
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);

    return BackGround(
      child: FutureBuilder<ReportData>(
        future: expenditureViewModel.getReportData(_dateRange),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reportData = snapshot.data!;
          final currencyCode = settingsViewModel.settings.primaryCurrencyCode;

          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: ReportsAppBar(
              l10n: l10n,
              onResetDate: _resetDateRange,
              onSelectDate: _selectDateRange,
              dateRange: _dateRange,
            ),
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    8,
                    MediaQuery.of(context).padding.top + kToolbarHeight + 40,
                    8,
                    8,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // All-time money left card
                      _buildAllTimeCard(context, l10n),
                      const SizedBox(height: 16),

                      // Income vs Expense card
                      _buildIncomeExpenseCard(
                        context,
                        l10n,
                        reportData,
                        currencyCode,
                      ),
                      const SizedBox(height: 16),

                      // Time series chart
                      if (reportData.lineChartData != null)
                        _buildTimeSeriesChart(
                          context,
                          reportData.lineChartData!,
                          currencyCode,
                          l10n,
                        ),
                      const SizedBox(height: 16),

                      // Expense pie chart
                      if (reportData.expenseByTag.isNotEmpty)
                        _buildPieChart(
                          context,
                          l10n,
                          'Expense Breakdown',
                          reportData.expenseByTag,
                          currencyCode,
                          _dateRange,
                          isIncomeChart: false,
                        ),
                      const SizedBox(height: 16),

                      // Income pie chart
                      if (reportData.incomeByTag.isNotEmpty)
                        _buildPieChart(
                          context,
                          l10n,
                          'Income Breakdown',
                          reportData.incomeByTag,
                          currencyCode,
                          _dateRange,
                          isIncomeChart: true,
                        ),
                      const SizedBox(height: 16),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllTimeCard(BuildContext context, AppLocalizations l10n) {
    final allTimeMoneyLeft = Provider.of<ExpenditureViewModel>(
      context,
      listen: false,
    ).getAllTimeMoneyLeft();
    final currencyCode = Provider.of<SettingsViewModel>(
      context,
      listen: false,
    ).settings.primaryCurrencyCode;
    final bool isPositive = allTimeMoneyLeft >= 0;
    final Color cardColor = isPositive
        ? Colors.green.withValues(alpha: 0.2)
        : Colors.red.withValues(alpha: 0.15);
    final Color textColor =
        isPositive ? Colors.green.shade900 : Colors.red.shade900;

    return GlassCard(
      color: cardColor,
      child: ListTile(
        leading: Icon(Icons.account_balance_wallet_outlined, color: textColor),
        title: Text(
          l10n.allTimeMoneyLeft,
          style: TextStyle(color: textColor.withValues(alpha: 0.8)),
        ),
        trailing: Text(
          NumberFormat.currency(
            locale: l10n.localeName,
            name: currencyCode,
            decimalDigits: 2,
          ).format(allTimeMoneyLeft),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseCard(
    BuildContext context,
    AppLocalizations l10n,
    ReportData data,
    String currencyCode,
  ) {
    final net = data.totalIncome - data.totalExpense;
    final currencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      decimalDigits: 2,
      name: currencyCode,
    );
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _IncomeExpenseBarChart(
            income: data.totalIncome,
            expense: data.totalExpense,
            currencyCode: currencyCode,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    l10n.income,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    currencyFormat.format(data.totalIncome),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    l10n.expense,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    currencyFormat.format(data.totalExpense),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    l10n.netBalance,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    currencyFormat.format(net),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: net >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(
    BuildContext context,
    AppLocalizations l10n,
    String title,
    Map<Tag, TagReportData> data,
    String currencyCode,
    DateTimeRange dateRange, {
    required bool isIncomeChart,
  }) {
    int touchedIndex = -1;
    final totalValue = data.values.fold(
      0.0,
      (sum, item) => sum + item.totalAmount,
    );
    final mainEntries = data.entries.toList()
      ..sort((a, b) => b.value.totalAmount.compareTo(a.value.totalAmount));

    if (mainEntries.isEmpty) return const SizedBox.shrink();

    // Take top 5 and group rest as "Other"
    final topEntries = mainEntries.take(5).toList();
    final otherAmount = mainEntries.skip(5).fold(
      0.0,
      (sum, entry) => sum + entry.value.totalAmount,
    );

    return GlassCard(
      padding: EdgeInsets.zero,
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    ...topEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final tag = entry.value.key;
                      final amount = entry.value.value.totalAmount;
                      return PieChartSectionData(
                        value: amount,
                        color: Color(tag.colorValue).withValues(alpha: 0.8),
                        radius: touchedIndex == index ? 70 : 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        title: '${(amount / totalValue * 100).toStringAsFixed(1)}%',
                      );
                    }),
                    if (otherAmount > 0)
                      PieChartSectionData(
                        value: otherAmount,
                        color: Colors.grey.withValues(alpha: 0.5),
                        radius: touchedIndex == topEntries.length ? 70 : 60,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        title: '${(otherAmount / totalValue * 100).toStringAsFixed(1)}%',
                      ),
                  ],
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),
            ),
            _buildPieChartLegend(
              context,
              l10n,
              topEntries,
              dateRange,
              totalValue,
              otherAmount,
              isIncomeChart,
              currencyCode,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartLegend(
    BuildContext context,
    AppLocalizations l10n,
    List<MapEntry<Tag, TagReportData>> entries,
    DateTimeRange dateRange,
    double totalValue,
    double otherAmount,
    bool isIncomeChart,
    String currencyCode,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      decimalDigits: 2,
      name: currencyCode,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          ...entries.map((entry) {
            final tag = entry.key;
            final amount = entry.value.totalAmount;
            final percentage = (amount / totalValue * 100).toStringAsFixed(1);

            return InkWell(
              onTap: () => _navigateToFilteredList(
                context,
                tag,
                dateRange,
                isIncomeOnly: isIncomeChart,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(tag.colorValue).withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(tag.name),
                    ),
                    Text(
                      '${currencyFormat.format(amount)} ($percentage%)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (otherAmount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Other'),
                  ),
                  Text(
                    '${currencyFormat.format(otherAmount)} (${(otherAmount / totalValue * 100).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesChart(
    BuildContext context,
    LineChartReportData data,
    String currencyCode,
    AppLocalizations l10n,
  ) {
    final currencyFormat = NumberFormat.compactCurrency(
      locale: l10n.localeName,
      name: currencyCode,
    );

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: SizedBox(
        height: 250,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Cash Flow Timeline',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 5 == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            currencyFormat.format(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data.incomeSpots,
                      color: Colors.green.shade500,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      isCurved: true,
                    ),
                    LineChartBarData(
                      spots: data.expenseSpots,
                      color: Colors.red.shade500,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      isCurved: true,
                    ),
                  ],
                  minX: data.minX,
                  maxX: data.maxX,
                  minY: 0,
                  maxY: data.maxY,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 2,
                        color: Colors.green.shade500,
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.income),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 2,
                        color: Colors.red.shade500,
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.expense),
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

class _IncomeExpenseBarChart extends StatelessWidget {
  final double income;
  final double expense;
  final String currencyCode;

  const _IncomeExpenseBarChart({
    required this.income,
    required this.expense,
    required this.currencyCode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      decimalDigits: 2,
      name: currencyCode,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final total = income + expense;
        final incomeWidth = (total > 0) ? (income / total) * maxWidth : 0.0;
        final expenseWidth = (total > 0) ? (expense / total) * maxWidth : 0.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBarRow(
              context,
              'Income',
              income,
              incomeWidth,
              Colors.green,
              currencyFormat,
            ),
            const SizedBox(height: 12),
            _buildBarRow(
              context,
              'Expense',
              expense,
              expenseWidth,
              Colors.red,
              currencyFormat,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBarRow(
    BuildContext context,
    String label,
    double amount,
    double barWidth,
    Color color,
    NumberFormat currencyFormat,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              currencyFormat.format(amount),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 8,
          width: barWidth,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// Filtered Transactions Page
enum SortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
  nameAsc,
  nameDesc,
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
  late List<dynamic> _results;
  SortOption _currentSortOption = SortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    _loadAndSortResults();
  }

  void _loadAndSortResults() {
    final expenditureViewModel =
        Provider.of<ExpenditureViewModel>(context, listen: false);
    final allResults = expenditureViewModel
        .expenditures
        .where((exp) {
          final expDate = exp.date;
          return expDate.isAfter(widget.dateRange.start.subtract(const Duration(days: 1))) &&
              expDate.isBefore(widget.dateRange.end.add(const Duration(days: 1))) &&
              exp.mainTagId == widget.tag.id &&
              exp.isIncome == widget.showIncomeOnly;
        })
        .toList();

    setState(() {
      _results = allResults;
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
          (a, b) => a.articleName.toLowerCase().compareTo(
                b.articleName.toLowerCase(),
              ),
        );
        break;
      case SortOption.nameDesc:
        _results.sort(
          (a, b) => b.articleName.toLowerCase().compareTo(
                a.articleName.toLowerCase(),
              ),
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
    final settingsViewModel =
        Provider.of<SettingsViewModel>(context, listen: false);
    final currencyCode = settingsViewModel.settings.primaryCurrencyCode;

    final double appBarHeight = kToolbarHeight + 36.0;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalTopOffset = appBarHeight + statusBarHeight;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 24.0),
          child: RepaintBoundary(
            child: AppBar(
              title: Text(widget.tag.name),
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
                PopupMenuButton<SortOption>(
                  icon: const Icon(Icons.sort),
                  tooltip: l10n.sortBy,
                  onSelected: (SortOption result) {
                    setState(() {
                      _currentSortOption = result;
                      _sortResults();
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SortOption>>[
                        PopupMenuItem<SortOption>(
                          value: SortOption.dateDesc,
                          child: Text(l10n.dateNewestFirst),
                        ),
                        PopupMenuItem<SortOption>(
                          value: SortOption.dateAsc,
                          child: const Text('Date (Oldest first)'),
                        ),
                        PopupMenuItem<SortOption>(
                          value: SortOption.amountDesc,
                          child: const Text('Amount (Highest first)'),
                        ),
                        PopupMenuItem<SortOption>(
                          value: SortOption.amountAsc,
                          child: const Text('Amount (Lowest first)'),
                        ),
                        PopupMenuItem<SortOption>(
                          value: SortOption.nameAsc,
                          child: const Text('Name (A-Z)'),
                        ),
                        PopupMenuItem<SortOption>(
                          value: SortOption.nameDesc,
                          child: const Text('Name (Z-A)'),
                        ),
                      ],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(24.0),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    '${DateFormat.yMMMd(l10n.localeName).format(widget.dateRange.start)} - ${DateFormat.yMMMd(l10n.localeName).format(widget.dateRange.end)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
                padding: EdgeInsets.fromLTRB(8, totalTopOffset + 8, 8, 8),
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
                          DateFormat.yMMMd(
                            l10n.localeName,
                          ).format(expenditure.date),
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
