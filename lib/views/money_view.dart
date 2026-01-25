import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/money_view_model.dart';

class MoneyView extends StatelessWidget {
  const MoneyView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MoneyViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("MVVM Money Tracker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Total Money Spent:"),
            
            Consumer<MoneyViewModel>(
              builder: (context, vm, child) {
                return Text(
                  "\$${vm.totalSpent}",
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => viewModel.addExpense(10),
                  child: const Text("Spend \$10"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => viewModel.addExpense(50),
                  child: const Text("Spend \$50"),
                ),
              ],
            ),
            TextButton(
              onPressed: () => viewModel.resetSpending(),
              child: const Text("Reset"),
            )
          ],
        ),
      ),
    );
  }
}