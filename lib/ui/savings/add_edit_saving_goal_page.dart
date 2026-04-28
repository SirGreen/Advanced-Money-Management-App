
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/expenditure.dart';
import '../../domain/entities/saving_goal.dart';
import '../../l10n/app_localizations.dart';
import '../helpers/currency_input_formatter.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/section_header.dart';
import '../settings/settings_view_model.dart';
import '../transaction/expenditure_view_model.dart';
import 'saving_goal_view_model.dart';

class AddEditSavingGoalAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final AppLocalizations l10n;
  final bool isEditing;
  final VoidCallback? onDeletePressed;

  const AddEditSavingGoalAppBar({
    super.key,
    required this.l10n,
    required this.isEditing,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: GradientTitle(
        text: isEditing ? l10n.editSavingGoal : l10n.addSavingGoal,
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

class AddEditSavingGoalPage extends StatefulWidget {
  final SavingGoal? goal;

  const AddEditSavingGoalPage({super.key, this.goal});

  @override
  State<AddEditSavingGoalPage> createState() => _AddEditSavingGoalPageState();
}

class _AddEditSavingGoalPageState extends State<AddEditSavingGoalPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;

  final _contributionAmountController = TextEditingController();
  final _contributionNotesController = TextEditingController();

  late DateTime _startDate;
  DateTime? _endDate;

  bool get isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final goal = widget.goal;
    final formatter = NumberFormat('#,###');

    _nameController = TextEditingController(text: goal?.name ?? '');
    _notesController = TextEditingController(text: goal?.notes ?? '');
    _targetAmountController = TextEditingController(
      text: goal != null ? formatter.format(goal.targetAmount) : '',
    );
    _currentAmountController = TextEditingController(
      text: goal != null ? formatter.format(goal.currentAmount) : '0',
    );
    _startDate = goal?.startDate ?? DateTime.now();
    _endDate = goal?.endDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _contributionAmountController.dispose();
    _contributionNotesController.dispose();
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

  Future<void> _addContribution() async {
    final l10n = AppLocalizations.of(context)!;
    final settingsVm = context.read<SettingsViewModel>();
    final currencyCode = settingsVm.settings.primaryCurrencyCode;
    
    final amount = DecimalCurrencyInputFormatter.parse(
      _contributionAmountController.text,
      currencyCode: currencyCode,
    );

    if (amount <= 0 || widget.goal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validNumber)),
      );
      return;
    }

    final savingGoalVm = context.read<SavingGoalViewModel>();
    final expenditureVm = context.read<ExpenditureViewModel>();

    await savingGoalVm.addContribution(
      goalId: widget.goal!.id,
      amount: amount,
      note: _contributionNotesController.text.isNotEmpty
          ? _contributionNotesController.text
          : null,
    );

    String? mainTagId;
    for (final tag in expenditureVm.tags) {
      if (tag.id == 'savings_contribution' ||
          tag.name.toLowerCase().contains('saving')) {
        mainTagId = tag.id;
        break;
      }
    }
    mainTagId ??= expenditureVm.tags.isNotEmpty ? expenditureVm.tags.first.id : null;

    if (mainTagId != null) {
      await expenditureVm.addExpenditure(
        Expenditure(
          id: const Uuid().v4(),
          articleName: '${widget.goal!.name} (${l10n.contribution})',
          amount: amount,
          date: DateTime.now(),
          mainTagId: mainTagId,
          isIncome: false,
          currencyCode: settingsVm.settings.primaryCurrencyCode,
          notes: _contributionNotesController.text.isNotEmpty
              ? _contributionNotesController.text
              : null,
        ),
      );
    }

    final refreshedGoal = savingGoalVm.getGoalById(widget.goal!.id);
    if (refreshedGoal != null) {
      _currentAmountController.text = NumberFormat('#,###').format(refreshedGoal.currentAmount);
    }

    _contributionAmountController.clear();
    _contributionNotesController.clear();
    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.contributionAdded)),
      );
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<SavingGoalViewModel>();
    final currencyCode = context.read<SettingsViewModel>().settings.primaryCurrencyCode;

    final targetAmount = DecimalCurrencyInputFormatter.parse(
      _targetAmountController.text,
      currencyCode: currencyCode,
    );
    final currentAmount = DecimalCurrencyInputFormatter.parse(
      _currentAmountController.text,
      currencyCode: currencyCode,
    );

    if (isEditing) {
      final goal = widget.goal!;
      goal.name = _nameController.text;
      goal.notes = _notesController.text;
      goal.targetAmount = targetAmount;
      goal.currentAmount = currentAmount;
      goal.startDate = _startDate;
      goal.endDate = _endDate;
      await vm.updateSavingGoal(goal);
    } else {
      await vm.createSavingGoal(
        name: _nameController.text,
        notes: _notesController.text,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        endDate: _endDate,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appBar = AddEditSavingGoalAppBar(
      l10n: l10n,
      isEditing: isEditing,
      onDeletePressed: () async {
        final navigator = Navigator.of(context);
        final vm = context.read<SavingGoalViewModel>();
        await vm.deleteSavingGoal(widget.goal!.id);
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
                    if (isEditing) ...[
                      const SizedBox(height: 24),
                      _buildContributionCard(l10n),
                    ],
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
    final currencyCode = context.read<SettingsViewModel>().settings.primaryCurrencyCode;
    final currencySymbol = NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.goalName,
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
            controller: _targetAmountController,
            decoration: InputDecoration(
              labelText: l10n.targetAmount,
              prefixText: currencySymbol,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              DecimalCurrencyInputFormatter(
                locale: l10n.localeName,
                currencyCode: currencyCode,
              ),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.validNumber;
              final parsed = DecimalCurrencyInputFormatter.parse(
                v,
                currencyCode: currencyCode,
              );
              if (parsed <= 0) {
                return l10n.validNumber;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _currentAmountController,
            decoration: InputDecoration(
              labelText: l10n.currentAmount,
              prefixText: currencySymbol,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              DecimalCurrencyInputFormatter(
                locale: l10n.localeName,
                currencyCode: currencyCode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContributionCard(AppLocalizations l10n) {
    final currencyCode = context.read<SettingsViewModel>().settings.primaryCurrencyCode;
    final currencySymbol = NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          SectionHeader(title: l10n.addContribution),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  controller: _contributionAmountController,
                  decoration: InputDecoration(
                    labelText: l10n.contributionAmount,
                    prefixText: currencySymbol,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    DecimalCurrencyInputFormatter(
                      locale: l10n.localeName,
                      currencyCode: currencyCode,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contributionNotesController,
                  decoration: InputDecoration(
                    labelText: l10n.notesOptional,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_card),
                    label: Text(l10n.saveAsTransaction),
                    onPressed: _addContribution,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.startDate),
                  subtitle: Text(DateFormat.yMMMd(l10n.localeName).format(_startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(true, l10n),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.endDateOptional),
                  subtitle: Text(
                    _endDate == null
                        ? l10n.noEndDate
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
                      child: Text(l10n.clearEndDate),
                    ),
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.notesOptional,
                    hintText: l10n.notesHint,
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
