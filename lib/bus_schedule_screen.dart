import 'package:flutter/material.dart';

class BusScheduleScreen extends StatelessWidget {
  const BusScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 130,
              color: Colors.white,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 30,
                    right: 180,
                    child: Image.asset('assets/img/stop.png', height: 100),
                  ),
                  Positioned(
                    right: 10,
                    top: 8,
                    bottom: -42,
                    child: Image.asset('assets/img/bus.png', height: 40),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF87C6FE),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 텍스트
                      const Text(
                        '2024-2 학기 순환버스 운행 시간표',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 원하는 시간대, 장소 선택 텍스트
                      const Text(
                        '원하는 시간대, 장소를 선택하세요',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 강남대학교 -> 기흥역 텍스트
                      const Row(
                        children: [
                          Icon(Icons.directions_bus, color: Colors.black),
                          SizedBox(width: 8),
                          Text(
                            '강남대학교 ↔️ 기흥역(4번 출구)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 버튼 리스트
                      Expanded(
                        child: ListView(
                          children: [
                            // 기흥역 출발 버튼
                            _buildCustomButton(
                              context,
                              Icons.access_time, // 시계 아이콘
                              '기흥역(4번 출구) 출발',
                              '',
                              '/giheungDeparture15',
                            ),
                            // 실시간 그래프 버튼
                            _buildCustomButton(
                            context,
                            Icons.bar_chart, // 그래프 아이콘
                            '과거 실시간 그래프',
                            '',
                            '/realtimeGraph', // 네비게이션 라우트 이름
                              selectedTime: TimeOfDay.now(), // 현재 시간 기본값 전달
                            ),
                            // AI 택시 매칭 버튼
                            _buildCustomButton(
                              context,
                              Icons.local_taxi, // 택시 아이콘
                              'AI 택시 매칭',
                              '',
                              '/chatbot',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 버튼 생성 함수
  Widget _buildCustomButton(
    BuildContext context,
    IconData icon, // 아이콘 데이터 추가
    String title,
    String subtitle,
    String route, {
    TimeOfDay? selectedTime, // optional 파라미터로 selectedTime 추가
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // 둥근 모서리
      ),
      child: InkWell(
        onTap: () {
          if (route == '/pastGraph') {
            Navigator.pushNamed(
              context,
              route,
              arguments: selectedTime,
            );
          } else {
            Navigator.pushNamed(context, route);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 아이콘 부분
            Icon(
              icon,
              size: 40,
              color: Colors.black,
            ),
            const SizedBox(width: 16), // 아이콘과 텍스트 사이 간격
            // 텍스트 부분
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle.isNotEmpty) // subtitle이 있는 경우에만 표시
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
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

