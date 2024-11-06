import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'bus_schedule_screen.dart';
import 'start_giheung_234.dart';  // 기흥역 출발 (화, 수, 목)
import 'start_giheung_15.dart';  // 기흥역 출발 (월, 금)
import 'time_detail_screen.dart';
import 'chatbot.dart';  // 챗봇 화면 추가

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dalgugi Count',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',  // 앱 시작 화면을 로그인 화면으로 설정
      routes: {
        '/': (context) => LoginScreen(),
        '/busSchedule': (context) => const BusScheduleScreen(),
        '/giheungDeparture234': (context) => const GiheungDepartureScreen234(),  // 기흥역 출발 (화, 수, 목)
        '/giheungDeparture15': (context) => const GiheungDepartureScreen15(),  // 기흥역 출발 (월, 금)
        '/timeDetail': (context) => const TimeDetailScreen(),  // 시간대 세부 페이지
        '/chatbot': (context) => ChatScreen(),  // 챗봇 화면 라우트 추가
        //'/inputForm': (context) => const InputFormScreen(selectedTime: null),  // 입력 폼 페이지
      },
    );
  }
}
