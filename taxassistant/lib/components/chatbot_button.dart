import 'package:flutter/material.dart';
import 'package:taxassistant/chatbot%20page/chatbot_page.dart'; // Import ChatbotPage
import 'package:taxassistant/constants.dart'; // Import constants.dart

class ChatbotButton extends StatelessWidget {
  const ChatbotButton({Key? key}) : super(key: key);

  void _openChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatbotPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openChatbot(context),
      tooltip: 'Open Chatbot',
      backgroundColor: kColorAccent, // Set background color from constants
      child: const Icon(
        Icons.smart_toy, // Changed icon to smart_toy
        color: kColorPrimary, // Set icon color from constants
      ),
    );
  }
}
