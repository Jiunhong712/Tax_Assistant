import 'package:get/get.dart';
import '../models/mock_data.dart'; // Import mock data
import 'package:taxassistant/history%20page/history_controller.dart';

class ExpenseController extends GetxController {
  final List<Expense> _expenses =
      [...mockExpenses].obs; // Use mock data and make it observable

  List<Expense> get expenses => _expenses;

  void addExpense(Expense expense) {
    _expenses.add(expense);
  }

  // You might add methods here to update or remove expenses later
}
