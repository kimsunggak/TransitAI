import 'package:app/my_firestore_widget.dart';
import 'package:app/realtimeGraph.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'bus_schedule_screen.dart';
import 'start_giheung_15.dart'; // 기흥역 출발 (월, 금)
import 'time_detail_screen.dart';
import 'chatbot.dart'; // 챗봇 화면 추가


class PastGraphScreen extends StatelessWidget {
  final TimeOfDay selectedTime;

  const PastGraphScreen({super.key, required this.selectedTime});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Graph for ${selectedTime.format(context)}'),
      ),
      body: Center(
        child: Text(
          'Graph details for ${selectedTime.format(context)}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
// 과거 그래프 화면 추가
// 예측 페이지 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 설정 옵션 추가
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dalgugi Prediction Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // 앱 시작 화면을 로그인 화면으로 설정
      routes: {
        '/': (context) => LoginScreen(),
        '/busSchedule': (context) => const BusScheduleScreen(),
        '/giheungDeparture15': (context) => const GiheungDepartureScreen15(),
        '/timeDetail': (context) => const TimeDetailScreen(),
        '/chatbot': (context) => ChatScreen(),
        '/realtimeGraph': (context) => const RealTimeGraph(), // 수정된 RealTimeGraph 호출
        '/firestore': (context) => const MyFirestoreWidget(), // Firestore 위젯 라우트 추가
      },
    );
  }
}
