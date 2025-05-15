import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/mock_data.dart'; // mockIncome will be moved here
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:taxassistant/history%20page/history_controller.dart';

enum HistoryView { Income, Expenses }

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final historyController = Get.find<HistoryController>();
  List<Expense> _allHistory = [];
  List<Expense> _incomeHistory = [];
  List<Expense> _expenseHistory = [];
  bool _isLoading = false;
  HistoryView _selectedView =
      HistoryView.Income; // Initialize with a default value

  // State for Income filtering
  String _selectedIncomeMonth = 'All';
  List<String> _availableIncomeMonths = ['All'];

  // State for Expense filtering
  String _selectedExpenseMonth = 'All';
  String _selectedExpenseCategory = 'All';
  List<String> _availableExpenseMonths = ['All'];
  final List<String> _availableExpenseCategories = [
    'All',
    'Lifestyle & Daily Living',
    'Childcare & Parenting',
    'Medical & Health',
    'Retirement & Investment',
    'Housing',
  ];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
    });

    // Mock: Simulate fetching history from /history endpoint
    print('Simulating fetching history from /history endpoint');
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // Access mockIncome and mockExpenses from mock_data.dart
    _allHistory = [
      ...historyController.mockExpenses,
      ...historyController.mockIncome,
    ]; // Combine for all history
    _incomeHistory = historyController.mockIncome;
    _expenseHistory = historyController.mockExpenses;

    _populateAvailableFilters();

    setState(() {
      _isLoading = false;
    });
  }

  void _populateAvailableFilters() {
    // Populate available months for income and expenses
    final allDates =
        _allHistory.map((expense) => DateTime.parse(expense.date)).toList();
    final uniqueMonths =
        allDates
            .map((date) => DateFormat('yyyy-MM').format(date))
            .toSet()
            .toList();
    uniqueMonths.sort(); // Sort months chronologically

    _availableIncomeMonths = ['All', ...uniqueMonths];
    _availableExpenseMonths = ['All', ...uniqueMonths];
  }

  List<Expense> _getFilteredIncome() {
    List<Expense> filteredIncome = _incomeHistory;

    if (_selectedIncomeMonth != 'All') {
      filteredIncome =
          filteredIncome.where((expense) {
            final month = DateFormat(
              'yyyy-MM',
            ).format(DateTime.parse(expense.date));
            return month == _selectedIncomeMonth;
          }).toList();
    }

    return filteredIncome;
  }

  List<Expense> _getFilteredExpenses() {
    List<Expense> filteredExpenses = _expenseHistory;

    if (_selectedExpenseMonth != 'All') {
      filteredExpenses =
          filteredExpenses.where((expense) {
            final month = DateFormat(
              'yyyy-MM',
            ).format(DateTime.parse(expense.date));
            return month == _selectedExpenseMonth;
          }).toList();
    }

    if (_selectedExpenseCategory != 'All') {
      filteredExpenses =
          filteredExpenses
              .where((expense) => expense.category == _selectedExpenseCategory)
              .toList();
    }

    return filteredExpenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<HistoryView>(
                      segments: const <ButtonSegment<HistoryView>>[
                        ButtonSegment<HistoryView>(
                          value: HistoryView.Income,
                          label: Text('Income'),
                        ),
                        ButtonSegment<HistoryView>(
                          value: HistoryView.Expenses,
                          label: Text('Expenses'),
                        ),
                      ],
                      selected: <HistoryView>{_selectedView},
                      onSelectionChanged: (Set<HistoryView> newSelection) {
                        setState(() {
                          _selectedView = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Conditionally display Income or Expense section
                    if (_selectedView == HistoryView.Income)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Income History',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 10),
                            DropdownButton<String>(
                              value: _selectedIncomeMonth,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedIncomeMonth = newValue!;
                                });
                              },
                              items:
                                  _availableIncomeMonths
                                      .map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      })
                                      .toList(),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _getFilteredIncome().length,
                                itemBuilder: (context, index) {
                                  final income = _getFilteredIncome()[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: ListTile(
                                      title: Text(income.vendor),
                                      subtitle: Text(
                                        '${income.date} - ${income.category}',
                                      ),
                                      trailing: Text(
                                        'RM ${income.total.toStringAsFixed(2)}',
                                      ),
                                    ),
                                  );
                                },
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
                              'Expense History',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _selectedExpenseMonth,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedExpenseMonth = newValue!;
                                      });
                                    },
                                    items:
                                        _availableExpenseMonths
                                            .map<DropdownMenuItem<String>>((
                                              String value,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            })
                                            .toList(),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _selectedExpenseCategory,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedExpenseCategory = newValue!;
                                      });
                                    },
                                    items:
                                        _availableExpenseCategories
                                            .map<DropdownMenuItem<String>>((
                                              String value,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            })
                                            .toList(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _getFilteredExpenses().length,
                                itemBuilder: (context, index) {
                                  final expense = _getFilteredExpenses()[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: ListTile(
                                      title: Text(expense.vendor),
                                      subtitle: Text(
                                        '${expense.date} - ${expense.category}',
                                      ),
                                      trailing: Text(
                                        'RM ${expense.total.toStringAsFixed(2)}',
                                      ),
                                    ),
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
}
