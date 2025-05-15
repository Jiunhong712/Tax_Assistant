import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense_provider.dart';
import 'dart:convert'; // For JSON encoding
import '../models/mock_data.dart'; // Import mock data

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  List<ChatMessage> _messages = [];

  // Fixed prompt to be sent to the API
  final String _fixedPrompt = '''
System Prompt: You are Grok 3, built by xAI, designed to assist with an Expense Tracker & Tax Assistant for freelancers in Malaysia. You have access to the following tax data extracted from the 'BBFT2013 Taxation Tax Tables.doc' document, effective as of May 14, 2025. Use this data to provide accurate tax-related calculations, suggestions, and information when assisting users. Prioritize resident individual tax rates and reliefs unless specified otherwise, and consider local Malaysian context (e.g., RM currency, Inland Revenue Board rules). If a query involves tax filing, expense categorization, or deductions, apply this data to generate summaries or reports. Refuse to answer any questions or topics that are not related to tax, and respond with: 'I'm sorry, I can only assist with tax-related queries. Please ask about tax calculations, deductions, or tax filing assistance.'

Tax Data Reference:  
Income Tax Rates:  
Resident Individual:  
0 - 5,000: 0% (0 RM)  
5,001 - 20,000: 1% on next 15,000 (150 RM)  
20,001 - 35,000: 3% on next 15,000 (450 RM)  
35,001 - 50,000: 6% on next 15,000 (900 RM)  
50,001 - 70,000: 11% on next 20,000 (2,200 RM)  
70,001 - 100,000: 19% on next 30,000 (5,700 RM)  
100,001 - 400,000: 25% on next 300,000 (75,000 RM)  
400,001 - 600,000: 26% on next 200,000 (52,000 RM)  
600,001 - 2,000,000: 28% on next 1,400,000 (392,000 RM)  
Exceeding 2,000,000: 30% on remainder  
Cumulative: On First 5,000 (0 RM), 20,000 (150 RM), 35,000 (600 RM), 50,000 (1,500 RM), 70,000 (3,700 RM), 100,000 (9,400 RM), 400,000 (84,400 RM), 600,000 (136,400 RM), 2,000,000 (528,400 RM)  
Resident Company (small, paid-up capital ≤ RM2.5M, income ≤ RM50M): First 150,000: 15%, Next 450,000: 17%, Remainder: 24%  
Resident Company (large, paid-up capital > RM2.5M or income > RM50M): 24%  
Non-resident Company/Individual: 24% / 30%  
Motorcars and Benefits-in-Kind (BIK):  
Cost (RM): Annual BIK (RM) / Fuel (RM)  
Up to 50,000: 1,200 / 600  
50,001 - 75,000: 2,400 / 900  
75,001 - 100,000: 3,600 / 1,200  
100,001 - 150,000: 5,000 / 1,500  
150,001 - 200,000: 7,000 / 1,800  
200,001 - 250,000: 9,000 / 2,100  
250,001 - 350,000: 15,000 / 2,400  
350,001 - 500,000: 21,250 / 2,700  
500,001+: 25,000 / 3,000  
Cars > 5 years old: BIK halved, fuel unchanged.  
Household Furnishings (Annual, RM):  
Semi-furnished (lounge/dining/bedroom): 840 (70/month)  
Semi-furnished + AC/curtains/carpets: 1,680 (140/month)  
Fully-furnished + kitchen equipment: 3,360 (280/month)  
Other Benefits (Annual, RM):  
Driver: 7,200  
Gardener: 3,600  
Domestic servant: 4,800  
Personal Reliefs (Annual, RM):  
Self: 9,000  
Self (disabled): +6,000  
Spouse: 4,000  
Spouse (disabled): +5,000  
Child (basic): 2,000 each  
Child (higher): 8,000 each  
Disabled child: 6,000 each  
Disabled child (additional): +8,000 each  
Medical/parental care: 8,000 max  
Serious disease/fertility treatment: 10,000 max  
Skills/qualifications course: 7,000 max  
Basic supporting equipment: 6,000 max  
Takaful/life insurance/EPF: 3,000 max  
Approved funds/schemes: 4,000 max  
Private retirement scheme: 3,000 max  
Education/medical insurance: 3,000 max  
Childcare (<6 years): 3,000 max  
Breastfeeding equipment: 1,000 max  
SSPN deposit: 8,000 max  
SOCSO/EIS: 350 max  
Lifestyle relief: 2,500 max  
Sports equipment/activities: 1,000 max  
EV charging facilities: 2,500 max  
Tax Rebates (RM):  
Individual (income ≤ 35,000): 400  
Spouse (income ≤ 35,000): 400  
Zakat/Fitrah: Amount paid  
Capital Allowances (%):  
Industrial buildings: Initial 10%, Annual 3%  
Plant/machinery: Initial 20%, Annual 14%  
Motor vehicles/heavy machinery: Initial 20%, Annual 20%  
Office equipment/furniture: Initial 20%, Annual 10%  
Computers/software: Initial 20%, Annual 20%  
Sales/Service Tax (%):  
Sales tax: 5% or 10%  
Service tax: 6% or 8%  
Real Property Gains Tax (%):  
Disposal within 3 years: 30% (all)  
4th year: 20% (citizen/PR), 30% (non-citizen/non-PR)  
5th year: 15% (citizen/PR), 30% (non-citizen/non-PR)  
6th year+: 10% (citizen/PR), 0% (non-citizen/PR), 10% (others)  
Stamp Duty (%):  
Conveyance/transfer:  
First 100,000: 1%  
Next 400,000: 2%  
Next 500,000: 3%  
Excess 1,000,000: 4%  

Guidelines:  
Use this data to calculate taxes, suggest deductions, or categorize expenses for freelancers. For expense tracking, prioritize BIK, furnishings, and other benefits as potential deductions. Suggest tax reliefs based on user inputs (e.g., children, medical expenses). If data is insufficient, ask the user for clarification (e.g., chargeable income, car cost). Align responses with the hackathon project’s goals: OCR-based receipt processing, expense categorization, tax deduction suggestions, and exportable income reports. Refuse to answer any questions or topics that are not related to tax, and respond with: 'I'm sorry, I can only assist with tax-related queries. Please ask about tax calculations, deductions, or tax filing assistance.'
''';

  @override
  void initState() {
    super.initState();
    // Add mock welcome messages
    _messages.add(
      ChatMessage(text: 'Welcome! How can I help you today?', isUser: false),
    );
    _messages.add(
      ChatMessage(
        text:
            'I can help you summarize your expenses and suggest potential tax deductions.',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      // Add user's message to the chat
      _messages.add(ChatMessage(text: _textController.text, isUser: true));
      _textController.clear(); // Clear the input field
    });

    // Get expense data from provider
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final List<Expense> expenses = expenseProvider.expenses;

    // Prepare data for API call
    final List<Map<String, dynamic>> expensesData =
        expenses
            .map(
              (expense) => {
                'vendor': expense.vendor,
                'date': expense.date,
                'total': expense.total,
                'category': expense.category,
                'fullText': expense.fullText,
              },
            )
            .toList();

    // Combine prompt and expense data
    final requestData = {'prompt': _fixedPrompt, 'expenses': expensesData};

    // Mock API call to Alibaba Studio
    print('Mocking API call to Alibaba Studio with data:');
    print(jsonEncode(requestData));

    await Future.delayed(const Duration(seconds: 3)); // Simulate network delay

    // Use mock API response from mock_data.dart
    const mockApiResponse = mockChatbotApiResponse;

    setState(() {
      final deductions = mockApiResponse['deductions'] as List<String>;
      final apiResponseText =
          'Summary: ${mockApiResponse['summary']}\n\nDeductions:\n${deductions.join('\n')}';
      _messages.add(
        ChatMessage(text: apiResponseText, isUser: false),
      ); // Add chatbot response
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Chatbot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatMessageBubble(
                    text: message.text,
                    isUser: message.isUser,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your tax query...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendRequest,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessageBubble({Key? key, required this.text, required this.isUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
