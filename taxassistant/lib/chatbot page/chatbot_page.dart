import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:taxassistant/history%20page/history_controller.dart'; // Import HistoryController
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http; // Import http package
import '../constants.dart'; // Import constants

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  List<ChatMessage> _messages = [];
  final HistoryController historyController = Get.find<HistoryController>();
  late String dashboardData;

  @override
  void initState() {
    super.initState();
    dashboardData = historyController.getCombinedDashboardData();
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

    // URL of the Flask backend
    final url = Uri.parse('http://127.0.0.1:5001/chatbot');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': _messages.last.text,
          'dashboardData': dashboardData, // Include dashboard data
        }), // Send the user's message and dashboard data
      );

      if (response.statusCode == 200) {
        // Request successful, process the response
        final responseData = jsonDecode(response.body);
        final apiResponseText = responseData['response'];

        setState(() {
          _messages.add(
            ChatMessage(text: apiResponseText, isUser: false),
          ); // Add chatbot response
          _isLoading = false;
        });
      } else {
        // Request failed
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Error: ${response.statusCode} - ${response.reasonPhrase}',
              isUser: false,
            ),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle network or other errors
      setState(() {
        _messages.add(ChatMessage(text: 'Error: $e', isUser: false));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Taxly',
          style: TextStyle(
            color: kColorPrimary,
            fontFamily: 'Poppins',
          ), // Set title color to white
        ),
      ),
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
                      hintText: 'Enter your message here..',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                OutlinedButton(
                  onPressed: _isLoading ? null : _sendRequest,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: kColorComponent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    backgroundColor:
                        _isLoading
                            ? Colors.grey
                            : kColorAccent, // Set background color
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            'Send',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color:
                                  _isLoading
                                      ? Colors.black
                                      : kColorPrimary, // Set text color
                            ),
                          ),
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
