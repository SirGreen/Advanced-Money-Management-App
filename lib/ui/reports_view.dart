import 'package:flutter/material.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Reports',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
