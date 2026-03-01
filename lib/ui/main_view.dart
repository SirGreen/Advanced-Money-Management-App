import 'package:flutter/material.dart';
import 'transaction/add_transaction_view.dart';
import 'transaction/add_scheduled_expenditure_view.dart';
import 'transaction/expenditure_list_view.dart';
import 'transaction/scheduled_expenditure_list_view.dart';
import 'sections/camera_scanner_page.dart'; 

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
    CameraScannerPage(),
    Center(child: Text('Settings (Coming Soon)')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      floatingActionButton: _selectedIndex == 2 || _selectedIndex == 3
        ? null
        : FloatingActionButton(
            onPressed: () {
              Widget destination;

              if (_selectedIndex == 1) {
                destination = const AddScheduledExpenditureView();
              } else {
                destination = const AddTransactionView();
              }

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              );
            },
            child: Icon(_selectedIndex == 2 ? Icons.camera_alt : Icons.add),
          ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.repeat),
            label: 'Recurring',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.document_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}