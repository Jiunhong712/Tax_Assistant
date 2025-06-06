import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data'; // Required for Uint8List
import 'package:get/get.dart'; // Import GetX
import 'upload_controller.dart'; // Import the controller
import 'package:taxassistant/history%20page/history_controller.dart';
import '../constants.dart'; // Import constants
import '../edit page/edit_page.dart'; // Import the EditPage
import '../filling page/filling_page.dart'; // Import the FillingPage
import '../profile page/profile_page.dart'; // Import the ProfilePage

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  @override
  Widget build(BuildContext context) {
    final uploadController = Get.put(UploadController());
    final historyController = Get.put(HistoryController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove the back button
        title: const Text(
          'Upload Document',
          style: TextStyle(
            color: kColorPrimary,
            fontFamily: 'Poppins',
          ), // Set title color to white
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: kColorPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
        ],
      ),
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
              const SizedBox(height: 20), // Add some spacing
              const SizedBox(height: 20),
              // Modified Upload File section
              ElevatedButton(
                onPressed: () {
                  uploadController.resetUploadPage();
                  if (!uploadController.isDocumentProcessed.value) {
                    uploadController.pickFile(); // Allow picking a new file
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    double.infinity,
                    100,
                  ), // Maintain similar size
                  padding: const EdgeInsets.all(20.0),
                  backgroundColor:
                      Colors.grey[200], // Set background color to grey
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ), // Add circular border
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_upload,
                      size: 50.0,
                      color: Colors.grey,
                    ), // Add an upload icon
                    const SizedBox(height: 10),
                    Obx(
                      () => Text(
                        uploadController.isDocumentProcessed.value
                            ? 'Click to Upload Another File'
                            : 'Click to Upload File',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
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
                                  height: 400,
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
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) => EditPage(
                                                          expense:
                                                              uploadController
                                                                  .processedExpense!,
                                                        ),
                                                  ),
                                                );
                                              },
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
