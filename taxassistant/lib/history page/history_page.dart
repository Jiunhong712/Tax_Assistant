import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'history_controller.dart';
import '../models/mock_data.dart'; // Import Expense and Income models
import '../upload page/upload_page.dart'; // Import UploadPage
import '../profile_page.dart'; // Import ProfilePage
import '../constants.dart'; // Import constants
import 'package:intl/intl.dart'; // Import for date formatting
import 'dart:convert'; // For JSON encoding
import 'dart:io'; // For file operations
import 'package:http/http.dart' as http; // Import http package
import 'package:taxassistant/main.dart';
import 'package:path_provider/path_provider.dart'; // For getting directory paths
import 'package:permission_handler/permission_handler.dart'; // For permission handling
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'dart:html' show Blob, Url, AnchorElement; // For web-specific APIs

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryController historyController = Get.find<HistoryController>();
  bool _showIncome = true; // State to toggle between Income and Expenses
  DateTime? _selectedIncomeMonth =
      DateTime.now(); // State for selected month for income
  String _selectedExpenseCategory =
      'All'; // State for selected expense category
  DateTime? _selectedExpenseMonth; // State for selected month for expenses
  int _selectedYear =
      DateTime.now().year; // State for selected year for summary
  final List<dynamic> _selectedTransactions =
      []; // State for selected transactions

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
  }

  @override
  Widget build(BuildContext context) {
    // Calculate summary values for the selected year
    final double totalExpenses = historyController.mockExpenses
        .where((expense) => DateTime.parse(expense.date).year == _selectedYear)
        .fold(0.0, (sum, expense) => sum + expense.total);
    final double totalIncome = historyController.mockIncome
        .where((income) => DateTime.parse(income.date).year == _selectedYear)
        .fold(0.0, (sum, income) => sum + income.total);

    // Filter transactions based on selected view and filters
    final filteredTransactions =
        _showIncome
            ? historyController.mockIncome.where((dynamic transaction) {
              if (_selectedIncomeMonth == null) {
                return true; // No filter applied
              }
              final incomeDate = DateTime.parse((transaction as Income).date);
              return incomeDate.year == _selectedIncomeMonth!.year &&
                  incomeDate.month == _selectedIncomeMonth!.month;
            }).toList()
            : historyController.mockExpenses.where((dynamic transaction) {
              if (_selectedExpenseCategory != 'All' &&
                  (transaction as Expense).category !=
                      _selectedExpenseCategory) {
                return false; // Category filter
              }
              if (_selectedExpenseMonth == null) {
                return true; // No month filter applied
              }
              final expenseDate = DateTime.parse((transaction as Expense).date);
              return expenseDate.year == _selectedExpenseMonth!.year &&
                  expenseDate.month == _selectedExpenseMonth!.month;
            }).toList();

    // Group filtered transactions by date
    final Map<String, List<dynamic>> groupedTransactions =
        {}; // Use dynamic to handle both Income and Expense
    filteredTransactions.sort(
      (a, b) => DateTime.parse(
        (b as dynamic).date,
      ).compareTo(DateTime.parse((a as dynamic).date)),
    ); // Sort by date descending

    for (var transaction in filteredTransactions) {
      if (groupedTransactions.containsKey((transaction as dynamic).date)) {
        groupedTransactions[(transaction as dynamic).date]!.add(transaction);
      } else {
        groupedTransactions[(transaction as dynamic).date] = [transaction];
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'History',
          style: TextStyle(
            color: kColorPrimary,
            fontFamily: 'Poppins',
          ), // Set title color to white
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_circle,
              color: kColorPrimary,
            ), // Profile icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.file_download, // Corrected icon name
              color: kColorPrimary,
            ), // Export icon
            onPressed: _exportSelectedTransactions,
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Section (Expenses, Income)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                            if (_selectedIncomeMonth != null) {
                              _selectedIncomeMonth = DateTime(
                                _selectedYear,
                                _selectedIncomeMonth!.month,
                              );
                            }
                            if (_selectedExpenseMonth != null) {
                              _selectedExpenseMonth = DateTime(
                                _selectedYear,
                                _selectedExpenseMonth!.month,
                              );
                            }
                          });
                        },
                      ),
                      Text(
                        _selectedYear.toString(),
                        style: TextStyle(
                          color: kColorPrimary,
                          fontFamily: 'Poppins',
                          fontSize:
                              Theme.of(context).textTheme.titleLarge!.fontSize,
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
                            if (_selectedIncomeMonth != null) {
                              _selectedIncomeMonth = DateTime(
                                _selectedYear,
                                _selectedIncomeMonth!.month,
                              );
                            }
                            if (_selectedExpenseMonth != null) {
                              _selectedExpenseMonth = DateTime(
                                _selectedYear,
                                _selectedExpenseMonth!.month,
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem(
                        'Expenses $_selectedYear',
                        '-RM ${totalExpenses.toStringAsFixed(2)}',
                        Colors.red, // Use red color for expenses
                        () {
                          setState(() {
                            _showIncome = false;
                            _selectedIncomeMonth = null; // Reset income filter
                            _selectedExpenseMonth =
                                DateTime.now(); // Set expense month to current month
                          });
                        },
                        !_showIncome, // isSelected
                      ),
                      _buildSummaryItem(
                        'Income $_selectedYear',
                        'RM ${totalIncome.toStringAsFixed(2)}',
                        Colors.green, // Use green color for income
                        () {
                          setState(() {
                            _showIncome = true;
                            _selectedExpenseCategory =
                                'All'; // Reset expense filters
                            _selectedExpenseMonth = null;
                            _selectedIncomeMonth =
                                DateTime.now(); // Set income month to current month
                          });
                        },
                        _showIncome, // isSelected
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            // Filtering Options
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child:
                  _showIncome ? _buildIncomeFilter() : _buildExpenseFilters(),
            ),
            const Divider(),
            // Transactions List
            Expanded(
              child: ListView.builder(
                itemCount: groupedTransactions.keys.length,
                itemBuilder: (context, index) {
                  final date = groupedTransactions.keys.elementAt(index);
                  final transactions = groupedTransactions[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          _formatDateHeader(date),
                          style: TextStyle(
                            color: kColorPrimary, // Apply primary color
                            fontFamily: 'Poppins', // Apply Poppins font
                            fontSize:
                                Theme.of(
                                  context,
                                ).textTheme.titleMedium!.fontSize,
                            fontWeight:
                                Theme.of(
                                  context,
                                ).textTheme.titleMedium!.fontWeight,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, transactionIndex) {
                          final transaction = transactions[transactionIndex];
                          // Safely access properties based on type
                          String vendor = '';
                          String category = '';
                          double total = 0.0;
                          bool isExpense = false;

                          if (transaction is Expense) {
                            vendor = transaction.vendor;
                            category = transaction.category;
                            total = transaction.total;
                            isExpense = true;
                          } else if (transaction is Income) {
                            vendor = transaction.vendor;
                            category = transaction.category;
                            total = transaction.total;
                            isExpense = false;
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: kColorComponent,
                              ), // Apply border color
                              borderRadius: BorderRadius.circular(
                                8.0,
                              ), // Apply border radius
                            ),
                            child: CheckboxListTile(
                              value: _selectedTransactions.contains(
                                transaction,
                              ),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    _selectedTransactions.add(transaction);
                                  } else {
                                    _selectedTransactions.remove(transaction);
                                  }
                                });
                              },
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    vendor,
                                    style: TextStyle(
                                      color: kColorPrimary,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    '${isExpense ? '-' : '+'}RM ${total.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color:
                                          isExpense ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                category,
                                style: TextStyle(
                                  color: kColorPrimary,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton.extended(
          onPressed: () {
            // Navigate to UploadPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
          label: const Text(
            'Add new',
            style: TextStyle(fontFamily: 'Poppins'),
          ), // Apply Poppins font
          icon: const Icon(Icons.add),
          backgroundColor: kColorAccent, // Apply accent color
        ),
      ),
    );
  }

  Future<void> _exportSelectedTransactions() async {
    if (_selectedTransactions.isEmpty) {
      // Show a message to the user that no transactions are selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions selected for export.')),
      );
      return;
    }

    if (kIsWeb) {
      // Web-specific export logic
      for (var transaction in _selectedTransactions) {
        String fileName = '';
        String content = '';
        String transactionType = '';

        if (transaction is Expense) {
          transactionType = 'expense';
          fileName =
              '${transaction.vendor}_${transaction.date.replaceAll('-', '_')}.txt';
          content = '''
Vendor: ${transaction.vendor}
Category: ${transaction.category}
Total: ${transaction.total.toStringAsFixed(2)}
Date: ${transaction.date}
''';
        } else if (transaction is Income) {
          transactionType = 'income';
          fileName =
              '${transaction.vendor}_${transaction.date.replaceAll('-', '_')}.txt';
          content = '''
Vendor: ${transaction.vendor}
Category: ${transaction.category}
Total: ${transaction.total.toStringAsFixed(2)}
Date: ${transaction.date}
''';
        }

        if (transactionType.isNotEmpty) {
          // Create a blob from the content
          final blob = Blob([content], 'text/plain');
          // Create a download link
          final url = Url.createObjectUrlFromBlob(blob);
          final anchor =
              AnchorElement(href: url)
                ..setAttribute('download', fileName)
                ..click();
          // Revoke the object URL
          Url.revokeObjectUrl(url);
        }
      }
      // Show a success message for web
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected transactions downloaded successfully!'),
        ),
      );
    } else {
      // Mobile/Desktop export logic
      // Request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        try {
          // Get the documents directory
          final directory = await getApplicationDocumentsDirectory();
          final taxlyDirectory = Directory('${directory.path}/taxly');
          final expensesDirectory = Directory(
            '${taxlyDirectory.path}/expenses',
          );
          final incomeDirectory = Directory('${taxlyDirectory.path}/income');

          // Create directories if they don't exist
          if (!await taxlyDirectory.exists()) {
            await taxlyDirectory.create(recursive: true);
          }
          if (!await expensesDirectory.exists()) {
            await expensesDirectory.create(recursive: true);
          }
          if (!await incomeDirectory.exists()) {
            await incomeDirectory.create(recursive: true);
          }

          for (var transaction in _selectedTransactions) {
            String fileName = '';
            String content = '';
            String monthYear = DateFormat(
              'MMM_yyyy',
            ).format(DateTime.parse((transaction as dynamic).date));
            String transactionType = '';

            if (transaction is Expense) {
              transactionType = 'expenses';
              fileName =
                  '${transaction.vendor}_${transaction.date.replaceAll('-', '_')}.txt';
              content = '''
Vendor: ${transaction.vendor}
Category: ${transaction.category}
Total: ${transaction.total.toStringAsFixed(2)}
Date: ${transaction.date}
''';
            } else if (transaction is Income) {
              transactionType = 'income';
              fileName =
                  '${transaction.vendor}_${transaction.date.replaceAll('-', '_')}.txt';
              content = '''
Vendor: ${transaction.vendor}
Category: ${transaction.category}
Total: ${transaction.total.toStringAsFixed(2)}
Date: ${transaction.date}
''';
            }

            if (transactionType.isNotEmpty) {
              final exportDirectory = Directory(
                '${taxlyDirectory.path}/$transactionType/${monthYear.toLowerCase()}',
              );
              if (!await exportDirectory.exists()) {
                await exportDirectory.create(recursive: true);
              }
              final file = File('${exportDirectory.path}/$fileName');
              await file.writeAsString(content);
            }
          }

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected transactions exported successfully!'),
            ),
          );
        } catch (e) {
          // Show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error exporting transactions: $e')),
          );
        }
      } else {
        // Show a message if permission is denied
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied. Cannot export.'),
          ),
        );
      }
    }
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    Color color,
    VoidCallback onTap,
    bool isSelected,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border:
              isSelected
                  ? Border.all(
                    color: kColorComponent,
                    width: 5.0,
                  ) // Increased border width
                  : null, // Add border if selected
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color:
                    title == 'Expenses'
                        ? Colors.red
                        : Colors
                            .green, // Apply red for expenses, green for income
                fontFamily: 'Poppins', // Apply Poppins font
                fontSize: Theme.of(context).textTheme.titleSmall!.fontSize,
                fontWeight: Theme.of(context).textTheme.titleSmall!.fontWeight,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              value,
              style: TextStyle(
                color:
                    color, // Use the passed color (red for expenses, green for income)
                fontFamily: 'Poppins', // Apply Poppins font
                fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, color: kColorPrimary, size: 20.0),
          onPressed: () {
            setState(() {
              _selectedIncomeMonth =
                  _selectedIncomeMonth == null
                      ? DateTime.now().subtract(
                        const Duration(days: 30),
                      ) // Approximate a month
                      : DateTime(
                        _selectedIncomeMonth!.year,
                        _selectedIncomeMonth!.month - 1,
                      );
            });
          },
        ),
        InkWell(
          onTap: _selectIncomeMonth,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: kColorComponent), // Add border
              borderRadius: BorderRadius.circular(8.0), // Add border radius
            ),
            child: Text(
              _selectedIncomeMonth == null
                  ? DateFormat('MMMM').format(
                    DateTime.now(),
                  ) // Default to current month
                  : DateFormat('MMMM').format(_selectedIncomeMonth!),
              style: TextStyle(fontFamily: 'Poppins', color: kColorPrimary),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: kColorPrimary, size: 20.0),
          onPressed: () {
            setState(() {
              _selectedIncomeMonth =
                  _selectedIncomeMonth == null
                      ? DateTime.now().add(
                        const Duration(days: 30),
                      ) // Approximate a month
                      : DateTime(
                        _selectedIncomeMonth!.year,
                        _selectedIncomeMonth!.month + 1,
                      );
            });
          },
        ),
      ],
    );
  }

  Widget _buildExpenseFilters() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedExpenseCategory,
              dropdownColor: Colors.white, // Set dropdown background to white
              items:
                  _availableExpenseCategories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: kColorPrimary,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedExpenseCategory = newValue;
                  });
                }
              },
            ),
            const SizedBox(width: 16.0),
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: kColorPrimary,
                size: 20.0,
              ),
              onPressed: () {
                setState(() {
                  _selectedExpenseMonth =
                      _selectedExpenseMonth == null
                          ? DateTime.now().subtract(
                            const Duration(days: 30),
                          ) // Approximate a month
                          : DateTime(
                            _selectedExpenseMonth!.year,
                            _selectedExpenseMonth!.month - 1,
                          );
                });
              },
            ),
            InkWell(
              onTap: _selectExpenseMonth,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: kColorComponent), // Add border
                  borderRadius: BorderRadius.circular(8.0), // Add border radius
                ),
                child: Text(
                  _selectedExpenseMonth == null
                      ? DateFormat('MMMM').format(
                        DateTime.now(),
                      ) // Default to current month
                      : DateFormat('MMMM').format(_selectedExpenseMonth!),
                  style: TextStyle(fontFamily: 'Poppins', color: kColorPrimary),
                ),
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
                  _selectedExpenseMonth =
                      _selectedExpenseMonth == null
                          ? DateTime.now().add(
                            const Duration(days: 30),
                          ) // Approximate a month
                          : DateTime(
                            _selectedExpenseMonth!.year,
                            _selectedExpenseMonth!.month + 1,
                          );
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectIncomeMonth() async {
    await _showMonthPicker(context, _selectedIncomeMonth, (pickedMonth) {
      setState(() {
        _selectedIncomeMonth = pickedMonth;
      });
    });
  }

  Future<void> _selectExpenseMonth() async {
    await _showMonthPicker(context, _selectedExpenseMonth, (pickedMonth) {
      setState(() {
        _selectedExpenseMonth = pickedMonth;
      });
    });
  }

  Future<void> _showMonthPicker(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onMonthSelected,
  ) async {
    DateTime selectedDate = initialDate ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = initialDate ?? DateTime.now();
        return AlertDialog(
          backgroundColor: Colors.white,
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: 300.0, // Adjust width as needed
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Month Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final month = index + 1;
                        final monthDate = DateTime(selectedDate.year, month);
                        final isSelected = selectedDate.month == month;
                        return ElevatedButton(
                          onPressed: () {
                            onMonthSelected(monthDate);
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected ? kColorAccent : Colors.grey[300],
                          ),
                          child: Text(
                            DateFormat('MMM').format(monthDate),
                            style: TextStyle(
                              color: isSelected ? Colors.white : kColorPrimary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatDateHeader(String date) {
    final today = DateTime.now();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final transactionDate = DateTime.parse(date);

    if (transactionDate.year == today.year &&
        transactionDate.month == today.month &&
        transactionDate.day == today.day) {
      return 'TODAY';
    } else if (transactionDate.year == yesterday.year &&
        transactionDate.month == yesterday.month &&
        transactionDate.day == yesterday.day) {
      return 'YESTERDAY';
    } else {
      // Format as "Month Day"
      return '${_getMonthName(transactionDate.month)} ${transactionDate.day}';
    }
  }

  String _getMonthName(int month) {
    const monthNames = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month];
  }
}
