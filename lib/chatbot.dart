import 'package:flutter/material.dart';

void main() {
  runApp(const ChatBotApp());
}

class ChatBotApp extends StatelessWidget {
  const ChatBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  final List<Map<String, String>> messages = [
    {"sender": "bot", "message": "무엇을 도와드릴까요"},
    {"sender": "user", "message": "텍스트"},
  ];

  ChatScreen({super.key});

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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      // 메시지 전송 로직 추가
                    },
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

  const ChatBubble({super.key, required this.isBot, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot)
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.smart_toy, // 로봇 모양 아이콘
                color: Colors.black,
                size: 24,
              ),
            ),
          if (!isBot)
            const SizedBox(width: 40), // 왼쪽 여백
          Container(
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isBot ? Colors.yellow[300] : Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.black),
            ),
          ),
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
