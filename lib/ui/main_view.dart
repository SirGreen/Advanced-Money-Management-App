import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:animations/animations.dart';
import 'helpers/shared_axis_page_route.dart';
import 'sections/camera_scanner_page.dart';

import '../l10n/app_localizations.dart';
import 'settings/settings_view.dart';
import 'transaction/add_transaction_view.dart';
import 'transaction/transaction_list_view.dart';
import 'transaction/dashboard_page.dart';
import 'transaction/reports_page.dart';
import 'savings/assets_page.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final TabController _assetsTabController;
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _assetsTabController = TabController(length: 3, vsync: this);
    _assetsTabController.addListener(() {
      if (_selectedIndex == 3) {
        setState(() {});
      }
    });

    _widgetOptions = <Widget>[
      DashboardPage(
        onViewAllTransactions: () => _onItemTapped(1),
        onViewBudgets: () => _onItemTapped(3),
        onNavigateToSettings: () => _onItemTapped(4),
      ),
      const TransactionListView(),
      const ReportsPage(),
      AssetsPage(tabController: _assetsTabController),
      const SettingsView(),
    ];
  }

  @override
  void dispose() {
    _assetsTabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPageWidget = _widgetOptions[_selectedIndex];

    if (currentPageWidget is DashboardPage) {
      return currentPageWidget.buildFab(context);
    }

    if (currentPageWidget is AssetsPage) {
      return currentPageWidget.buildFab(context, _assetsTabController.index);
    }

    if (_selectedIndex == 2) {
      return const SizedBox.shrink();
    }

    if (_selectedIndex == 1) {
      return SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.teal.shade800,
        tooltip: l10n.addTransaction,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.camera_alt_outlined),
            backgroundColor: Colors.teal.shade500,
            foregroundColor: Colors.white,
            label: l10n.scanReceipt,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CameraScannerPage()),
            ),
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit),
            backgroundColor: Colors.teal.shade500,
            foregroundColor: Colors.white,
            label: l10n.addManually,
            onTap: () => Navigator.of(context).push(
              SharedAxisPageRoute(
                page: const AddTransactionView(),
                transitionType: SharedAxisTransitionType.scaled,
              ),
            ),
          ),
        ],
      );
    }

    return FloatingActionButton(
      backgroundColor: Colors.teal.shade600,
      foregroundColor: Colors.white,
      onPressed: () {
        if (_selectedIndex != 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionView()),
          );
        }
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      appBar: null,
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          elevation: 0,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard),
              label: l10n.dashboard,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: l10n.transactionsSingle,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.bar_chart),
              label: l10n.reports,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              activeIcon: const Icon(Icons.account_balance_wallet),
              label: l10n.assets,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: l10n.settings,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.6),
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
