import 'package:flutter/material.dart';
import 'mock_data.dart'; // Import mock data

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [...mockExpenses]; // Use mock data

  List<Expense> get expenses => _expenses;

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  // You might add methods here to update or remove expenses later
}
