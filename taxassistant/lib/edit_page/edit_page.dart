import 'package:flutter/material.dart';
import '../models/mock_data.dart'; // Import the Expense model

class EditPage extends StatefulWidget {
  final Expense expense; // Add a final field to accept the expense data

  const EditPage({Key? key, required this.expense}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  // Define TextEditingControllers for each field
  late TextEditingController _categoryController;
  late TextEditingController _vendorController;
  late TextEditingController _dateController;
  late TextEditingController _totalController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the expense data
    _categoryController = TextEditingController(text: widget.expense.category);
    _vendorController = TextEditingController(text: widget.expense.vendor);
    _dateController = TextEditingController(text: widget.expense.date);
    _totalController = TextEditingController(
      text: widget.expense.total.toString(),
    );
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed
    _categoryController.dispose();
    _vendorController.dispose();
    _dateController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Fields')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextFormField(
              controller: _vendorController,
              decoration: const InputDecoration(labelText: 'Vendor'),
            ),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            TextFormField(
              controller: _totalController,
              decoration: const InputDecoration(labelText: 'Total'),
              keyboardType: TextInputType.number, // Set keyboard type for total
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save logic
                print('Save button pressed');
                // You would typically update the expense object and navigate back
                // Navigator.pop(context, updatedExpense);
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
