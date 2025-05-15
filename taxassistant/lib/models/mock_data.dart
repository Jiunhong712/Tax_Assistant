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

// Mock Expense Data
final List<Expense> mockExpenses = [
  Expense(
    vendor: 'Mock Cafe',
    date: '2025-05-10',
    total: 25.50,
    fullText: 'Coffee and pastry',
    category: 'Food',
  ),
  Expense(
    vendor: 'Mock Grab',
    date: '2025-05-11',
    total: 15.00,
    fullText: 'Ride to office',
    category: 'Travel',
  ),
  Expense(
    vendor: 'Mock Bookstore',
    date: '2025-05-12',
    total: 50.00,
    fullText: 'Business book',
    category: 'Education',
  ),
  Expense(
    vendor: 'Mock Restaurant',
    date: '2025-05-13',
    total: 75.20,
    fullText: 'Business lunch',
    category: 'Food',
  ),
  Expense(
    vendor: 'Mock Train',
    date: '2025-05-14',
    total: 10.00,
    fullText: 'Train ticket',
    category: 'Travel',
  ),
];

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
