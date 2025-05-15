import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import '../models/mock_data.dart';
import '../controllers/expense_controller.dart'; // Import ExpenseController

enum DashboardView { Income, Expenses } // Define enum for dashboard views

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardView _selectedView =
      DashboardView
          .Expenses; // State variable for selected view, default to Expenses

  @override
  Widget build(BuildContext context) {
    final expenseController =
        Get.find<ExpenseController>(); // Get instance of ExpenseController

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Segmented Button
            SegmentedButton<DashboardView>(
              segments: const <ButtonSegment<DashboardView>>[
                ButtonSegment<DashboardView>(
                  value: DashboardView.Income,
                  label: Text('Income'),
                ),
                ButtonSegment<DashboardView>(
                  value: DashboardView.Expenses,
                  label: Text('Expenses'),
                ),
              ],
              selected: <DashboardView>{_selectedView},
              onSelectionChanged: (Set<DashboardView> newSelection) {
                setState(() {
                  _selectedView = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),
            // Conditionally display content based on selected view
            // Removed Income view as mockIncome was removed
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Expense Summary by Category:',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Obx(() {
                      // Use Obx for reactivity
                      final categoryTotals = _calculateCategoryTotals(
                        expenseController.expenses, // Use expenseController
                      );

                      if (categoryTotals.isEmpty) {
                        return const Center(
                          child: Text('No expenses recorded yet.'),
                        );
                      }
                      return ListView.builder(
                        itemCount: categoryTotals.length,
                        itemBuilder: (context, index) {
                          final category = categoryTotals.keys.elementAt(index);
                          final total = categoryTotals.values.elementAt(index);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    category,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    'RM ${total.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateCategoryTotals(List<Expense> expenses) {
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals.update(
        expense.category,
        (value) => value + expense.total,
        ifAbsent: () => expense.total,
      );
    }
    return categoryTotals;
  }
}
