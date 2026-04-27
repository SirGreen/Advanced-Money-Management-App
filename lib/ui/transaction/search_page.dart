import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'expenditure_view_model.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/entities/tag.dart';
import '../helpers/glass_card.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/section_header.dart';
import '../helpers/tag_icon.dart';
import 'search_results_page.dart';
// Note: Assuming a settings provider exists, or we default to VND. If the new app has settings, we can use it.
// For now, using a simple fallback or hardcoded VND since AppLocalizations / Settings might be slightly different.

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SearchAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AppBar(
        title: const GradientTitle(text: 'Advanced Search'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _filter = SearchFilter();
  final _keywordController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  final List<String> _selectedTagIds = [];

  @override
  void dispose() {
    _keywordController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _performSearch() {
    _filter.keyword = _keywordController.text.trim().isNotEmpty
        ? _keywordController.text.trim()
        : null;
    _filter.minAmount = _minAmountController.text.isNotEmpty
        ? double.tryParse(_minAmountController.text)
        : null;
    _filter.maxAmount = _maxAmountController.text.isNotEmpty
        ? double.tryParse(_maxAmountController.text)
        : null;

    final expenditureViewModel = Provider.of<ExpenditureViewModel>(
      context,
      listen: false,
    );
    _filter.tags = _selectedTagIds
        .map(
          (id) => expenditureViewModel.tags.cast<Tag?>().firstWhere(
            (t) => t?.id == id,
            orElse: () => null,
          ),
        )
        .whereType<Tag>()
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SearchResultsPage(filter: _filter)),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _filter.startDate != null && _filter.endDate != null
          ? DateTimeRange(start: _filter.startDate!, end: _filter.endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _filter.startDate = picked.start;
        _filter.endDate = picked.end;
      });
    }
  }

  void _setToday() {
    final now = DateTime.now();
    setState(() {
      _filter.startDate = DateTime(now.year, now.month, now.day);
      _filter.endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    });
  }

  void _setThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    setState(() {
      _filter.startDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      _filter.endDate = endOfWeek;
    });
  }

  void _setThisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    setState(() {
      _filter.startDate = startOfMonth;
      _filter.endDate = endOfMonth;
    });
  }

  void _setAllTime() {
    setState(() {
      _filter.startDate = null;
      _filter.endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const searchAppBar = SearchAppBar();
    final double appBarHeight = searchAppBar.preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalTopOffset = appBarHeight + statusBarHeight;

    return BackGround(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: searchAppBar,
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, totalTopOffset + 16, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildTransactionTypeCard(),
                  const SizedBox(height: 16),
                  _buildKeywordCard(),
                  const SizedBox(height: 16),
                  _buildAmountCard(),
                  const SizedBox(height: 16),
                  _buildDateCard(),
                  const SizedBox(height: 16),
                  _buildTagsCard(),
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _performSearch,
          label: const Text('Search'),
          icon: const Icon(Icons.search),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildTransactionTypeCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Transaction Type'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DropdownButtonFormField<TransactionTypeFilter>(
              initialValue: _filter.transactionType,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: TransactionTypeFilter.all,
                  child: Text('All'),
                ),
                DropdownMenuItem(
                  value: TransactionTypeFilter.expense,
                  child: Text('Expense'),
                ),
                DropdownMenuItem(
                  value: TransactionTypeFilter.income,
                  child: Text('Income'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _filter.transactionType = val);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywordCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Keyword'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextFormField(
              controller: _keywordController,
              decoration: InputDecoration(
                hintText: 'Search by Name or Note',
                prefixIcon: const Icon(Icons.title),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Amount Range'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minAmountController,
                    decoration: InputDecoration(
                      labelText: 'Min',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxAmountController,
                    decoration: InputDecoration(
                      labelText: 'Max',
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
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

  Widget _buildDateCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Date Range'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                const Icon(Icons.date_range_outlined, color: Colors.grey),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _filter.startDate != null
                        ? '${DateFormat.yMMMd().format(_filter.startDate!)} - ${DateFormat.yMMMd().format(_filter.endDate!)}'
                        : 'Any Date',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                TextButton(
                  onPressed: _selectDateRange,
                  child: Text(_filter.startDate != null ? 'Change' : 'Select'),
                ),
                if (_filter.startDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _setAllTime,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8.0,
              children: [
                ActionChip(label: const Text('Today'), onPressed: _setToday),
                ActionChip(
                  label: const Text('This Week'),
                  onPressed: _setThisWeek,
                ),
                ActionChip(
                  label: const Text('This Month'),
                  onPressed: _setThisMonth,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsCard() {
    final viewModel = Provider.of<ExpenditureViewModel>(context);
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Tags'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: (viewModel.tags.isEmpty)
                ? const Center(
                    child: Text(
                      'No Tags Yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: viewModel.tags.map((tag) {
                      final isSelected = _selectedTagIds.contains(tag.id);
                      return FilterChip(
                        label: Text(tag.name),
                        avatar: TagIcon(tag: tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTagIds.add(tag.id);
                            } else {
                              _selectedTagIds.remove(tag.id);
                            }
                          });
                        },
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        backgroundColor: Colors.black.withValues(alpha: 0.1),
                        selectedColor: Colors.white.withValues(alpha: 0.8),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
