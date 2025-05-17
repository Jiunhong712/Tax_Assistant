import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taxassistant/upload%20page/upload_page.dart';
import 'package:taxassistant/history%20page/history_page.dart';
import 'package:taxassistant/dashboard%20page/dashboard_page.dart';
import 'package:taxassistant/components/chatbot_button.dart';
import 'package:taxassistant/history%20page/history_controller.dart';
import 'package:taxassistant/onboarding%20page/login_page/login_page.dart';
import 'package:taxassistant/constants.dart'; // Import constants.dart

void main() {
  Get.put(HistoryController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Use GetMaterialApp
      title: 'Tax Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins', // Set Poppins as the default font
      ),
      home: LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [UploadPage(), DashboardPage(), HistoryPage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white, // Set background color to white
        selectedItemColor:
            kColorPrimary, // Set selected item color to kColorAccent
        onTap: _onItemTapped,
      ),
      floatingActionButton: ChatbotButton(),
    );
  }
}
