import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Dalgugi',
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Text(
                    'Count',
                    style: TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 이미지 섹션 (버스 정류장 + 버스)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/img/stop02.png', height: 150),  // 정류장 이미지
                      const SizedBox(width: 20),
                      Image.asset('assets/img/bus.png', height: 150),  // 버스 이미지
                    ],
                  ),
                  const SizedBox(height: 40),
                  // 학번 입력
                  TextField(
                    controller: studentIdController,
                    decoration: const InputDecoration(
                      labelText: '학번을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 비밀번호 입력
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호를 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  // 로그인 버튼
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/busSchedule');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('로그인', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // 비밀번호 재설정 기능 추가 가능
                    },
                    child: const Text(
                      '비밀번호 재설정',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
