import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard
import 'package:http/http.dart' as http;
import 'dart:convert';

class FillingPage extends StatefulWidget {
  final Map<String, dynamic> dashboardData; // Add dashboardData parameter

  const FillingPage({Key? key, required this.dashboardData}) : super(key: key);

  @override
  _FillingPageState createState() => _FillingPageState();
}

class _FillingPageState extends State<FillingPage> {
  List<Map<String, dynamic>> taxReliefData = []; // Change to a list
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _callChatbotService();
  }

  Future<void> _callChatbotService() async {
    setState(() {
      _isLoading = true;
      taxReliefData = []; // Clear previous data
    });

    final url = Uri.parse('http://127.0.0.1:5001/chatbot');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': '''
Return the final response in JSON format only. Do not include explanations, examples, or any text other than the JSON.
Return the result as JSON where:

  - `category`: the best-matching tax relief section
  - `value`: the value of the tax relief for that category

  Sample response:

  {
  "Medical & Health": {
    "category": "Medical expenses on fertility treatment (self or spouse)",
    "value": 100
  },
  "Medical & Health": {
    "category": "Medical expenses on fertility treatment (self or spouse)",
    "value": 100
  }
}


Use the following official tax relief categories as your classification reference:

1. Medical treatment, dental treatment, special needs and carer
2. Complete medical examination
3. Basic supporting equipment for disabled self, spouse, child or parent
4. Disabled individual
5. Other than a degree at masters or doctorate level – Course of study in law, accounting, islamic financing, technical, vocational, industrial, scientific or technology
6. Degree at masters or doctorate level - Any course of study
7. Course of study undertaken for the purpose of upskilling or self-enhancement conducted by a recognized body
8. Medical expenses on serious diseases for self, spouse or child
9. Medical expenses on fertility treatment for self or spouse
10. Medical expenses on vaccination for self, spouse and child
11. Dental examination and treatment on himself, husband / wife or child
12. Complete medical examination for self, spouse or child / COVID-19 detection test including purchase of self-detection test kit for self, spouse or child / Mental health examination or consultation for self, spouse or child 
13. Assessment for the purposes of diagnosis of learning disability / Early intervention programme or rehabilitation treatment for learning disability 
14. Lifestyle - Expenses for the use / benefit of self, spouse or child
15. Lifestyle – Additional relief for the use / benefit of self, spouse or child in respect
16. Child care fees to a registered child care centre / kindergarten for a child aged 6 years and below
17. Net deposit in Skim Simpanan Pendidikan Nasional
18. Life insurance premium / Contribution to EPF (voluntary) 
19. Contribution to EPF (voluntary or compulsory) / approved scheme 
20. Private retirement scheme and deferred annuity
21. Education and medical insurance
22. Contribution to the Social Security Organization (SOCSO) according to Employees Social Security Act 1969 or Employment Insurance System Act 2017
23. Payment of installation, rental, purchase including hire-purchase of equipment or subscription for use of electric vehicle charging facility for own vehicle (Not for business use)

Return the final response in JSON format only. Do not include explanations, examples, or any text other than the JSON.
''',
          'dashboardData': widget.dashboardData, // Include dashboard data
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // The Python service returns a JSON object with a 'response' key
        if (responseData is Map && responseData.containsKey('response')) {
          final jsonString = responseData['response'];
          try {
            final decodedJson = jsonDecode(jsonString);
            if (decodedJson is Map<String, dynamic>) {
              List<Map<String, dynamic>> extractedData = [];
              decodedJson.forEach((key, value) {
                if (value is Map<String, dynamic> &&
                    value.containsKey('category') &&
                    value.containsKey('value')) {
                  extractedData.add({
                    'category': value['category'],
                    'value': value['value'],
                  });
                }
              });
              setState(() {
                taxReliefData = extractedData;
              });
            } else {
              setState(() {
                // Handle unexpected format after decoding the string
                taxReliefData = [
                  {
                    'category':
                        'Error: Unexpected data format in response string',
                    'value': 0.0,
                  },
                ];
              });
            }
          } catch (e) {
            setState(() {
              // Handle error decoding the JSON string
              taxReliefData = [
                {
                  'category': 'Error: Failed to decode JSON string: $e',
                  'value': 0.0,
                },
              ];
            });
          }
        } else {
          setState(() {
            // Handle unexpected top-level response format
            taxReliefData = [
              {
                'category': 'Error: Invalid top-level response format',
                'value': 0.0,
              },
            ];
          });
        }
      } else {
        setState(() {
          taxReliefData = [
            {'category': 'Error: ${response.statusCode}', 'value': 0.0},
          ];
        });
      }
    } catch (e) {
      setState(() {
        taxReliefData = [
          {'category': 'Error: $e', 'value': 0.0},
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyValueToClipboard(double valueToCopy) {
    Clipboard.setData(ClipboardData(text: valueToCopy.toString()));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Value copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relief')),
      body: Center(
        child:
            _isLoading
                ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16.0),
                    Text('Generating report for eBE Form Page 4'),
                  ],
                )
                : ListView.builder(
                  // Use ListView.builder to display the list
                  itemCount: taxReliefData.length,
                  itemBuilder: (context, index) {
                    final item = taxReliefData[index];
                    final category = item['category'] ?? 'N/A';
                    final value = item['value'] ?? 0.0;

                    bool isParentExpense =
                        category ==
                            'Medical treatment, dental treatment, special needs and carer' ||
                        category == 'Complete medical examination';

                    bool isEducationFees =
                        category ==
                            'Other than a degree at masters or doctorate level – Course of study in law, accounting, islamic financing, technical, vocational, industrial, scientific or technology' ||
                        category ==
                            'Degree at masters or doctorate level - Any course of study' ||
                        category ==
                            'Course of study undertaken for the purpose of upskilling or self-enhancement conducted by a recognized body';

                    bool isLifeInsuranceAndEPF =
                        category ==
                            'Life insurance premium / Contribution to EPF (voluntary)' ||
                        category ==
                            'Contribution to EPF (voluntary or compulsory) / approved scheme';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isParentExpense)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              'Expenses for parents',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        if (isEducationFees)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              'Education fees (Self)',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        if (isLifeInsuranceAndEPF)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              'Life insurance and EPF',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ListTile(
                          title: Text(category),
                          trailing: GestureDetector(
                            onTap:
                                () => _copyValueToClipboard(
                                  value.toDouble(),
                                ), // Pass the value to copy
                            child: Text(
                              value.toString(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ),
                        if (isParentExpense ||
                            isEducationFees ||
                            isLifeInsuranceAndEPF)
                          const Divider(),
                      ],
                    );
                  },
                ),
      ),
    );
  }
}
