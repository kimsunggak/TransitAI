import 'package:app/chatbot.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userIDController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;

  // 추가된 부분: 입력 필드 상태를 추적하는 변수
  bool isUserIDFilled = false;
  bool isPasswordFilled = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      // 익명으로 로그인
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

          // 로그인 성공 후
    // 로그인 성공 후
    if (user != null) {
      String uid = user.uid;
      String userID = userIDController.text.trim();

      // Firestore에 학번 저장 (필요한 경우)
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'userID': userID,
      });

      // 다음 화면으로 이동하며 UID와 userID 전달
      Navigator.pushReplacementNamed(
        context,
        '/busSchedule',
        arguments: userID, // userID를 전달
      );
    }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 다시 시도해주세요.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 추가된 부분: 입력 필드 상태 업데이트 함수
  void _updateButtonState() {
    setState(() {
      isUserIDFilled = userIDController.text.trim().isNotEmpty;
      isPasswordFilled = passwordController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    // 입력 필드에 리스너 추가
    userIDController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    // 리스너 제거 및 컨트롤러 해제
    userIDController.removeListener(_updateButtonState);
    passwordController.removeListener(_updateButtonState);
    userIDController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 로그인 버튼이 활성화되어야 하는지 여부
    bool isLoginButtonEnabled =
        !isLoading && isUserIDFilled && isPasswordFilled;

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
                    controller: userIDController,
                    decoration: InputDecoration(
                      hintText: '학번을 입력하세요',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 비밀번호 입력 (테스트 단계이므로 실제로 사용하지 않음)
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: '비밀번호를 입력하세요',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
                    onPressed: isLoginButtonEnabled ? _login : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator()
                        : const Text(
                            '확인',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                  ),
                  const SizedBox(height: 10),

                  // 비밀번호 재설정 버튼 (테스트 단계에서는 기능 없음)
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
