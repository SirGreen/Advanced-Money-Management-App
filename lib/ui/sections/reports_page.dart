import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import ../../ui/controllers/expenditure_controller.dart';
import ../../ui/controllers/settings_controller.dart';
import ../../data/models/report_data.dart';
import ../../data/models/tag.dart';
import ../../ui/views/filtered_transactions_page.dart';
import ../../ui/views/helpers/glass_card.dart';
import ../../ui/views/helpers/gradient_background.dart';
import ../../ui/views/helpers/gradient_title.dart';
import ../../ui/views/helpers/section_header.dart';
import ../ui/views/helpers/tag_icon.dart';
import ../../l10n/app_localizations.dart';

class ReportsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final VoidCallback onResetDate;
  final VoidCallback onSelectDate;

  const ReportsAppBar({
    super.key,
    required this.l10n,
    required this.onResetDate,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          title: GradientTitle(text: l10n.reports),
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
            IconButton(
              icon: const Icon(Icons.replay_outlined),
              tooltip: l10n.resetDate,
              onPressed: onResetDate,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);
    _dateRange =
        settingsController.reportDateRange ?? _calculateDefaultDateRange();
  }

  static DateTimeRange _calculateDefaultDateRange() {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = endDate.subtract(const Duration(days: 29));
    return DateTimeRange(start: startDate, end: endDate);
  }

  void _selectDateRange() async {
    final l10n = AppLocalizations.of(context)!;
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: l10n.selectDateRange,
      saveText: l10n.done,
      cancelText: l10n.cancel,
    );
    if (picked != null && picked != _dateRange) {
      settingsController.updateReportDateRange(picked);
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _resetDateRange() {
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);
    final defaultRange = _calculateDefaultDateRange();
    settingsController.updateReportDateRange(defaultRange);
    setState(() {
      _dateRange = defaultRange;
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
    final expenditureController =
        Provider.of<ExpenditureController>(context, listen: false);
    final settingsController =
        Provider.of<SettingsController>(context, listen: false);

    return BackGround(
      child: FutureBuilder<ReportData>(
        future: expenditureController.getReportData(_dateRange),
        builder: (context, snapshot) {
          final reportsAppBar = ReportsAppBar(
            l10n: l10n,
            onResetDate: _resetDateRange,
            onSelectDate: _selectDateRange,
          );

          final double appBarHeight = reportsAppBar.preferredSize.height;
          final double statusBarHeight = MediaQuery.of(context).padding.top;
          final double totalTopOffset = appBarHeight + statusBarHeight;

          return Scaffold(
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            appBar: reportsAppBar,
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: totalTopOffset)),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  )
                else if (!snapshot.hasData ||
                    (snapshot.data!.totalIncome == 0 &&
                        snapshot.data!.totalExpense == 0))
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(l10n.noDataForReport)),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Date range selector tile
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          onTap: _selectDateRange,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.dateRange),
                            subtitle: Text(
                              '${DateFormat.yMMMd(l10n.localeName).format(_dateRange.start)}'
                              ' - '
                              '${DateFormat.yMMMd(l10n.localeName).format(_dateRange.end)}',
                            ),
                            trailing: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildIncomeExpenseCard(
                          context,
                          l10n,
                          snapshot.data!,
                          settingsController.settings.primaryCurrencyCode,
                        ),
                        if (_dateRange.duration.inDays > 2 &&
                            snapshot.data!.lineChartData != null &&
                            (snapshot.data!.lineChartData!.incomeSpots
                                    .isNotEmpty ||
                                snapshot.data!.lineChartData!.expenseSpots
                                    .isNotEmpty)) ...[
                          const SizedBox(height: 24),
                          _buildTimeSeriesChart(
                            context,
                            snapshot.data!.lineChartData!,
                            settingsController.settings.primaryCurrencyCode,
                          ),
                        ],
                        if (snapshot.data!.expenseByTag.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildImprovedPieChart(
                            context,
                            l10n,
                            l10n.expenseBreakdown,
                            snapshot.data!.expenseByTag,
                            settingsController.settings.primaryCurrencyCode,
                            _dateRange,
                            isIncomeChart: false,
                          ),
                        ],
                        if (snapshot.data!.incomeByTag.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildImprovedPieChart(
                            context,
                            l10n,
                            l10n.incomeBreakdown,
                            snapshot.data!.incomeByTag,
                            settingsController.settings.primaryCurrencyCode,
                            _dateRange,
                            isIncomeChart: true,
                          ),
                        ],
                        const SizedBox(height: 80),
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
          const Divider(height: 32, thickness: 0.5),
          Text(
            l10n.netBalance,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(net),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color:
                      net >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovedPieChart(
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

    return GlassCard(
      padding: EdgeInsets.zero,
      child: StatefulBuilder(
        builder: (context, setState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: title),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildChartSummary(
                    context,
                    l10n,
                    touchedIndex,
                    mainEntries,
                    currencyCode,
                    totalValue,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: List.generate(mainEntries.length, (i) {
                          final isTouched = i == touchedIndex;
                          final radius = isTouched ? 60.0 : 50.0;
                          final entry = mainEntries[i];
                          final percentage = totalValue > 0
                              ? (entry.value.totalAmount / totalValue) * 100
                              : 0;
                          final String titleText =
                              percentage > 7
                                  ? '${percentage.toStringAsFixed(0)}%'
                                  : '';
                          return PieChartSectionData(
                            color: entry.key.color,
                            value: entry.value.totalAmount,
                            title: titleText,
                            radius: radius,
                            titleStyle: TextStyle(
                              fontSize: isTouched ? 16 : 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            borderSide: isTouched
                                ? BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.7),
                                    width: 4,
                                  )
                                : BorderSide.none,
                          );
                        }),
                        centerSpaceRadius: 65,
                        centerSpaceColor: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.5),
                        sectionsSpace: 3,
                        startDegreeOffset: -90,
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            if (event is! FlTapUpEvent) return;
                            setState(() {
                              final newIndex = pieTouchResponse
                                  ?.touchedSection?.touchedSectionIndex;
                              if (newIndex == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex =
                                  (touchedIndex == newIndex) ? -1 : newIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const Divider(height: 32, thickness: 0.5),
                  _buildLegend(
                    context,
                    l10n,
                    mainEntries,
                    dateRange,
                    touchedIndex,
                    isIncomeChart: isIncomeChart,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSummary(
    BuildContext context,
    AppLocalizations l10n,
    int touchedIndex,
    List<MapEntry<Tag, TagReportData>> entries,
    String currencyCode,
    double totalValue,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      decimalDigits: 2,
      name: currencyCode,
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axis: Axis.vertical,
          child: child,
        ),
      ),
      child: touchedIndex == -1
          ? Row(
              key: const ValueKey('total_summary'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      l10n.total,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(totalValue),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            )
          : Container(
              key: ValueKey(entries[touchedIndex].key.id),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: entries[touchedIndex].key.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  TagIcon(tag: entries[touchedIndex].key, radius: 16),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entries[touchedIndex].key.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l10n.transactions(
                            entries[touchedIndex].value.transactionCount,
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(
                          entries[touchedIndex].value.totalAmount,
                        ),
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(entries[touchedIndex].value.totalAmount / totalValue * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLegend(
    BuildContext context,
    AppLocalizations l10n,
    List<MapEntry<Tag, TagReportData>> entries,
    DateTimeRange dateRange,
    int touchedIndex, {
    required bool isIncomeChart,
  }) {
    final currencyCode = Provider.of<SettingsController>(
      context,
      listen: false,
    ).settings.primaryCurrencyCode;
    final currencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      decimalDigits: 2,
      name: currencyCode,
    );
    return Column(
      children: List.generate(entries.length, (i) {
        final entry = entries[i];
        final isOtherCategory = entry.key.id == '__other__';
        final isTouched = i == touchedIndex;
        final transactionLabel =
            l10n.transactions(entry.value.transactionCount);
        return InkWell(
          onTap: isOtherCategory
              ? null
              : () => _navigateToFilteredList(
                    context,
                    entry.key,
                    dateRange,
                    isIncomeOnly: isIncomeChart,
                  ),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: isTouched
                  ? entry.key.color.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                TagIcon(tag: entry.key, radius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormat.format(entry.value.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transactionLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeSeriesChart(
    BuildContext context,
    LineChartReportData data,
    String currencyCode,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.compactCurrency(
      locale: l10n.localeName,
      name: currencyCode,
    );
    final tooltipCurrencyFormat = NumberFormat.currency(
      locale: l10n.localeName,
      name: currencyCode,
      decimalDigits: 2,
    );

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: SizedBox(
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: l10n.cashFlowTimeline),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: LineChart(
                  LineChartData(
                    maxY: data.maxY,
                    minX: data.minX,
                    maxX: data.maxX,
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final LineBarSpot barSpot = entry.value;
                            final amountTextStyle = TextStyle(
                              color: barSpot.barIndex == 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            );
                            final List<TextSpan> textSpans = [];
                            if (index == 0) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                barSpot.x.toInt(),
                              );
                              textSpans.add(
                                TextSpan(
                                  text:
                                      '${DateFormat.yMMMd(l10n.localeName).format(date)}\n',
                                  style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.9),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }
                            textSpans.add(
                              TextSpan(
                                text: tooltipCurrencyFormat.format(barSpot.y),
                                style: amountTextStyle,
                              ),
                            );
                            return LineTooltipItem(
                              '',
                              const TextStyle(),
                              children: textSpans,
                              textAlign: TextAlign.left,
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: (data.maxX > data.minX)
                              ? (data.maxX - data.minX) / 3
                              : 1,
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                              value.toInt(),
                            );
                            return SideTitleWidget(
                              meta: meta,
                              angle: -1,
                              space: 8.0,
                              child: Text(
                                DateFormat.MMMd(l10n.localeName).format(date),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          interval: data.maxY > 0 ? data.maxY / 4 : 1,
                          getTitlesWidget: (value, meta) {
                            if (value == meta.max || value == meta.min) {
                              return const SizedBox();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              space: 8.0,
                              child: Text(
                                currencyFormat.format(value),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: data.incomeSpots,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withValues(alpha: 0.2),
                        ),
                      ),
                      LineChartBarData(
                        spots: data.expenseSpots,
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.red.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
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
          children: [
            _buildBarRow(
              context,
              l10n.income,
              income,
              incomeWidth,
              Colors.green,
              currencyFormat,
            ),
            const SizedBox(height: 16),
            _buildBarRow(
              context,
              l10n.expense,
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
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              currencyFormat.format(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          height: 10,
          width: barWidth,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}

