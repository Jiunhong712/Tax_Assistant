import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants.dart';
import '../history page/history_controller.dart';
import '../data.dart'; // Import Expense and Income models
import '../profile page/profile_page.dart'; // Import ProfilePage
import '../filling page/filling_page.dart'; // Import FillingPage
import 'package:taxassistant/main.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final HistoryController historyController = Get.find<HistoryController>();
  int _selectedYear = DateTime.now().year; // State for selected year
  bool _isLoading = false; // State for loading indicator
  Map<String, dynamic>? _analysisResults; // State for AI analysis results

  @override
  void initState() {
    super.initState();
    // Potentially fetch or load data here if not using GetX controller directly
  }

  // Function to call the AI backend
  Future<void> _analyseWithAI() async {
    setState(() {
      _isLoading = true;
    });

    // Prepare dashboard data to send
    final groupedExpenses = _getExpensesByCategoryAndYear();
    final totalIncome = _getTotalIncomeForYear();

    // Format data for JSON
    final dashboardData = {
      'year': _selectedYear,
      'totalIncome': totalIncome,
      'expensesByCategory': groupedExpenses.map(
        (category, expenses) => MapEntry(
          category,
          expenses.map((expense) => expense.toJson()).toList(),
        ),
      ), // Assuming Expense model has toJson()
    };

    // URL of the Flask backend
    final url = Uri.parse(
      'http://127.0.0.1:5001/chatbot',
    ); // Using chatbot endpoint as per user feedback

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': """
              Analyse my financial data for $_selectedYear and calculate the **total amount of tax relief for each category**.
              For each category, return:

- `relief_amount`: the maximum tax relief amount for that category.
- `suggestion`: a short, practical suggestion on how to maximize tax relief for that category.

Return the final response in JSON format, structured as a dictionary where each key is the category name, and the value is an object with `relief_amount` and `suggestion`.

Example format:

{
  "healthcare": {
    "relief_amount": 500,
    "suggestion": "Increase your contributions to health savings accounts to maximize relief."
  },
  "education": {
    "relief_amount": 300,
    "suggestion": "Claim all eligible education expenses and keep receipts for deductions."
  }
}

Return the final response in JSON format only. Do not include explanations, examples, or any text other than the JSON.

""", // Provide a default message
          'dashboardData': dashboardData, // Include dashboard data
        }),
      );

      if (response.statusCode == 200) {
        // Request successful, process the response
        final responseData = jsonDecode(response.body);
        final apiResponseText = responseData['response'];

        try {
          _analysisResults = jsonDecode(apiResponseText);
          // TODO: Handle the AI analysis response (e.g., display in a dialog or navigate to a new page)
          print(
            'AI Analysis Response: $_analysisResults',
          ); // For now, print to console
        } catch (e) {
          print('Error decoding AI response: $e');
          // TODO: Show an error message to the user
        }
      } else {
        // Request failed
        // TODO: Handle error response (e.g., show an error message to the user)
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle network or other errors
      // TODO: Handle network error (e.g., show an error message to the user)
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: kColorPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: kColorPrimary),
              )
              : SingleChildScrollView(
                child: Padding(
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
                              fontSize:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.fontSize,
                              fontWeight:
                                  Theme.of(
                                    context,
                                  ).textTheme.titleLarge!.fontWeight,
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
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          color: kColorPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Expenses by Category and Analyse with AI button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expenses by Category $_selectedYear:',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          OutlinedButton.icon(
                            onPressed:
                                _isLoading
                                    ? null
                                    : _analyseWithAI, // Disable button when loading
                            icon: Icon(
                              Icons.lightbulb_outline,
                              color: kColorPrimary,
                            ),
                            label: const Text(
                              'Analyse with AI',
                              style: TextStyle(
                                color: kColorPrimary,
                                fontFamily: 'Poppins',
                              ),
                            ), // Added closing parenthesis for OutlinedButton.icon
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: kColorComponent),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true, // Add shrinkWrap
                        physics: NeverScrollableScrollPhysics(), // Add physics
                        itemCount: groupedExpenses.keys.length,
                        itemBuilder: (context, index) {
                          final category = groupedExpenses.keys.elementAt(
                            index,
                          );
                          final expenses = groupedExpenses[category]!;
                          final totalCategoryExpense = expenses.fold(
                            0.0,
                            (sum, expense) => sum + expense.total,
                          );

                          // Get potential relief amount if available
                          final potentialRelief =
                              (_analysisResults != null &&
                                      _analysisResults!.containsKey(category))
                                  ? _analysisResults![category]['relief_amount']
                                  : null;

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ExpansionTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$category (RM ${totalCategoryExpense.toStringAsFixed(2)})',
                                    style: TextStyle(
                                      color: kColorPrimary,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (potentialRelief != null)
                                    Text(
                                      'Maximum Relief: RM ${potentialRelief.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color:
                                            (potentialRelief != null &&
                                                    potentialRelief <
                                                        totalCategoryExpense)
                                                ? Colors.green
                                                : Colors
                                                    .red, // Set text color based on condition
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              children: [
                                // Display AI suggestion if available
                                if (_analysisResults != null &&
                                    _analysisResults!.containsKey(category))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      'AI Suggestion: ${_analysisResults![category]['suggestion']}',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.fontSize,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ...expenses.map((expense) {
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
                              ], // Added closing bracket for the children list
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24.0), // Add some spacing
                      // Buttons at the bottom
                      if (_analysisResults !=
                          null) // Conditionally render buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomePage(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: kColorComponent),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                              ),
                              child: const Text(
                                'Upload Files',
                                style: TextStyle(
                                  color: kColorPrimary,
                                  fontFamily: 'Poppins',
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16.0,
                            ), // Spacing between buttons
                            OutlinedButton(
                              onPressed: () {
                                // Prepare dashboard data to send
                                final groupedExpenses =
                                    _getExpensesByCategoryAndYear();
                                final totalIncome = _getTotalIncomeForYear();

                                // Format data for JSON
                                final dashboardData = {
                                  'year': _selectedYear,
                                  'totalIncome': totalIncome,
                                  'expensesByCategory': groupedExpenses.map(
                                    (category, expenses) => MapEntry(
                                      category,
                                      expenses
                                          .map((expense) => expense.toJson())
                                          .toList(),
                                    ),
                                  ), // Assuming Expense model has toJson()
                                };

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => FillingPage(
                                          dashboardData: dashboardData,
                                        ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: kColorComponent),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                              ),
                              child: const Text(
                                'Proceed to Tax Relief Filing',
                                style: TextStyle(
                                  color: kColorPrimary,
                                  fontFamily: 'Poppins',
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ], // Closing bracket for the Column's children
                  ),
                ),
              ),
    );
  }
}
