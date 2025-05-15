import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_provider.dart';
import '../models/mock_data.dart';
import 'package:taxassistant/history%20page/history_controller.dart';
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:intl/intl.dart'; // Import intl for date formatting

enum DashboardView { Income, Expenses } // Define enum for dashboard views

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardView _selectedView =
      DashboardView.Income; // State variable for selected view

  @override
  Widget build(BuildContext context) {
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
            if (_selectedView == DashboardView.Income)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Display Total Income
                    Text(
                      'Total Income: RM ${_calculateTotalIncome().toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Income by Month:',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 70),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          barGroups: _createMonthlyIncomeBarGroups(
                            _calculateMonthlyIncome(),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: _getBottomTitles,
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
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
                      child: Consumer<ExpenseProvider>(
                        builder: (context, expenseProvider, child) {
                          final categoryTotals = _calculateCategoryTotals(
                            expenseProvider.expenses,
                          );

                          if (categoryTotals.isEmpty) {
                            return const Center(
                              child: Text('No expenses recorded yet.'),
                            );
                          }
                          return ListView.builder(
                            itemCount: categoryTotals.length,
                            itemBuilder: (context, index) {
                              final category = categoryTotals.keys.elementAt(
                                index,
                              );
                              final total = categoryTotals.values.elementAt(
                                index,
                              );
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                ),
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
                        },
                      ),
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

  double _calculateTotalIncome() {
    double totalIncome = 0.0;
    for (var income in mockIncome) {
      totalIncome += income.total;
    }
    return totalIncome;
  }

  Map<String, double> _calculateMonthlyIncome() {
    final Map<String, double> monthlyIncome = {};
    for (var income in mockIncome) {
      final month = DateFormat('yyyy-MM').format(DateTime.parse(income.date));
      monthlyIncome.update(
        month,
        (value) => value + income.total,
        ifAbsent: () => income.total,
      );
    }
    return monthlyIncome;
  }

  List<BarChartGroupData> _createMonthlyIncomeBarGroups(
    Map<String, double> monthlyIncome,
  ) {
    List<BarChartGroupData> barGroups = [];
    final sortedMonths = monthlyIncome.keys.toList()..sort();

    for (int i = 0; i < sortedMonths.length; i++) {
      final month = sortedMonths[i];
      final income = monthlyIncome[month] ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: income, color: Colors.blue, width: 20),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    return barGroups;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    final monthlyIncome = _calculateMonthlyIncome();
    final sortedMonths = monthlyIncome.keys.toList()..sort();

    if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
      final month = sortedMonths[value.toInt()];
      text = DateFormat('MMM').format(DateTime.parse('$month-01'));
    } else {
      text = '';
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: Text(text, style: style),
    );
  }
}
