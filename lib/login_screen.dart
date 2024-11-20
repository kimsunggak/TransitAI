import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD54F), // 배경색: 노란색
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 이미지
                  Image.asset(
                    'assets/img/logo3.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 60),

                  // 학번 입력
                  TextField(
                    controller: studentIdController,
                    decoration: InputDecoration(
                      hintText: '학번을 입력하세요',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 비밀번호 입력
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: '비밀번호를 입력하세요',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),

                  // 확인 버튼
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/busSchedule');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 비밀번호 재설정 버튼
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
