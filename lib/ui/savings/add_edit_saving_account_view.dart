import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/saving_account.dart';
import '../../l10n/app_localizations.dart';
import '../helpers/currency_input_formatter.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/section_header.dart';
import '../settings/settings_view_model.dart';
import 'saving_account_view_model.dart';

class AddEditSavingAccountAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final bool isEditing;
  final VoidCallback? onDeletePressed;

  const AddEditSavingAccountAppBar({
    super.key,
    required this.l10n,
    required this.isEditing,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GradientTitle(
        text: isEditing ? l10n.editSavingAccount : l10n.addSavingAccount,
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
      ),
      actions: [
        if (isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDeletePressed,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AddEditSavingAccountView extends StatefulWidget {
  final SavingAccount? account;

  const AddEditSavingAccountView({super.key, this.account});

  @override
  State<AddEditSavingAccountView> createState() => _AddEditSavingAccountViewState();
}

class _AddEditSavingAccountViewState extends State<AddEditSavingAccountView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late TextEditingController _interestController;
  late TextEditingController _notesController;

  late DateTime _startDate;
  DateTime? _endDate;

  bool get isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    final formatter = NumberFormat('#,##0.00');

    _nameController = TextEditingController(text: account?.name ?? '');
    _balanceController = TextEditingController(
      text: account != null ? formatter.format(account.balance) : '0.00',
    );
    _interestController = TextEditingController(
      text: account?.annualInterestRate?.toString() ?? '',
    );
    _notesController = TextEditingController(text: account?.notes ?? '');
    _startDate = account?.startDate ?? DateTime.now();
    _endDate = account?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _interestController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart, AppLocalizations l10n) async {
    final initial = isStart ? _startDate : (_endDate ?? DateTime.now());
    final first = isStart ? DateTime(2000) : _startDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2100),
      helpText: l10n.selectDate,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveForm() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<SavingAccountViewModel>();
    final currencyCode = context.read<SettingsViewModel>().settings.primaryCurrencyCode;

    final balance = DecimalCurrencyInputFormatter.parse(
      _balanceController.text,
      currencyCode: currencyCode,
    );
    final interestRate = double.tryParse(_interestController.text);

    if (isEditing) {
      final account = widget.account!;
      account.name = _nameController.text;
      account.balance = balance;
      account.notes = _notesController.text;
      account.startDate = _startDate;
      account.endDate = _endDate;
      account.annualInterestRate = interestRate;
      await vm.updateSavingAccount(account);
    } else {
      await vm.createSavingAccount(
        name: _nameController.text,
        balance: balance,
        notes: _notesController.text,
        startDate: _startDate,
        endDate: _endDate,
        annualInterestRate: interestRate,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appBar = AddEditSavingAccountAppBar(
      l10n: l10n,
      isEditing: isEditing,
      onDeletePressed: () async {
        final navigator = Navigator.of(context);
        final vm = context.read<SavingAccountViewModel>();
        await vm.deleteSavingAccount(widget.account!.id);
        if (mounted) navigator.pop();
      },
    );
    final totalTopOffset = appBar.preferredSize.height + MediaQuery.of(context).padding.top;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, totalTopOffset + 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMainInfoCard(l10n),
                    const SizedBox(height: 24),
                    _buildDetailsCard(l10n),
                  ]),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saveForm,
          label: Text(isEditing ? l10n.update : l10n.save),
          icon: const Icon(Icons.check),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildMainInfoCard(AppLocalizations l10n) {
    final settings = context.read<SettingsViewModel>().settings;
    final currencySymbol = NumberFormat.simpleCurrency(
      name: settings.primaryCurrencyCode,
    ).currencySymbol;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.accountName,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) => v == null || v.isEmpty ? l10n.nameInput : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _balanceController,
            decoration: InputDecoration(
              labelText: l10n.currentBalance,
              prefixText: '$currencySymbol ',
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalCurrencyInputFormatter(
                locale: l10n.localeName,
                currencyCode: settings.primaryCurrencyCode,
              ),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.validNumber;
              final parsed = DecimalCurrencyInputFormatter.parse(
                v,
                currencyCode: settings.primaryCurrencyCode,
              );
              if (parsed < 0) {
                return l10n.validNumber;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(AppLocalizations l10n) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SectionHeader(title: l10n.optionalDetails),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _interestController,
                  decoration: InputDecoration(
                    labelText: l10n.annualInterestRate,
                    suffixText: '%',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                ),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.openingDate),
                  subtitle: Text(DateFormat.yMMMd(l10n.localeName).format(_startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(true, l10n),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.closingDate),
                  subtitle: Text(
                    _endDate == null
                        ? l10n.stillActive
                        : DateFormat.yMMMd(l10n.localeName).format(_endDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(false, l10n),
                ),
                if (_endDate != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _endDate = null),
                      child: Text(
                        l10n.clearClosingDate,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.notesOptional,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
