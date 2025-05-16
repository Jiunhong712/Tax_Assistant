// Define a simple Expense model
class Expense {
  final String vendor;
  final String date;
  final double total;
  final String fullText;
  String category; // Make category editable

  Expense({
    required this.vendor,
    required this.date,
    required this.total,
    required this.fullText,
    this.category = 'Uncategorized', // Default category
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      vendor: json['vendor'],
      date: json['date'],
      total: json['total'].toDouble(),
      fullText: json['fullText'],
      category: json['category'] ?? 'Uncategorized',
    );
  }
}

// Define a simple Income model
class Income {
  final String vendor;
  final String date;
  final double total;
  final String fullText;
  String category; // Make category editable

  Income({
    required this.vendor,
    required this.date,
    required this.total,
    required this.fullText,
    this.category = 'Uncategorized', // Default category
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      vendor: json['vendor'],
      date: json['date'],
      total: json['total'].toDouble(),
      fullText: json['fullText'],
      category: json['category'] ?? 'Uncategorized',
    );
  }
}

// Mock Chatbot API Response
const Map<String, dynamic> mockChatbotApiResponse = {
  'summary': 'Total expenses: RM 300.00. Food: RM 150.00, Travel: RM 150.00.',
  'deductions': [
    'Travel expenses may be deductible if for business purposes.',
    'Food expenses are generally not deductible.',
  ],
};

// Mock OCR Data
const Map<String, String> mockOcrData = {
  'vendor': 'Mock Restaurant',
  'date': '2025-05-15',
  'total': '150.50',
  'fullText':
      'This is mock OCR text for a meal at Mock Restaurant. Taxi ride home.',
};
