import 'package:flutter/material.dart';

class TimeDetailScreen extends StatelessWidget {
  const TimeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String time = args['time'];  // 선택된 시간대
    final List<String> timeSlots = args['timeSlots'];  // 시간대에 대한 세부 시간 리스트

    return Scaffold(
      appBar: AppBar(
        title: Text('Time Detail - $time'),
        backgroundColor: const Color(0xFF87C6FE),  // 파란색 배경
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 페이지 상단에 '그래프' 텍스트 표시
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '그래프',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            // 시간대에 따른 시간 슬롯을 리스트로 표시
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(95),  // 라운드 모서리 95 적용
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.access_time),  // 시간 아이콘
                        title: Text(
                          timeSlots[index],  // 시간 슬롯을 리스트에 표시
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text('그래프'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
