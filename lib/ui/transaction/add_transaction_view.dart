import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../settings/settings_view_model.dart';
import 'expenditure_view_model.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/tag.dart';
import '../../l10n/app_localizations.dart';
import '../helpers/currency_input_formatter.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/tag_icon.dart';
import '../helpers/currency_picker_sheet.dart';

class AddTransactionView extends StatefulWidget {
  final Expenditure? expenditure;

  const AddTransactionView({super.key, this.expenditure});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  late TextEditingController _nameController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<String> _amountSuggestions = [];
  // State
  bool _isIncome = false;
  String? _selectedMainTagId;
  List<String> _selectedSubTagIds = [];
  DateTime _selectedDate = DateTime.now();
  bool _isShared = false;
  String? _receiptPath;
  String _selectedCurrency = 'VND';
  late bool isEditing;
  bool _isInitialized = false;

  // AI Tag recommendations
  List<Object> _recommendedTags = [];
  bool _isFetchingRecommendations = false;

  // Adjust total
  final TextEditingController _adjustAmountController = TextEditingController();
  bool _isAddingToTotal = true;

  @override
  void initState() {
    super.initState();
    isEditing = widget.expenditure != null;
    final e = widget.expenditure;
    _nameController = TextEditingController(text: e?.articleName ?? '');
    
    final settingsViewModel = Provider.of<SettingsViewModel>(context, listen: false);
    _selectedCurrency = e?.currencyCode ?? settingsViewModel.settings.primaryCurrencyCode;

    if (isEditing) {
      _notesController.text = e!.notes ?? '';
      _isIncome = e.isIncome;
      _selectedMainTagId = e.mainTagId;
      _selectedSubTagIds = List.from(e.subTagIds);
      _selectedDate = e.date;
      _receiptPath = e.receiptImagePath;
    }
    _amountController.addListener(_updateAmountSuggestions);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      if (isEditing && widget.expenditure != null) {
        final e = widget.expenditure!;

        if (e.amount == null) {
          _amountController.text = "0";
        } else {
          _amountController.text = NumberFormat.currency(
            locale: Localizations.localeOf(context).toString(),
            symbol: NumberFormat.simpleCurrency(name: e.currencyCode).currencySymbol,
            decimalDigits: e.currencyCode == 'JPY' || e.currencyCode == 'VND' ? 0 : 2,
          ).format(e.amount);
        }
      }
      _isInitialized = true;
    }
  }

  void _updateAmountSuggestions() {
    if (_selectedCurrency != 'VND' && _selectedCurrency != 'JPY') {
      if (_amountSuggestions.isNotEmpty) {
        setState(() => _amountSuggestions = []);
      }
      return;
    }
    final text = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = double.tryParse(text);
    if (amount == null || amount == 0) {
      if (_amountSuggestions.isNotEmpty) {
        setState(() => _amountSuggestions = []);
      }
      return;
    }
    if (amount > 1000000000) {
      if (_amountSuggestions.isNotEmpty) {
        setState(() => _amountSuggestions = []);
      }
      return;
    }
    final integerText = amount.toInt().toString();
    final newSuggestions = ['${integerText}000', '${integerText}0000'];
    if (newSuggestions.join(',') != _amountSuggestions.join(',')) {
      setState(() => _amountSuggestions = newSuggestions);
    }
  }

  double? _parseAmount(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;

    final rawValue = double.tryParse(digitsOnly) ?? 0;
    if (_selectedCurrency == 'JPY' || _selectedCurrency == 'VND') {
      return rawValue;
    } else {
      return rawValue / 100;
    }
  }

  void _applyAmountSuggestion(String suggestion) {
    final number = double.tryParse(suggestion);
    if (number != null) {
      final currencySymbol = NumberFormat.simpleCurrency(
      name: _selectedCurrency,
    ).currencySymbol;
    final formatted = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: currencySymbol,
      decimalDigits: _selectedCurrency == 'JPY' || _selectedCurrency == 'VND' ? 0 : 2,
    ).format(number);
    _amountController.text = formatted;
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    }
  }

  void _handleTagSelection(String tagId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (_selectedMainTagId == null) {
          _selectedMainTagId = tagId;
        } else if (!_selectedSubTagIds.contains(tagId) &&
            _selectedMainTagId != tagId) {
          _selectedSubTagIds.add(tagId);
        }
      } else {
        if (_selectedMainTagId == tagId) {
          _selectedMainTagId = _selectedSubTagIds.isNotEmpty
              ? _selectedSubTagIds.removeAt(0)
              : null;
        } else {
          _selectedSubTagIds.remove(tagId);
        }
      }
    });
  }

  Future<void> _pickReceiptImage() async {
    final l10n = AppLocalizations.of(context)!;
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePicture),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.selectFromGallery),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (image != null) {
        final savedPath = await _saveImageInternally(image);
        setState(() {
          _receiptPath = savedPath;
        });
      }
    }
  }

  Future<String> _saveImageInternally(XFile pickedImage) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName = p.basename(pickedImage.path);
    final String savedPath = p.join(directory.path, fileName);
    await File(pickedImage.path).copy(savedPath);
    return savedPath;
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateAmountSuggestions);
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _adjustAmountController.dispose();
    super.dispose();
  }

  // ---- AI Tag Recommendation ----
  Future<void> _getTagRecommendations() async {
    if (_nameController.text.length < 3) return;
    if (_isFetchingRecommendations) return;
    final viewModel = Provider.of<ExpenditureViewModel>(context, listen: false);
    setState(() {
      _isFetchingRecommendations = true;
      _recommendedTags = [];
    });
    final results = await viewModel.recommendTags(_nameController.text);
    if (mounted) {
      setState(() {
        _recommendedTags = results;
        _isFetchingRecommendations = false;
      });
    }
  }

  void _applyTagRecommendation(Object recommendation) {
    String? tagId;
    if (recommendation is Tag) {
      tagId = recommendation.id;
    }
    if (tagId == null) return;
    setState(() {
      _handleTagSelection(tagId!, true);
      _recommendedTags.remove(recommendation);
    });
  }

  // ---- Clear Tags ----
  void _clearAllTags() {
    setState(() {
      _selectedMainTagId = null;
      _selectedSubTagIds.clear();
    });
  }

  // ---- Adjust Total ----
  void _adjustTotalAmount() {
    final l10n = AppLocalizations.of(context)!;
    final currentAmount = _parseAmount(_amountController.text) ?? 0.0;
    final adjustAmount = _parseAmount(_adjustAmountController.text) ?? 0.0;

    if (adjustAmount <= 0) return;

    final double newTotal = _isAddingToTotal
        ? currentAmount + adjustAmount
        : currentAmount - adjustAmount;

    if (newTotal < 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.cannotBeNegative)));
      return;
    }

    final currencySymbol = NumberFormat.simpleCurrency(
      name: _selectedCurrency,
    ).currencySymbol;
    final formatted = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: currencySymbol,
      decimalDigits: _selectedCurrency == 'JPY' || _selectedCurrency == 'VND' ? 0 : 2,
    ).format(newTotal);
    setState(() {
      _amountController.text = formatted;
      _adjustAmountController.clear();
      _isAddingToTotal = true;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = Provider.of<ExpenditureViewModel>(context);
    final tags = viewModel.tags;

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = kToolbarHeight;
    final double totalTopOffset = appBarHeight + statusBarHeight;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildGlassAppBar(),
        body: Form(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, totalTopOffset + 16, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildAmountCard(),
                    const SizedBox(height: 16),
                    _buildAdjustTotalCard(),
                    const SizedBox(height: 24),
                    Center(child: _buildTypeSelector()),
                    const SizedBox(height: 24),
                    _buildTagSelector(tags),
                    const SizedBox(height: 24),
                    _buildDetailsSection(),
                    if (isEditing) ...[
                      const SizedBox(height: 16),
                      _buildTimestampsCard(),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: viewModel.isLoading ? null : () => _saveForm(viewModel),
          label: viewModel.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(isEditing ? l10n.update : l10n.save),
          icon: const Icon(Icons.check_rounded),
          backgroundColor: Colors.teal.shade600,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    final l10n = AppLocalizations.of(context)!;
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: AppBar(
          title: GradientTitle(
            text: isEditing ? l10n.editTransaction : l10n.addTransaction,
          ),
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
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: _deleteTransaction,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      color: _isIncome ? Colors.green.withValues(alpha: 0.7) : null,
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalCurrencyInputFormatter(
                locale: Localizations.localeOf(context).toString(),
                currencyCode: _selectedCurrency,
              ),
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixText: '${NumberFormat.simpleCurrency(name: _selectedCurrency).currencySymbol} ',
              hintText: '0',
              prefixStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.normal,
                color: Colors.grey.shade600,
              ),
            ),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: _isIncome
                  ? Colors.green.shade700
                  : Theme.of(context).colorScheme.onSurface,
            ),
            autofocus: !isEditing && _amountController.text.isEmpty,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final String? selected = await showModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) => CurrencyPickerSheet(
                      supportedCurrencies: currencyFlags.keys.toList(),
                      title: l10n.selectCurrency,
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedCurrency = selected;
                    });
                  }
                },
                icon: Text(
                  currencyFlags[_selectedCurrency] ?? '🏳️',
                  style: const TextStyle(fontSize: 18),
                ),
                label: Text(
                  _selectedCurrency,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          TextField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: _isIncome ? l10n.source : l10n.articleName,
              border: InputBorder.none,
              hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          if (_amountSuggestions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.center,
                children: _amountSuggestions.map((suggestion) {
                  final formatted = NumberFormat.decimalPattern(
                    'vi_VN',
                  ).format(double.parse(suggestion));
                  return ActionChip(
                    label: Text(formatted),
                    onPressed: () => _applyAmountSuggestion(suggestion),
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment<bool>(
          value: false,
          label: Text(l10n.expense),
          icon: Icon(Icons.arrow_downward_rounded),
        ),
        ButtonSegment<bool>(
          value: true,
          label: Text(l10n.income),
          icon: Icon(Icons.arrow_upward_rounded),
        ),
      ],
      selected: {_isIncome},
      onSelectionChanged: (newSelection) {
        setState(() => _isIncome = newSelection.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        selectedBackgroundColor: _isIncome
            ? Colors.green.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.5),
        selectedForegroundColor: _isIncome
            ? Colors.white
            : Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  Widget _buildTagSelector(List<Tag> tags) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tags,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (tags.isEmpty)
            const Center(child: CircularProgressIndicator())
          else
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: tags.map((tag) {
                final isMain = _selectedMainTagId == tag.id;
                final isSub = _selectedSubTagIds.contains(tag.id);
                final isSelected = isMain || isSub;

                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tag.name),
                      if (isMain) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Colors.amber.shade700,
                        ),
                      ],
                    ],
                  ),
                  avatar: TagIcon(tag: tag, radius: 10),
                  selected: isSelected,
                  onSelected: (selected) =>
                      _handleTagSelection(tag.id, selected),
                  selectedColor: Color(tag.colorValue).withValues(alpha: 0.7),
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: isSelected
                          ? Color(tag.colorValue).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),

          // Divider + action buttons
          const Divider(height: 24),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8.0,
            children: [
              if (_selectedMainTagId != null)
                TextButton.icon(
                  icon: const Icon(Icons.layers_clear_outlined, size: 18),
                  label: Text(l10n.clearTags),
                  onPressed: _clearAllTags,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade600,
                  ),
                ),
              TextButton.icon(
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: Text(l10n.suggestTags),
                onPressed: _isFetchingRecommendations
                    ? null
                    : _getTagRecommendations,
              ),
            ],
          ),

          // Loading bar for AI
          if (_isFetchingRecommendations)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: LinearProgressIndicator(),
            ),

          // AI Recommended Tag chips
          if (!_isFetchingRecommendations && _recommendedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.recommendations}:',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _recommendedTags.map((item) {
                      if (item is Tag) {
                        return ActionChip(
                          avatar: TagIcon(tag: item, radius: 10),
                          label: Text(item.name),
                          onPressed: () => _applyTagRecommendation(item),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---- Adjust Total Card ----
  Widget _buildAdjustTotalCard() {
    final l10n = AppLocalizations.of(context)!;
    final currencySymbol = NumberFormat.simpleCurrency(
      name: _selectedCurrency,
    ).currencySymbol;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: const Icon(Icons.add_shopping_cart_outlined),
        title: Text(l10n.adjustTotal),
        subtitle: Text(l10n.forgotToAddItem),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _adjustAmountController,
                        decoration: InputDecoration(
                          labelText: l10n.adjustmentAmount,
                          prefixText: '$currencySymbol ',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.5),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          DecimalCurrencyInputFormatter(
                            locale: Localizations.localeOf(context).toString(),
                            currencyCode: _selectedCurrency,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ToggleButtons(
                      isSelected: [_isAddingToTotal, !_isAddingToTotal],
                      onPressed: (index) {
                        setState(() => _isAddingToTotal = index == 0);
                      },
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Icon(Icons.add),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _adjustTotalAmount,
                    icon: Icon(
                      _isAddingToTotal
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                    ),
                    label: Text(
                      _isAddingToTotal ? l10n.addToTotal : l10n.removeFromTotal,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAddingToTotal
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                      foregroundColor: Colors.white,
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

  // ---- Timestamps Card (Edit mode) ----
  Widget _buildTimestampsCard() {
    final e = widget.expenditure!;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss', 'vi_VN');
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Created on: ${dateFormat.format(e.createdAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.edit_calendar_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                'Last updated: ${dateFormat.format(e.updatedAt)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(l10n.optionalDetails),
        leading: const Icon(Icons.notes_outlined),
        initiallyExpanded: _notesController.text.isNotEmpty,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.date,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Row(
                          children: [
                            Text(
                              DateFormat.yMMMEd('vi_VN').format(_selectedDate),
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.notes,
                    hintText: l10n.notesHint,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.5),
                  ),
                  maxLines: 3,
                  minLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Tự động thêm vào Tổng kết"),
                  subtitle: const Text(
                    "Đồng bộ giao dịch khi tính toán ngân sách",
                  ),
                  value: _isShared,
                  onChanged: (value) {
                    setState(() {
                      _isShared = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.receipt,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  color: Colors.black.withValues(alpha: 0.05),
                  child: InkWell(
                    onTap: _receiptPath == null
                        ? _pickReceiptImage
                        : () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                child: Image.file(File(_receiptPath!)),
                              ),
                            );
                          },
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: _receiptPath != null
                          ? BoxDecoration(
                              image: DecorationImage(
                                image: FileImage(File(_receiptPath!)),
                                fit: BoxFit.cover,
                              ),
                            )
                          : null,
                      child: _receiptPath == null
                          ? Center(
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.grey.shade600,
                                size: 40,
                              ),
                            )
                          : Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() {
                                    _receiptPath = null;
                                  }),
                                ),
                              ),
                            ),
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

  void _saveForm(ExpenditureViewModel viewModel) async {
    FocusScope.of(context).unfocus();
    final amount = _parseAmount(_amountController.text);

    final String finalArticleName = _nameController.text.isNotEmpty
        ? _nameController.text
        : 'Default - ${DateFormat.Hms('vi_VN').format(_selectedDate)}';

    // Fallback tag nếu chưa chọn: dùng tag đầu tiên trong danh sách
    final viewModelForTag = Provider.of<ExpenditureViewModel>(
      context,
      listen: false,
    );
    final fallbackTagId =
        _selectedMainTagId ??
        (viewModelForTag.tags.isNotEmpty
            ? viewModelForTag.tags.first.id
            : 'other');

    final expenditure = Expenditure(
      id: isEditing ? widget.expenditure!.id : const Uuid().v4(),
      articleName: finalArticleName,
      amount: amount,
      date: _selectedDate,
      mainTagId: fallbackTagId,
      subTagIds: _selectedSubTagIds,
      isIncome: _isIncome,
      currencyCode: _selectedCurrency,
      notes: _notesController.text,
      scheduledExpenditureId: isEditing
          ? widget.expenditure!.scheduledExpenditureId
          : null,
      receiptImagePath: _receiptPath,
    );

    if (isEditing) {
      await viewModel.updateExpenditure(expenditure);
    } else {
      await viewModel.addExpenditure(expenditure);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _deleteTransaction() {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = Provider.of<ExpenditureViewModel>(context, listen: false);
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
              await viewModel.deleteExpenditure(widget.expenditure!.id);
              if (mounted) {
                Navigator.pop(context);
              }
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