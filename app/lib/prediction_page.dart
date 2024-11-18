import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prediction Service',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now(); // 기본값을 현재 날짜로 설정
    String selectedWeather = '맑음'; // 기본값 설정
    String selectedDayOfWeek = '수요일'; // 기본값 설정
    bool isEvent = false; // 이벤트 여부
    bool isTrainArrived = false; // 기차 도착 여부

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Service'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PredictionPage(
                  selectedDate: selectedDate,
                  selectedWeather: selectedWeather,
                  selectedDayOfWeek: selectedDayOfWeek,
                  isEvent: isEvent,
                  isTrainArrived: isTrainArrived,
                ),
              ),
            );
          },
          child: const Text('조회하기'),
        ),
      ),
    );
  }
}

class PredictionPage extends StatelessWidget {
  final DateTime selectedDate;
  final String selectedWeather;
  final String selectedDayOfWeek;
  final bool isEvent;
  final bool isTrainArrived;

  const PredictionPage({
    super.key,
    required this.selectedDate,
    required this.selectedWeather,
    required this.selectedDayOfWeek,
    required this.isEvent,
    required this.isTrainArrived,
  });

  Future<List<FlSpot>> fetchPredictionData() async {
    List<FlSpot> spots = [];

    // Firestore에서 데이터를 가져오기 위한 쿼리
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('predictions')
        .where('date', isEqualTo: DateFormat('yyyy-MM-dd').format(selectedDate))
        .where('weather', isEqualTo: selectedWeather)
        .where('dayOfWeek', isEqualTo: selectedDayOfWeek)
        .where('isEvent', isEqualTo: isEvent)
        .where('isTrainArrived', isEqualTo: isTrainArrived)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs[0].data() as Map<String, dynamic>?;
      if (data != null && data['predictionData'] != null) {
        List<dynamic> predictionData = data['predictionData'];
        for (var i = 0; i < predictionData.length; i++) {
          spots.add(FlSpot(i.toDouble(), (predictionData[i] as num).toDouble()));
        }
      }
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prediction for ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
      ),
      body: FutureBuilder<List<FlSpot>>(
        future: fetchPredictionData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No prediction data available.'));
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: snapshot.data!,
                      isCurved: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
