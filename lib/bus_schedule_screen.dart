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
                    left: 25,
                    child: Image.asset('assets/img/stop02.png', height: 100),
                  ),
                  Positioned(
                    left: 80,
                    top: 8,
                    bottom: -42,
                    child: Image.asset('assets/img/bus.png', height: 150),
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
                      const Text(
                        '2024-2 학기 순환버스 운행 시간표',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '원하는 시간대, 장소를 선택하세요',
                        style: TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '🚍강남대학교 → 기흥역(4번 출구)',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Scrollbar(
                          thumbVisibility: true,
                          thickness: 8.0,
                          radius: const Radius.circular(10),
                          child: ListView(
                            children: [
                              _buildCustomButton(
                                context,
                                '기흥역 출발(4번 출구)',
                                '월요일, 금요일',
                                const Color(0xFF2A69A1),
                                '/giheungDeparture15',
                              ),
                              _buildCustomButton(
                                context,
                                '실시간 그래프',
                                '화요일, 수요일, 목요일',
                                const Color(0xFF2A69A1),
                                '/giheungDeparture234',
                              ),
                              _buildCustomButton(
                                context,
                                'AI 택시 모집',
                                '화요일, 수요일, 목요일',
                                const Color(0xFF2A69A1),
                                '/chatbot',  // 챗봇 라우트로 설정
                              ),
                            ],
                          ),
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
    String title,
    String subtitle,
    Color borderColor,
    String route,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // 라운드 모서리를 8로 설정
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          // 해당 route로 화면 전환
          Navigator.pushNamed(context, route);
        },
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
