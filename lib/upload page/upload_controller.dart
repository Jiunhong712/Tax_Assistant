import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // Required for Uint8List
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html; // For web download
import 'package:get/get.dart'; // Import GetX
import '../data.dart';

class UploadController extends GetxController {
  var _pickedFile = Rx<PlatformFile?>(null);
  var _isLoading = false.obs;
  var _processedExpense = Rx<Expense?>(null); // Use the Expense model
  var _reminderMessage = ''.obs;
  var isDocumentProcessed = false.obs;

  PlatformFile? get pickedFile => _pickedFile.value;
  bool get isLoading => _isLoading.value;
  Expense? get processedExpense => _processedExpense.value;
  String get reminderMessage => _reminderMessage.value;

  @override
  void onInit() {
    super.onInit();
    _calculateReminder();
  }

  void _calculateReminder() {
    final now = DateTime.now();
    final filingStartDate = DateTime(2025, 3, 1);
    final filingEndDate = DateTime(2025, 12, 31);
    final currentMonth = now.month;

    String message = '';

    if (now.isBefore(filingStartDate)) {
      final difference = filingStartDate.difference(now);
      final days = difference.inDays;
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      message =
          '$months months and $remainingDays days until filing opens. Start tracking your deductible expenses like broadband, books, and insurance.';
    } else if (now.isAfter(filingEndDate)) {
      message =
          'The 2026 tax filing period has ended. Remember to store all receipts for next year’s claim.';
    } else {
      final daysLeft = filingEndDate.difference(now).inDays;
      message = '$daysLeft days remaining to file your 2025 taxes.';

      // Add time-sensitive reminders
      if (now.day == 1) {
        message +=
            '\n🔁 Reminder: Upload your monthly receipts (e.g. internet, gym, books).';
      }

      if (currentMonth >= 10 && currentMonth <= 12) {
        message +=
            '\n🕒 Year-end tip: Contribute to PRS or SSPN now to maximize RM8,000 relief.';
      }

      if (currentMonth == 12) {
        message +=
            '\n🚨 Final month to submit claims and maximize tax relief. Don’t miss EV charger, insurance, or SSPN deductions!';
      }
    }

    _reminderMessage.value = message;
  }

  Future<void> pickFile() async {
    _isLoading.value = true;
    _processedExpense.value = null; // Reset processed expense

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;
        _pickedFile.value = file;
        await _uploadAndProcess(file);
      } else {
        // User canceled the picker
        _isLoading.value = false;
      }
    } catch (e) {
      print('Error picking file: $e');
      _isLoading.value = false;
    }
  }

  Future<void> _uploadAndProcess(PlatformFile file) async {
    // Mock: Simulate uploading to Alibaba Cloud OSS
    print('Simulating upload to OSS: ${file.name}');
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    // Mock: Simulate calling the /process-receipt endpoint
    print('Simulating calling /process-receipt endpoint');
    await Future.delayed(const Duration(seconds: 3)); // Simulate network delay

    // Use mock OCR Result from mock_data.dart
    final ocrData = mockOcrData;

    // Create an Expense object
    final expense = Expense(
      vendor: ocrData['vendor']!,
      date: ocrData['date']!,
      total: double.parse(ocrData['total']!),
      fullText: ocrData['fullText']!,
    );

    // Categorize the expense
    _categorizeExpense(expense);

    // Add the expense to the provider
    // This part still needs context from the UI or a separate provider
    // For now, I'll leave it here and address it when refactoring the UI.
    // Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);

    _processedExpense.value = expense;
    _isLoading.value = false;
    isDocumentProcessed.value = true; // Set to true after processing
  }

  void _categorizeExpense(Expense expense) {
    expense.category = "Lifestyle & Daily Living";
  }

  void editCategory(Expense expense) {
    // Placeholder for category editing functionality
    print('Editing category for ${expense.vendor}');
    // In a real app, this would show a dialog or navigate to a new page
  }

  void resetUploadPage() {
    _pickedFile.value = null;
    _isLoading.value = false;
    _processedExpense.value = null;
    isDocumentProcessed.value = false;
  }

  // Function to calculate monthly summary (simple example)
  Map<String, double> getMonthlySummary(List<Expense> expenses) {
    final Map<String, double> monthlySummary = {};
    for (var expense in expenses) {
      // Assuming date is in 'YYYY-MM-DD' format
      final month = expense.date.substring(0, 7);
      monthlySummary.update(
        month,
        (value) => value + expense.total,
        ifAbsent: () => expense.total,
      );
    }
    return monthlySummary;
  }

  void showDeductionSuggestions(BuildContext context, Expense expense) {
    // Placeholder for showing deduction suggestions
    print('Showing deduction suggestions for ${expense.vendor}');
    // In a real app, this would show a dialog or bottom sheet with suggestions
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tax Deduction Suggestions'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Suggestions for ${expense.vendor}:'),
                const SizedBox(height: 10),
                // Mock suggestions based on category
                if (expense.category == 'Computers')
                  const Text(
                    '- Deductible: RM 240 (Computers allowance: 20% initial)',
                  ),
                if (expense.category == 'Food')
                  const Text('- Food expenses are generally not deductible.'),
                if (expense.category == 'Travel')
                  const Text(
                    '- Travel expenses may be deductible if for business purposes.',
                  ),
                const SizedBox(height: 10),
                const Text('- Lifestyle relief: RM 2,500 max.'),
                const Text('- Self relief: RM 9,000.'),
                const Text('- Child relief: RM 2,000 per child.'),
                // Add more suggestions based on tax tables and user input
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
