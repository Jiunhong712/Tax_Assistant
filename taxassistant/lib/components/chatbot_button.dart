import 'package:flutter/material.dart';
import 'package:taxassistant/chatbot%20page/chatbot_page.dart'; // Import ChatbotPage

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
      child: const Icon(Icons.chat),
    );
  }
}
