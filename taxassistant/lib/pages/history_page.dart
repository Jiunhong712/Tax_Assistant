import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/mock_data.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Expense> _historyExpenses = [];
  bool _isLoading = false;
  String _selectedFilter = 'All'; // Default filter
  List<String> _availableFilters = [
    'All',
    'Food',
    'Travel',
    'Computers',
  ]; // Mock filters

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

    // Use mock expenses from mock_data.dart
    final List<Expense> fetchedExpenses = mockExpenses;

    setState(() {
      _historyExpenses = fetchedExpenses;
      _isLoading = false;
    });
  }

  List<Expense> _getFilteredExpenses() {
    if (_selectedFilter == 'All') {
      return _historyExpenses;
    } else {
      return _historyExpenses
          .where((expense) => expense.category == _selectedFilter)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedFilter,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                });
              },
              items:
                  _availableFilters.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                  child: ListView.builder(
                    itemCount: _getFilteredExpenses().length,
                    itemBuilder: (context, index) {
                      final expense = _getFilteredExpenses()[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
    );
  }
}
