import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'money_view_model.dart';

class MoneyView extends StatefulWidget {
  const MoneyView({super.key});

  @override
  State<MoneyView> createState() => _MoneyViewState();
}

class _MoneyViewState extends State<MoneyView> {
  @override
  void initState() {
    super.initState();
    // Load data when the screen starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MoneyViewModel>(context, listen: false).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MoneyViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text("3-Layer Architecture")),
      body: Center(
        child: Consumer<MoneyViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) return const CircularProgressIndicator();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "\$${vm.totalSpent}",
                  style: const TextStyle(fontSize: 40),
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
            );
          },
        ),
      ),
    );
  }
}
