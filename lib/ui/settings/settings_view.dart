
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/settings.dart';
import '../../l10n/app_localizations.dart';
import '../export/export_transactions_view.dart';
import '../helpers/currency_picker_sheet.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/section_header.dart';
import '../tags/manage_tags_page.dart';
import 'backup_restore_page.dart';
import 'settings_view_model.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppLocalizations l10n;

  const SettingsAppBar({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GradientTitle(text: l10n.settings),
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

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  void _showPrivacyModeInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.visibility_off_outlined),
            const SizedBox(width: 8),
            Text(l10n.privacyModeInfoTitle),
          ],
        ),
        content: Text(l10n.privacyModeInfoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.privacyModeGotIt),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, SettingsViewModel viewModel) {
    final controller = TextEditingController(text: viewModel.settings.geminiApiKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Paste your key here',
            helperText: 'Used for AI-powered features',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.updateGeminiApiKey(controller.text);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showExchangeRateApiKeyDialog(BuildContext context, SettingsViewModel viewModel) {
    final controller = TextEditingController(text: viewModel.settings.exchangeRateApiKey);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exchange Rate API Key'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Paste your key here',
            helperText: 'Used for real-time currency conversion',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.updateExchangeRateApiKey(controller.text);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  void _showUserContextDialog(BuildContext context, SettingsViewModel viewModel) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: viewModel.settings.userContext);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.financialContextTitle),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(hintText: l10n.financialContextSubTitle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.updateUserContext(controller.text);
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAppLock(
    BuildContext context,
    SettingsViewModel viewModel,
    bool value,
  ) async {
    if (value) {
      final auth = LocalAuthentication();
      final canAuthenticate =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your device does not support passcode or biometrics.'),
            ),
          );
        }
        return;
      }

      bool didAuthenticate = false;
      try {
        didAuthenticate = await auth.authenticate(
          localizedReason: 'Authenticate to enable App Lock',
          authMessages: const <AuthMessages>[
            AndroidAuthMessages(
              signInTitle: 'Enable App Lock',
              cancelButton: 'Cancel',
            ),
            IOSAuthMessages(cancelButton: 'Cancel'),
          ],
          biometricOnly: false,
        );
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to authenticate.')),
          );
        }
        return;
      }

      if (didAuthenticate) {
        await viewModel.toggleAppLock(true);
      }
    } else {
      await viewModel.toggleAppLock(false);
    }
  }

  Future<void> _updateLanguage(
    BuildContext context,
    SettingsViewModel viewModel,
    String? languageCode,
  ) async {
    final settings = viewModel.settings;
    await viewModel.saveSettings(
      settings.copyWith(
        languageCode: languageCode,
        clearLanguageCode: languageCode == null,
      ),
    );
  }

  Future<void> _updateDividerType(
    SettingsViewModel viewModel,
    DividerType type,
  ) async {
    final settings = viewModel.settings;
    await viewModel.saveSettings(settings.copyWith(dividerType: type));
  }

  Future<void> _updatePaydayStartDay(
    SettingsViewModel viewModel,
    int day,
  ) async {
    final settings = viewModel.settings;
    await viewModel.saveSettings(settings.copyWith(paydayStartDay: day));
  }

  Future<void> _updateFixedIntervalDays(
    SettingsViewModel viewModel,
    int days,
  ) async {
    final settings = viewModel.settings;
    await viewModel.saveSettings(settings.copyWith(fixedIntervalDays: days));
  }

  Future<void> _updatePaginationLimit(
    SettingsViewModel viewModel,
    int value,
  ) async {
    final settings = viewModel.settings;
    await viewModel.saveSettings(settings.copyWith(paginationLimit: value));
  }

  Future<void> _updateReminders(
    SettingsViewModel viewModel,
    bool value,
  ) async {
    final settings = viewModel.settings;
    await viewModel.saveSettings(settings.copyWith(remindersEnabled: value));
  }

  Future<void> _onCurrencyChanged(
    BuildContext context,
    SettingsViewModel viewModel,
    AppLocalizations l10n,
    String newCode,
  ) async {
    final oldCode = viewModel.settings.primaryCurrencyCode;
    if (oldCode == newCode) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeCurrency),
        content: Text(l10n.confirmCurrencyConversion(oldCode, newCode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.proceed),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      final rate = await viewModel.getExchangeRate(oldCode, newCode);

      if (context.mounted) Navigator.pop(context); // Pop loading

      if (rate != null) {
        await viewModel.convertAllData(rate, newCode);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.exchangeRateError)),
          );
        }
      }
    }
  }

  void _showAddCustomRateDialog(
    BuildContext context,
    SettingsViewModel viewModel,
    AppLocalizations l10n,
  ) {
    String fromCurrency = 'USD';
    String toCurrency = 'VND';
    final rateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.addCustomRate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: fromCurrency,
                      isExpanded: true,
                      items: _supportedCurrencies
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => fromCurrency = val);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: toCurrency,
                      isExpanded: true,
                      items: _supportedCurrencies
                          .map(
                            (code) => DropdownMenuItem(
                              value: code,
                              child: Text(code),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => toCurrency = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: rateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.exchangeRate,
                  hintText: 'e.g. 25000',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final rate = double.tryParse(rateController.text);
                if (rate != null && fromCurrency != toCurrency) {
                  viewModel.addOrUpdateCustomRate(fromCurrency, toCurrency, rate);
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _supportedCurrencies = [
    'VND',
    'USD',
    'EUR',
    'JPY',
    'GBP',
    'CNY',
    'AUD',
    'CAD',
    'CHF',
    'HKD',
    'SGD',
    'INR',
    'KRW',
    'THB',
    'PHP',
    'MYR',
    'BRL',
    'ZAR',
    'RUB',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAppBar = SettingsAppBar(l10n: l10n);
    final appBarHeight = settingsAppBar.preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final totalTopOffset = appBarHeight + statusBarHeight;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 90;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: settingsAppBar,
        body: Consumer<SettingsViewModel>(
          builder: (context, viewModel, child) {
            final settings = viewModel.settings;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(8, totalTopOffset + 15, 8, bottomPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      GlassCardContainer(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: l10n.general),
                            _buildLanguageSetting(context, viewModel, l10n),
                            ListTile(
                              leading: const Icon(Icons.person_pin_outlined),
                              title: Text(l10n.financialContextTitle),
                              subtitle: Text(l10n.financialContextSubTitle),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _showUserContextDialog(context, viewModel),
                            ),
                            ListTile(
                              leading: const Icon(Icons.category),
                              title: Text(l10n.tags),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ManageTagsPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      GlassCardContainer(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: l10n.reminders),
                            SwitchListTile(
                              secondary: Icon(
                                settings.remindersEnabled
                                    ? Icons.notifications_active
                                    : Icons.notifications_off_outlined,
                              ),
                              title: Text(l10n.enableReminders),
                              subtitle: Text(l10n.enableRemindersSubtitle),
                              value: settings.remindersEnabled,
                              onChanged: (value) => _updateReminders(viewModel, value),
                            ),
                          ],
                        ),
                      ),
                      GlassCardContainer(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: l10n.currency),
                            ListTile(
                              leading: const Icon(Icons.money),
                              title: Text(l10n.primaryCurrency),
                              subtitle: Text(
                                l10n.currencyName(settings.primaryCurrencyCode),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                final selectedCurrency =
                                    await showModalBottomSheet<String>(
                                  context: context,
                                  builder: (_) => CurrencyPickerSheet(
                                    supportedCurrencies: _supportedCurrencies,
                                    title: l10n.selectCurrency,
                                  ),
                                );
                                if (selectedCurrency != null && context.mounted) {
                                  await _onCurrencyChanged(
                                    context,
                                    viewModel,
                                    l10n,
                                    selectedCurrency,
                                  );
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.swap_horiz),
                              title: Text(l10n.customExchangeRates),
                              trailing: const Icon(Icons.add),
                              onTap: () => _showAddCustomRateDialog(
                                context,
                                viewModel,
                                l10n,
                              ),
                            ),
                            ...viewModel.customRates.map(
                              (rate) => ListTile(
                                dense: true,
                                title: Text(
                                  rate.conversionPair.replaceAll('_', ' → '),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      rate.rate.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                      onPressed: () => viewModel.deleteCustomRate(
                                        rate.conversionPair,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GlassCardContainer(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: l10n.security),
                            ListTile(
                              leading: Icon(
                                settings.privacyModeEnabled
                                    ? Icons.visibility_off
                                    : Icons.visibility_outlined,
                                color: settings.privacyModeEnabled
                                    ? Colors.amber.shade700
                                    : null,
                              ),
                              title: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(l10n.privacyMode),
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () => _showPrivacyModeInfo(context),
                                    child: const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                settings.privacyModeEnabled ? l10n.privacyModeOn : l10n.privacyModeOff,
                              ),
                              trailing: Switch(
                                value: settings.privacyModeEnabled,
                                onChanged: (value) =>
                                    viewModel.togglePrivacyMode(value),
                                activeColor: Colors.amber.shade700,
                              ),
                            ),
                            SwitchListTile(
                              secondary: const Icon(Icons.lock),
                              title: Text(l10n.pinLock),
                              subtitle: Text(
                                viewModel.isAppLockEnabled
                                    ? l10n.pinIsEnabled
                                    : l10n.pinIsDisabled,
                              ),
                              value: viewModel.isAppLockEnabled,
                              onChanged: (value) => _toggleAppLock(context, viewModel, value),
                            ),
                            ListTile(
                              leading: const Icon(Icons.auto_awesome),
                              title: const Text('Gemini API Key'),
                              subtitle: Text(
                                settings.geminiApiKey != null &&
                                        settings.geminiApiKey!.isNotEmpty
                                    ? 'Saved'
                                    : 'Unset',
                              ),
                              trailing: const Icon(Icons.edit),
                              onTap: () => _showApiKeyDialog(context, viewModel),
                            ),
                            ListTile(
                              leading: const Icon(Icons.currency_exchange),
                              title: const Text('Exchange Rate API Key'),
                              subtitle: Text(
                                settings.exchangeRateApiKey != null &&
                                        settings.exchangeRateApiKey!.isNotEmpty
                                    ? 'Saved'
                                    : 'Unset',
                              ),
                              trailing: const Icon(Icons.edit),
                              onTap: () => _showExchangeRateApiKeyDialog(context, viewModel),
                            ),
                          ],
                        ),
                      ),
                      GlassCardContainer(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: l10n.display),
                            _buildListGroupingSetting(context, viewModel, l10n),
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
                                    _updatePaginationLimit(viewModel, value);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      GlassCardContainer(
                        padding: EdgeInsets.zero,
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(title: l10n.dataManagement),
                            ListTile(
                              leading: const Icon(Icons.backup),
                              title: Text(l10n.backup),
                              subtitle: Text(l10n.backupDescription),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BackupRestorePage(),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.upload_file),
                              title: Text(l10n.exportData),
                              subtitle: Text(l10n.exportDataSubtitle),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ExportTransactionsView(),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.download_for_offline),
                              title: Text(l10n.importData),
                              subtitle: Text(l10n.importDataSubtitle),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const BackupRestorePage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: Theme.of(context)
                            .colorScheme
                            .errorContainer
                            .withValues(alpha: 0.5),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.resetConfirmation),
                              content: Text(l10n.resetWarningMessage),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text(l10n.cancel),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Theme.of(context).colorScheme.error,
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Reset action is not configured in this build.',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.resetAndStartOver),
                                ),
                              ],
                            ),
                          );
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: Icon(
                            Icons.warning_amber_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            l10n.resetAllData,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            l10n.resetApp,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
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
    BuildContext context,
    SettingsViewModel viewModel,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: Text(
        viewModel.settings.languageCode == null
            ? l10n.systemDefault
            : l10n.languageName(viewModel.settings.languageCode!),
      ),
      onTap: () => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.language),
          content: RadioGroup<String?>(
            groupValue: viewModel.settings.languageCode,
            onChanged: (val) async {
              await _updateLanguage(context, viewModel, val);
              if (ctx.mounted) Navigator.of(ctx).pop();
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
  }

  Widget _buildListGroupingSetting(
    BuildContext context,
    SettingsViewModel viewModel,
    AppLocalizations l10n,
  ) {
    final settings = viewModel.settings;

    return RadioGroup<DividerType>(
      groupValue: settings.dividerType,
      onChanged: (value) {
        if (value == null) return;
        if (value == DividerType.fixedInterval && settings.fixedIntervalDays <= 0) {
          _updateFixedIntervalDays(viewModel, 7);
        }
        _updateDividerType(viewModel, value);
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
          if (settings.dividerType == DividerType.paydayCycle)
            Padding(
              padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
              child: DropdownButtonFormField<int>(
                initialValue: settings.paydayStartDay,
                decoration: InputDecoration(labelText: l10n.cycleStartDate),
                items: List.generate(28, (i) => i + 1)
                    .map(
                      (day) => DropdownMenuItem(
                        value: day,
                        child: Text(l10n.dayOfMonthLabel(day)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _updatePaydayStartDay(viewModel, value);
                  }
                },
              ),
            ),
          RadioListTile<DividerType>(
            title: Text(l10n.fixedInterval),
            subtitle: Text(l10n.msgFixedInterval),
            value: DividerType.fixedInterval,
          ),
          if (settings.dividerType == DividerType.fixedInterval)
            _FixedIntervalSettings(
              settings: settings,
              onChanged: (days) => _updateFixedIntervalDays(viewModel, days),
            ),
        ],
      ),
    );
  }
}

class _FixedIntervalSettings extends StatefulWidget {
  final Settings settings;
  final ValueChanged<int> onChanged;

  const _FixedIntervalSettings({required this.settings, required this.onChanged});

  @override
  State<_FixedIntervalSettings> createState() => _FixedIntervalSettingsState();
}

class _FixedIntervalSettingsState extends State<_FixedIntervalSettings> {
  static const int customIntervalValue = 0;
  final List<int> presetIntervals = [7, 14, 15, 30];
  late int selectedValue;
  late TextEditingController customDaysController;

  bool _isCustom(int value) => !presetIntervals.contains(value);

  @override
  void initState() {
    super.initState();
    final current = widget.settings.fixedIntervalDays;
    selectedValue = presetIntervals.contains(current) ? current : customIntervalValue;
    customDaysController = TextEditingController(
      text: _isCustom(current) ? current.toString() : '',
    );
  }

  @override
  void dispose() {
    customDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showCustomField = selectedValue == customIntervalValue;

    return Padding(
      padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
      child: Column(
        children: [
          DropdownButtonFormField<int>(
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
                setState(() => selectedValue = value);
                if (value != customIntervalValue) {
                  widget.onChanged(value);
                }
              }
            },
          ),
          if (showCustomField)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                controller: customDaysController,
                decoration: InputDecoration(
                  labelText: l10n.customDays,
                  hintText: l10n.enterNumOfDays,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                onChanged: (value) {
                  final days = int.tryParse(value) ?? 0;
                  if (days > 0 && days <= 180) {
                    widget.onChanged(days);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
