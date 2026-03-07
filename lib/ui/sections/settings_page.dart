import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import ../../ui/controllers/expenditure_controller.dart';
import ../../ui/controllers/settings_controller.dart';
import ../../data/models/settings.dart';
import ../../ui/views/helpers/glass_card.dart';
import ../../ui/views/helpers/gradient_background.dart';
import ../../ui/views/helpers/gradient_title.dart';
import ../../ui/views/helpers/section_header.dart';
import ../../l10n/app_localizations.dart';

// REMOVED //updatePrimaryCurrency no longer takes AssetsController


class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;

  const SettingsAppBar({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          title: GradientTitle(text: l10n.settings),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _onCurrencyChanged(
    BuildContext context,
    String newCode,
    String oldCode,
    SettingsController settingsController,
    ExpenditureController expenditureController,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.changeCurrency),
        content: Text(l10n.confirmCurrencyConversion(oldCode, newCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            child: Text(l10n.proceed),
            onPressed: () async {
              Navigator.of(ctx).pop();
              _showLoadingDialog();
              try {
                await settingsController.updatePrimaryCurrency(
                  expenditureController,
                  newCode,
                  (from, to) =>
                      expenditureController.getBestExchangeRate(from, to),
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
              } catch (e) {
                if (!context.mounted) return;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.exchangeRateError)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  IconData _getCurrencyIcon(String currencyCode) {
    switch (currencyCode) {
      case 'JPY':
        return Icons.currency_yen;
      case 'USD':
        return Icons.attach_money;
      case 'EUR':
        return Icons.euro_symbol;
      case 'GBP':
        return Icons.currency_pound;
      case 'CNY':
        return Icons.currency_yuan;
      case 'RUB':
        return Icons.currency_ruble;
      case 'INR':
        return Icons.currency_rupee;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAppBar = SettingsAppBar(l10n: l10n);
    final double appBarHeight = settingsAppBar.preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalTopOffset = appBarHeight + statusBarHeight;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: settingsAppBar,
        body: Consumer<SettingsController>(
          builder: (context, controller, child) {
            final settings = controller.settings;
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding:
                      EdgeInsets.fromLTRB(8, totalTopOffset + 15, 8, 90),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ── General ────────────────────────────────────
                      GlassCardContainer(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: l10n.general),
                            _buildLanguageSetting(controller, l10n),
                          ],
                        ),
                      ),
                      // ── Currency ───────────────────────────────────
                      GlassCardContainer(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: l10n.currency),
                            _buildCurrencySetting(controller, l10n),
                          ],
                        ),
                      ),
                      // ── Display ────────────────────────────────────
                      GlassCardContainer(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: l10n.display),
                            _buildListGroupingSetting(controller, l10n),
                            ListTile(
                              leading: const Icon(Icons.list_alt),
                              title: Text(l10n.paginationLimit),
                              trailing: DropdownButton<int>(
                                value: settings.paginationLimit,
                                items: [25, 50, 100, 200]
                                    .map(
                                      (limit) => DropdownMenuItem(
                                        value: limit,
                                        child: Text('$limit'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    controller.updatePaginationLimit(value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildLanguageSetting(
    SettingsController controller,
    AppLocalizations l10n,
  ) =>
      ListTile(
        leading: const Icon(Icons.language),
        title: Text(l10n.language),
        subtitle: Text(
          controller.settings.languageCode == null
              ? l10n.systemDefault
              : l10n.languageName(controller.settings.languageCode!),
        ),
        onTap: () => showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.language),
            content: RadioGroup<String?>(
              groupValue: controller.settings.languageCode,
              onChanged: (val) {
                controller.updateLanguage(val);
                Navigator.of(ctx).pop();
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String?>(
                    title: Text(l10n.systemDefault),
                    value: null,
                  ),
                  ...AppLocalizations.supportedLocales.map(
                    (locale) => RadioListTile<String?>(
                      title: Text(l10n.languageName(locale.languageCode)),
                      value: locale.languageCode,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildCurrencySetting(
    SettingsController controller,
    AppLocalizations l10n,
  ) {
    const supportedCurrencies = [
      'JPY', 'USD', 'EUR', 'CNY', 'RUB', 'VND', 'AUD', 'KRW', 'THB', 'PHP', 'MYR',
    ];
    final expenditureController =
        Provider.of<ExpenditureController>(context, listen: false);
    return ListTile(
      leading: Icon(_getCurrencyIcon(controller.settings.primaryCurrencyCode)),
      title: Text(l10n.primaryCurrency),
      subtitle: Text(
        l10n.currencyName(controller.settings.primaryCurrencyCode),
      ),
      onTap: () {
        final oldCode = controller.settings.primaryCurrencyCode;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.primaryCurrency),
            content: SizedBox(
              width: double.maxFinite,
              child: RadioGroup<String>(
                groupValue: oldCode,
                onChanged: (newCode) {
                  Navigator.of(ctx).pop();
                  if (newCode != null && newCode != oldCode) {
                    _onCurrencyChanged(
                      context,
                      newCode,
                      oldCode,
                      controller,
                      expenditureController,
                      l10n,
                    );
                  }
                },
                child: ListView(
                  shrinkWrap: true,
                  children: supportedCurrencies
                      .map(
                        (code) => RadioListTile<String>(
                          title: Text(l10n.currencyName(code)),
                          value: code,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListGroupingSetting(
    SettingsController controller,
    AppLocalizations l10n,
  ) =>
      RadioGroup<DividerType>(
        groupValue: controller.settings.dividerType,
        onChanged: (value) {
          if (value == null) return;
          if (value == DividerType.fixedInterval &&
              controller.settings.fixedIntervalDays <= 0) {
            controller.updateFixedIntervalDays(7);
          }
          controller.updateDividerType(value);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioListTile<DividerType>(
              title: Text(l10n.calendarMonth),
              subtitle: Text(l10n.msgCalendarMonth),
              value: DividerType.monthly,
            ),
            RadioListTile<DividerType>(
              title: Text(l10n.paydayCycle),
              subtitle: Text(l10n.msgPaydayCycle),
              value: DividerType.paydayCycle,
            ),
            if (controller.settings.dividerType == DividerType.paydayCycle)
              Padding(
                padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
                child: DropdownButtonFormField<int>(
                  key: ValueKey(controller.settings.paydayStartDay),
                  initialValue: controller.settings.paydayStartDay,
                  decoration:
                      InputDecoration(labelText: l10n.cycleStartDate),
                  items: List.generate(28, (i) => i + 1)
                      .map(
                        (day) => DropdownMenuItem(
                          value: day,
                          child: Text(l10n.dayOfMonthLabel(day)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      controller.updatePaydayStartDay(value!),
                ),
              ),
            RadioListTile<DividerType>(
              title: Text(l10n.fixedInterval),
              subtitle: Text(l10n.msgFixedInterval),
              value: DividerType.fixedInterval,
            ),
            if (controller.settings.dividerType == DividerType.fixedInterval)
              FixedIntervalSettings(controller: controller),
          ],
        ),
      );
}

class FixedIntervalSettings extends StatefulWidget {
  final SettingsController controller;

  const FixedIntervalSettings({super.key, required this.controller});

  @override
  State<FixedIntervalSettings> createState() => _FixedIntervalSettingsState();
}

class _FixedIntervalSettingsState extends State<FixedIntervalSettings> {
  static const int customIntervalValue = 0;
  final List<int> presetIntervals = [7, 14, 15, 30];
  late int selectedValue;
  late TextEditingController _customDaysController;

  @override
  void initState() {
    super.initState();
    final current = widget.controller.settings.fixedIntervalDays;
    selectedValue =
        presetIntervals.contains(current) ? current : customIntervalValue;
    _customDaysController = TextEditingController(
      text: isCustom(current) ? current.toString() : '',
    );
  }

  bool isCustom(int value) => !presetIntervals.contains(value);

  @override
  void didUpdateWidget(covariant FixedIntervalSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = widget.controller.settings.fixedIntervalDays;
    final newSelectedValue =
        presetIntervals.contains(current) ? current : customIntervalValue;
    if (selectedValue != newSelectedValue) {
      selectedValue = newSelectedValue;
    }
  }

  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool showCustomField = selectedValue == customIntervalValue;
    return Padding(
      padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            key: ValueKey(selectedValue),
            initialValue: selectedValue,
            decoration: InputDecoration(labelText: l10n.interval),
            items: [
              ...presetIntervals.map(
                (day) => DropdownMenuItem(
                  value: day,
                  child: Text(l10n.daysUnit(day)),
                ),
              ),
              DropdownMenuItem(
                value: customIntervalValue,
                child: Text(l10n.custom),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedValue = value;
                  if (value != customIntervalValue) {
                    widget.controller.updateFixedIntervalDays(value);
                  }
                });
              }
            },
          ),
          if (showCustomField)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: TextFormField(
                controller: _customDaysController,
                decoration: InputDecoration(
                  labelText: l10n.customDays,
                  hintText: l10n.enterNumOfDays,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  final int days = int.tryParse(value) ?? 0;
                  if (days > 0 && days <= 180) {
                    widget.controller.updateFixedIntervalDays(days);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}