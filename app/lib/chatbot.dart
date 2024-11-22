import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  const ChatBotApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> messages = [
    {"sender": "bot", "message": "무엇을 도와드릴까요"},
  ];

  TextEditingController _controller = TextEditingController();

  // 서버 URL 설정 (ngrok URL로 변경)
  final String serverUrl = 'https://5260-211-238-109-139.ngrok-free.app/chat';
  // 고정된 user_id사용(테스트를 위해)
  final String userId = 'test2';
  Future<String> sendMessageToServer(String mssage) async {
    try {
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id':userId, 'message': mssage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('서버 응답 에러');
      }
    } catch (e) {
      print('Error: $e');
      return '죄송합니다. 오류가 발생했습니다.';
    }
  }

  void _sendMessage() async {
    String userInput = _controller.text.trim();
    if (userInput.isEmpty) return;

    setState(() {
      messages.add({"sender": "user", "message": userInput});
      _controller.clear();
    });

    String botResponse = await sendMessageToServer(userInput);

    setState(() {
      messages.add({"sender": "bot", "message": botResponse});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Icon(
          Icons.local_taxi,
          size: 40,
          color: Colors.black,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.lightBlue[100],
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isBot = message['sender'] == 'bot';
                  return ChatBubble(
                    isBot: isBot,
                    message: message['message']!,
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isBot;
  final String message;

  const ChatBubble({Key? key, required this.isBot, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBot)
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.smart_toy,
                color: Colors.black,
                size: 24,
              ),
            ),
          if (isBot) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBot ? Colors.yellow[300] : Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          if (!isBot) const SizedBox(width: 8),
          if (!isBot)
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.black),
            ),
        ],
      ),
    );
  }
}