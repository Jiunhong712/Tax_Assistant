import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data'; // Required for Uint8List
import 'package:get/get.dart'; // Import GetX
import '../models/mock_data.dart';
import '../history page/history_controller.dart'; // Import history_controller.dart
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html; // For web download

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
    final historyController =
        Get.find<HistoryController>(); // Get instance of ExpenseController

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (_selectedView == DashboardView.Income) {
                  generateReport(HistoryController().mockIncome);
                } else {
                  generateReport(historyController.mockExpenses);
                }
              },
              child: Text(
                _selectedView == DashboardView.Income
                    ? 'Export Income Report'
                    : 'Export Expense Report',
              ),
            ),
            const SizedBox(height: 20),
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
            Expanded(
              child:
                  _selectedView == DashboardView.Income
                      ? _buildIncomeView() // Build Income view
                      : _buildExpenseView(
                        historyController,
                      ), // Build Expense view
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeView() {
    final monthlyIncome = _calculateMonthlyIncome(
      HistoryController().mockIncome,
    );

    if (monthlyIncome.isEmpty) {
      return const Center(child: Text('No income data available.'));
    }

    // Prepare data for the chart
    final List<BarChartGroupData> barGroups =
        monthlyIncome.entries.map((entry) {
          // Assuming entry.key is a month index (0 for Jan, 1 for Feb, etc.)
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(toY: entry.value, color: Colors.blue, width: 16),
            ],
            showingTooltipIndicators: [0],
          );
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Monthly Income:',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 50),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const months = [
                          'Jan',
                          'Feb',
                          'Mar',
                          'Apr',
                          'May',
                          'Jun',
                          'Jul',
                          'Aug',
                          'Sep',
                          'Oct',
                          'Nov',
                          'Dec',
                        ];
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8.0,
                          child: Text(months[value.toInt() % 12]),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: const Color(0xff37434d), width: 1),
                ),
                barGroups: barGroups,
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    monthlyIncome.values.reduce((a, b) => a > b ? a : b) *
                    1.1, // Add some padding to the top
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseView(HistoryController historyController) {
    final categoryTotals = _calculateCategoryTotals(
      historyController.mockExpenses,
    );

    if (categoryTotals.isEmpty) {
      return const Center(child: Text('No expenses recorded yet.'));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Expense Summary by Category:',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: categoryTotals.length,
            itemBuilder: (context, index) {
              final category = categoryTotals.keys.elementAt(index);
              final total = categoryTotals.values.elementAt(index);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(category, style: const TextStyle(fontSize: 16)),
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
          ),
        ),
      ],
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

  Map<int, double> _calculateMonthlyIncome(List<Expense> income) {
    final Map<int, double> monthlyTotals = {};
    for (var entry in income) {
      try {
        final date = DateTime.parse(entry.date);
        final month = date.month - 1; // 0 for January, 11 for December
        monthlyTotals.update(
          month,
          (value) => value + entry.total,
          ifAbsent: () => entry.total,
        );
      } catch (e) {
        // Handle potential date parsing errors
        print('Error parsing date: ${entry.date}');
      }
    }
    return monthlyTotals;
  }

  Future<void> generateReport(List<Expense> expenses) async {
    if (expenses.isEmpty) {
      // This part needs context from the UI to show a SnackBar
      // For now, I'll just print a message.
      print('No expenses to generate a report.');
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Expense Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Processed Expenses:'),
              pw.SizedBox(height: 10),
              for (var expense in expenses)
                pw.Text(
                  '- ${expense.date}: ${expense.vendor} - ${expense.total.toStringAsFixed(2)} (${expense.category})',
                ),
              // Add more details like summaries and deductions here
            ],
          );
        },
      ),
    );

    // Save the PDF
    final bytes = await pdf.save();

    // For web, trigger download
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', 'expense_report.pdf')
          ..click();
    html.Url.revokeObjectUrl(url);
  }
}
