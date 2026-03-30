import 'package:flutter/material.dart';

import 'sections/camera_scanner_page.dart';
import 'sections/add_edit_expenditure_page.dart';

import 'settings/settings_view.dart';
import 'transaction/add_transaction_view.dart';
import 'transaction/search_page.dart';
import 'transaction/expenditure_list_view.dart';
import 'transaction/scheduled_expenditure_list_view.dart';
import 'savings/saving_goal_list_view.dart';
import 'savings/add_saving_goal_view.dart';
import 'reports_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ExpenditureListView(),
    ScheduledExpenditureListView(),
    ReportsView(),
    SavingGoalListView(),
    SettingsView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchPage()),
              );
            },
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      floatingActionButton: _selectedIndex != 2 && _selectedIndex != 4 ? FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            // Show dialog with camera and add manually options
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Scan Receipt'),
                        subtitle: const Text('Use your camera to scan a receipt'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CameraScannerPage(),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Add Manually'),
                        subtitle: const Text('Enter transaction details manually'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddEditExpenditurePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (_selectedIndex == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionView(),
              ),
            );
          } else if (_selectedIndex == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddSavingGoalView(),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Assets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[700],
        onTap: _onItemTapped,
      ),
    );
  }
}
