import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const ResultsPage({Key? key, required this.data}) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      appBar: AppBar(title: const Text('Receipt Results')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Vendor: ${data['vendor']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: ${data['date']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Total: ${data['total']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(
              'Category: ${data['category']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Tax Deduction Suggestions:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (data['suggestions'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    (data['suggestions'] as List<dynamic>)
                        .map(
                          (suggestion) => Text(
                            '- $suggestion',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
