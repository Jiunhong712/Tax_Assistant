import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data'; // Required for Uint8List
import 'package:provider/provider.dart'; // Import Provider
import 'package:get/get.dart'; // Import GetX
import '../models/expense_provider.dart';
import 'upload_controller.dart'; // Import the controller

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(
      context,
      listen: false,
    );
    final uploadController = Get.put(UploadController());

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Obx(
                () =>
                    uploadController.isDocumentProcessed.value
                        ? Container() // Hide the reminder
                        : Card(
                          color: Colors.yellow[100],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Tax Filing Reminder: ${uploadController.reminderMessage}',
                              textAlign: TextAlign.justify,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
              ),
              const SizedBox(height: 100),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      uploadController.isLoading
                          ? null
                          : uploadController.pickFile,
                  child: Text(
                    uploadController.isDocumentProcessed.value
                        ? 'Pick Another File'
                        : 'Upload File',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                // Use Expanded for the scrollable area
                child: SingleChildScrollView(
                  // Make the content scrollable
                  child: Obx(() {
                    // Use Obx to observe changes in the controller
                    return Column(
                      children: [
                        if (uploadController.isLoading)
                          const CircularProgressIndicator()
                        else if (uploadController.pickedFile != null)
                          Column(
                            // Changed from Expanded to Column
                            children: [
                              Text(
                                'Selected File: ${uploadController.pickedFile!.name}',
                              ),
                              const SizedBox(height: 10),
                              if (uploadController.pickedFile!.bytes != null)
                                // Display image preview for web
                                Image.memory(
                                  uploadController.pickedFile!.bytes
                                      as Uint8List,
                                  height: 200,
                                  fit: BoxFit.fill,
                                )
                              else if (uploadController.pickedFile!.path !=
                                  null)
                                // Display image preview for other platforms (if needed, though web is focus)
                                Image.file(
                                  File(uploadController.pickedFile!.path!),
                                  height: 200,
                                  fit: BoxFit.fill,
                                ),
                              const SizedBox(height: 20),
                              if (uploadController.processedExpense != null)
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Categorized Expense:',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Category: ${uploadController.processedExpense!.category}',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed:
                                                  () => uploadController
                                                      .editCategory(
                                                        uploadController
                                                            .processedExpense!,
                                                      ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Vendor: ${uploadController.processedExpense!.vendor}',
                                        ),
                                        Text(
                                          'Date: ${uploadController.processedExpense!.date}',
                                        ),
                                        Text(
                                          'Total: ${uploadController.processedExpense!.total.toStringAsFixed(2)}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed:
                                    uploadController.processedExpense != null
                                        ? () {
                                          uploadController.generateReport(
                                            expenseProvider.expenses,
                                          );
                                        }
                                        : null,
                                child: const Text('Export Report'),
                              ),
                            ],
                          )
                        else
                          const Text('No file selected.'),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
