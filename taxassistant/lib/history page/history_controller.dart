import '../models/mock_data.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  // Mock Expense Data
  final List<Expense> mockExpenses = [
    Expense(
      vendor: 'Pantai Hospital',
      date: '2025-05-09',
      total: 2000.00,
      fullText: 'Medical treatment',
      category: 'Medical & Health',
    ),
    Expense(
      vendor: 'AIA Insurance',
      date: '2025-05-11',
      total: 2400.00,
      fullText: 'Insurance',
      category: 'Retirement & Investment',
    ),
    Expense(
      vendor: 'Tesla Malaysia',
      date: '2025-05-13',
      total: 2300.00,
      fullText: 'EV charger',
      category: 'Lifestyle & Daily Living',
    ),
    Expense(
      vendor: 'Game Store',
      date: '2025-05-06',
      total: 800.00,
      fullText: 'Smartphone',
      category: 'Lifestyle & Daily Living',
    ),
    Expense(
      vendor: 'Little Star Kindergarten',
      date: '2025-05-07',
      total: 900.00,
      fullText: 'Monthly childcare fee',
      category: 'Childcare & Parenting',
    ),
    Expense(
      vendor: 'Big Pharmacy',
      date: '2025-01-15',
      total: 50.00,
      fullText: 'COVID test kits',
      category: 'Medical & Health',
    ),
  ];

  // Getter to get unique categories from mock data
  List<String> get uniqueCategories {
    final expenseCategories =
        mockExpenses.map((expense) => expense.category).toList();
    final incomeCategories =
        mockIncome.map((income) => income.category).toList();
    final allCategories = [...expenseCategories, ...incomeCategories];
    return allCategories.toSet().toList();
  }

  final List<Income> mockIncome = [
    // December 2024
    Income(
      vendor: 'Freelance Client E',
      date: '2024-12-18',
      total: 700.00,
      fullText: 'Consulting services',
      category: 'Freelance',
    ),
    // November 2024
    Income(
      vendor: 'Employer',
      date: '2024-11-30',
      total: 5000.00,
      fullText: 'Monthly Salary',
      category: 'Salary',
    ),
    // October 2024
    Income(
      vendor: 'Freelance Client F',
      date: '2024-10-25',
      total: 1100.00,
      fullText: 'Website maintenance',
      category: 'Freelance',
    ),
    // January 2025
    Income(
      vendor: 'Employer',
      date: '2025-01-31',
      total: 5000.00,
      fullText: 'Monthly Salary',
      category: 'Salary',
    ),
    Income(
      vendor: 'Freelance Client A',
      date: '2025-01-15',
      total: 1200.00,
      fullText: 'Mobile app development',
      category: 'Freelance',
    ),

    // February 2025
    Income(
      vendor: 'Employer',
      date: '2025-02-28',
      total: 5000.00,
      fullText: 'Monthly Salary',
      category: 'Salary',
    ),
    Income(
      vendor: 'Freelance Client B',
      date: '2025-02-20',
      total: 1000.00,
      fullText: 'Website redesign project',
      category: 'Freelance',
    ),

    // March 2025
    Income(
      vendor: 'Employer',
      date: '2025-03-31',
      total: 5000.00,
      fullText: 'Monthly Salary',
      category: 'Salary',
    ),
    Income(
      vendor: 'Freelance Client A',
      date: '2025-03-18',
      total: 1600.00,
      fullText: 'Backend integration task',
      category: 'Freelance',
    ),

    // April 2025
    Income(
      vendor: 'Employer',
      date: '2025-04-30',
      total: 5000.00,
      fullText: 'Monthly Salary',
      category: 'Salary',
    ),
    Income(
      vendor: 'Freelance Client C',
      date: '2025-04-12',
      total: 900.00,
      fullText: 'Graphic design work',
      category: 'Freelance',
    ),

    // May 2025
    Income(
      vendor: 'Employer',
      date: '2025-05-15',
      total: 5000.00,
      fullText: 'Monthly Salary',
      category: 'Salary',
    ),
    Income(
      vendor: 'Freelance Client D',
      date: '2025-05-10',
      total: 1500.00,
      fullText: 'Freelance project payment',
      category: 'Freelance',
    ),
  ];

  String getCombinedDashboardData() {
    final currentYear = DateTime.now().year;

    final incomeThisYear = mockIncome
        .where((income) {
          final incomeDate = DateTime.parse(income.date);
          return incomeDate.year == currentYear;
        })
        .fold(0.0, (sum, income) => sum + income.total);

    final expensesThisYear = mockExpenses
        .where((expense) {
          final expenseDate = DateTime.parse(expense.date);
          return expenseDate.year == currentYear;
        })
        .fold(0.0, (sum, expense) => sum + expense.total);

    final totalIncomeByYear =
        'Total Income in $currentYear: RM ${incomeThisYear.toStringAsFixed(2)}';
    final totalExpensesByYear =
        'Total Expenses in $currentYear: RM ${expensesThisYear.toStringAsFixed(2)}';

    final expensesByCategoryThisYear = mockExpenses
        .where((expense) {
          final expenseDate = DateTime.parse(expense.date);
          return expenseDate.year == currentYear;
        })
        .fold<Map<String, double>>({}, (map, expense) {
          map[expense.category] =
              (map[expense.category] ?? 0.0) + expense.total;
          return map;
        });

    String totalExpensesByCategoryByYear =
        'Expenses by Category in $currentYear: ';
    expensesByCategoryThisYear.forEach((category, total) {
      totalExpensesByCategoryByYear +=
          '$category: RM ${total.toStringAsFixed(2)}, ';
    });
    // Remove the trailing comma and space
    if (totalExpensesByCategoryByYear.endsWith(', ')) {
      totalExpensesByCategoryByYear = totalExpensesByCategoryByYear.substring(
        0,
        totalExpensesByCategoryByYear.length - 2,
      );
    }

    return "$totalIncomeByYear\n$totalExpensesByYear\n$totalExpensesByCategoryByYear";
  }
}
