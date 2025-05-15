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

// Updated Mock Expense Data for Tax Relief Categories
final List<Expense> mockExpenses = [
  Expense(
    vendor: 'Popular Bookstore',
    date: '2025-05-01',
    total: 120.00,
    fullText: 'Purchase of books and reference materials',
    category: 'Lifestyle & Daily Living',
  ),
  Expense(
    vendor: 'Machines Malaysia',
    date: '2025-05-02',
    total: 4300.00,
    fullText: 'New MacBook Air for work and study',
    category: 'Lifestyle & Daily Living',
  ),
  Expense(
    vendor: 'Fitness First',
    date: '2025-05-03',
    total: 180.00,
    fullText: 'Monthly gym membership',
    category: 'Lifestyle & Daily Living',
  ),
  Expense(
    vendor: 'Maxis Internet',
    date: '2025-05-04',
    total: 120.00,
    fullText: 'Monthly broadband bill',
    category: 'Lifestyle & Daily Living',
  ),
  Expense(
    vendor: 'Marathon Malaysia',
    date: '2025-05-05',
    total: 90.00,
    fullText: 'Marathon registration fee',
    category: 'Lifestyle & Daily Living',
  ),
  Expense(
    vendor: 'Babyland Store',
    date: '2025-05-06',
    total: 800.00,
    fullText: 'Electric breast pump and accessories',
    category: 'Childcare & Parenting',
  ),
  Expense(
    vendor: 'Little Star Kindergarten',
    date: '2025-05-07',
    total: 900.00,
    fullText: 'Monthly childcare fee',
    category: 'Childcare & Parenting',
  ),
  Expense(
    vendor: 'PTPTN SSPN-i',
    date: '2025-05-08',
    total: 3000.00,
    fullText: 'Education savings deposit',
    category: 'Retirement & Investment',
  ),
  Expense(
    vendor: 'Pantai Hospital',
    date: '2025-05-09',
    total: 620.00,
    fullText: 'Specialist consultation and medication',
    category: 'Medical & Health',
  ),
  Expense(
    vendor: 'Guardian Pharmacy',
    date: '2025-05-10',
    total: 150.00,
    fullText: 'Medical supplies and supplements',
    category: 'Medical & Health',
  ),
  Expense(
    vendor: 'AIA Insurance',
    date: '2025-05-11',
    total: 2400.00,
    fullText: 'Annual medical and education insurance premium',
    category: 'Retirement & Investment',
  ),
  Expense(
    vendor: 'PRSB Malaysia',
    date: '2025-05-12',
    total: 3000.00,
    fullText: 'Private retirement scheme contribution',
    category: 'Retirement & Investment',
  ),
  Expense(
    vendor: 'EV ChargeGo',
    date: '2025-05-13',
    total: 60.00,
    fullText: 'Electric vehicle charging fee',
    category: 'Lifestyle & Daily Living',
  ),
  Expense(
    vendor: 'Tesla Malaysia',
    date: '2025-05-13',
    total: 2300.00,
    fullText: 'Home EV wall charger purchase',
    category: 'Lifestyle & Daily Living',
  ),
  Expense(
    vendor: 'Maybank Home Loan',
    date: '2025-05-14',
    total: 480.00,
    fullText: 'Monthly interest payment on housing loan (1st home)',
    category: 'Housing',
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
