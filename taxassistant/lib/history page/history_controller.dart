import '../models/mock_data.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  // Mock Expense Data
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
    // December 2024
    Expense(
      vendor: 'Grocery Store',
      date: '2024-12-05',
      total: 250.00,
      fullText: 'Weekly groceries',
      category: 'Lifestyle & Daily Living',
    ),
    Expense(
      vendor: 'Electricity Bill',
      date: '2024-12-20',
      total: 180.00,
      fullText: 'Monthly electricity usage',
      category: 'Housing',
    ),
    // November 2024
    Expense(
      vendor: 'Restaurant',
      date: '2024-11-10',
      total: 80.00,
      fullText: 'Dinner with friends',
      category: 'Lifestyle & Daily Living',
    ),
    // October 2024
    Expense(
      vendor: 'Online Course',
      date: '2024-10-15',
      total: 500.00,
      fullText: 'Professional development course',
      category: 'Retirement & Investment',
    ),
  ];

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
}
