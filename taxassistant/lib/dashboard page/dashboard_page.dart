import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../history page/history_controller.dart';
import '../models/mock_data.dart'; // Import Expense and Income models

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final HistoryController historyController = Get.find<HistoryController>();
  int _selectedYear = DateTime.now().year; // State for selected year

  @override
  void initState() {
    super.initState();
    // Potentially fetch or load data here if not using GetX controller directly
  }

  // Helper to group expenses by category for the selected year
  Map<String, List<Expense>> _getExpensesByCategoryAndYear() {
    final selectedYearExpenses =
        historyController.mockExpenses
            .where(
              (expense) => DateTime.parse(expense.date).year == _selectedYear,
            )
            .toList();

    final Map<String, List<Expense>> groupedExpenses = {};
    for (var expense in selectedYearExpenses) {
      if (groupedExpenses.containsKey(expense.category)) {
        groupedExpenses[expense.category]!.add(expense);
      } else {
        groupedExpenses[expense.category] = [expense];
      }
    }
    return groupedExpenses;
  }

  // Helper to calculate total income for the selected year
  double _getTotalIncomeForYear() {
    return historyController.mockIncome
        .where((income) => DateTime.parse(income.date).year == _selectedYear)
        .fold(0.0, (sum, income) => sum + income.total);
  }

  // Placeholder for calculating potential tax relief (needs actual logic)
  double _getPotentialTaxRelief() {
    // This is a placeholder. Actual tax relief calculation logic is needed here.
    // It would likely involve analyzing expenses based on tax regulations.
    return 5000.00; // Example placeholder value
  }

  @override
  Widget build(BuildContext context) {
    final groupedExpenses = _getExpensesByCategoryAndYear();
    final totalIncome = _getTotalIncomeForYear();
    final potentialTaxRelief = _getPotentialTaxRelief();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: kColorPrimary, fontFamily: 'Poppins'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Year Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: kColorPrimary,
                    size: 20.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedYear--;
                    });
                  },
                ),
                Text(
                  _selectedYear.toString(),
                  style: TextStyle(
                    color: kColorPrimary,
                    fontFamily: 'Poppins',
                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                    fontWeight:
                        Theme.of(context).textTheme.titleLarge!.fontWeight,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: kColorPrimary,
                    size: 20.0,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedYear++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Total Income for the Year
            Text(
              'Total Income $_selectedYear:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'RM ${totalIncome.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: kColorPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Expenses by Category
            Text(
              'Expenses by Category $_selectedYear:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: groupedExpenses.keys.length,
                itemBuilder: (context, index) {
                  final category = groupedExpenses.keys.elementAt(index);
                  final expenses = groupedExpenses[category]!;
                  final totalCategoryExpense = expenses.fold(
                    0.0,
                    (sum, expense) => sum + expense.total,
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ExpansionTile(
                      title: Text(
                        '$category (RM ${totalCategoryExpense.toStringAsFixed(2)})',
                        style: TextStyle(
                          color: kColorPrimary,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children:
                          expenses.map((expense) {
                            return ListTile(
                              title: Text(expense.vendor),
                              subtitle: Text(
                                '${expense.date} - ${expense.category}',
                              ),
                              trailing: Text(
                                '-RM ${expense.total.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          }).toList(),
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
