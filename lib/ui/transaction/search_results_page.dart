import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'expenditure_view_model.dart';
import '../../domain/entities/expenditure.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/entities/tag.dart';
import 'add_transaction_view.dart';
import '../helpers/gradient_background.dart';
import '../helpers/gradient_title.dart';
import '../helpers/tag_icon_mapper.dart';
// Note: GlassCardContainer isn't defined explicitly in snippets, so we'll just use a styled Card/Container
// to match the app's glassy aesthetic if needed, or stick to default Material Card for the list.

class SearchResultsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Function(SortOption) onSortSelected;

  const SearchResultsAppBar({super.key, required this.onSortSelected});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: AppBar(
          title: const GradientTitle(text: 'Search Results'),
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
              tooltip: 'Sort By',
              onSelected: onSortSelected,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: SortOption.dateDesc,
                  child: Text('Date (Newest First)'),
                ),
                PopupMenuItem(
                  value: SortOption.dateAsc,
                  child: Text('Date (Oldest First)'),
                ),
                PopupMenuItem(
                  value: SortOption.amountDesc,
                  child: Text('Amount (Highest First)'),
                ),
                PopupMenuItem(
                  value: SortOption.amountAsc,
                  child: Text('Amount (Lowest First)'),
                ),
                PopupMenuItem(
                  value: SortOption.nameAsc,
                  child: Text('Name (A-Z)'),
                ),
                PopupMenuItem(
                  value: SortOption.nameDesc,
                  child: Text('Name (Z-A)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchResultsPage extends StatefulWidget {
  final SearchFilter filter;
  const SearchResultsPage({super.key, required this.filter});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late List<Expenditure> _results;
  SortOption _currentSortOption = SortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  void _fetchResults() {
    final controller = Provider.of<ExpenditureViewModel>(
      context,
      listen: false,
    );
    _results = controller.getFilteredExpenditures(widget.filter);
    _sortResults();
  }

  void _sortResults() {
    setState(() {
      switch (_currentSortOption) {
        case SortOption.dateAsc:
          _results.sort((a, b) => a.date.compareTo(b.date));
          break;
        case SortOption.dateDesc:
          _results.sort((a, b) => b.date.compareTo(a.date));
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ExpenditureViewModel>(
      context,
      listen: false,
    );
    final searchAppBar = SearchResultsAppBar(
      onSortSelected: (newSortOption) {
        _currentSortOption = newSortOption;
        _sortResults();
      },
    );

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
              padding: EdgeInsets.fromLTRB(8, totalTopOffset + 8, 8, 8),
              sliver: _results.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('No Results Found')),
                    )
                  : SliverList.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final expenditure = _results[index];
                        final tag = controller.tags.firstWhere(
                          (t) => t.id == expenditure.mainTagId,
                          orElse: () => Tag(
                            id: 'unknown',
                            name: 'Unknown',
                            colorValue: Colors.grey.toARGB32(),
                          ),
                        );

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4.0,
                            horizontal: 8,
                          ),
                          color: Colors.white.withValues(alpha: 0.8),
                          child: ListTile(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddTransactionView(
                                    expenditure: expenditure,
                                  ),
                                ),
                              );
                              if (context.mounted) {
                                _fetchResults(); // Re-fetch in case of edits
                              }
                            },
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Transaction?"),
                                  content: const Text(
                                    "This action cannot be undone.",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("CANCEL"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await controller.deleteExpenditure(
                                          expenditure.id,
                                        );
                                        if (context.mounted) {
                                          _fetchResults();
                                        }
                                      },
                                      child: const Text(
                                        "DELETE",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Color(
                                tag.colorValue,
                              ).withValues(alpha: 0.2),
                              child: Icon(
                                getIconForTag(tag.iconName ?? 'other'),
                                color: Color(tag.colorValue),
                              ),
                            ),
                            title: Text(expenditure.articleName),
                            subtitle: Text(
                              '${tag.name} • ${DateFormat.yMMMd('vi_VN').format(expenditure.date)}',
                            ),
                            trailing: Text(
                              '${expenditure.isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(expenditure.amount ?? 0)}',
                              style: TextStyle(
                                color: expenditure.isIncome
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
