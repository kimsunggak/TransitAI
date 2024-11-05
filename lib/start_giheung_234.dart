import 'package:flutter/material.dart';
import 'InputFormScreen.dart';

class GiheungDepartureScreen234 extends StatefulWidget {
  const GiheungDepartureScreen234({super.key});

  @override
  GiheungDepartureScreen234State createState() => GiheungDepartureScreen234State();
}

class GiheungDepartureScreen234State extends State<GiheungDepartureScreen234> with SingleTickerProviderStateMixin {
  // 애니메이션 컨트롤러와 애니메이션 설정
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 애니메이션 컨트롤러 설정 (10초 동안 애니메이션 실행)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    // 1.0에서 0.08로 변화하는 Tween 애니메이션 설정
    _animation = Tween<double>(begin: 1.0, end: 0.08).animate(_controller);

    // 애니메이션 시작
    _controller.forward();
  }

  @override
  void dispose() {
    // 애니메이션 종료 시 컨트롤러 해제
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  color: const Color(0xFF87C6FE),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 0,
                        top: 20,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 30),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 40,
                        child: Image.asset('assets/img/stop02.png', height: 80),
                      ),
                      // 버스 이미지가 오른쪽에서 왼쪽으로 이동하는 애니메이션
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Positioned(
                            top: 60,
                            left: MediaQuery.of(context).size.width * _animation.value,
                            child: Image.asset('assets/img/bus.png', height: 80),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Positioned.fill(
                  top: 120,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(150),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/img/sidebus.png', height: 60),
                    const SizedBox(width: 10),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '기흥역(4번 출구)',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '기흥역(4번 출구) ➡️ 이공관',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/img/time.png', height: 30),
                  const SizedBox(width: 8),
                  const Text(
                    '화요일, 수요일, 목요일',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 8.0,
                  radius: const Radius.circular(10),
                  child: ListView(
                    children: [
                      _buildTimeButton(context, '07:50~09:05', ['07:50', '08:00', '08:10', '08:20', '08:30', '08:40', '08:50', '09:00']),
                      _buildTimeButton(context, '10시', ['10:40', '10:50']),
                      _buildTimeButton(context, '11시', ['11:00', '11:10', '11:20']),
                      _buildTimeButton(context, '12시', ['12:50']),
                      _buildTimeButton(context, '13시', ['13:10', '13:40']),
                      _buildTimeButton(context, '14시', ['14:00', '14:10', '14:20']),
                      _buildTimeButton(context, '17시', ['17:00', '17:20', '17:40']),
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

  // 시간대 버튼을 눌렀을 때 시간을 선택하는 모달을 표시
  Widget _buildTimeButton(BuildContext context, String time, List<String> timeSlots) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: () {
          _showTimeSlots(context, timeSlots); // 시간대 버튼 클릭 시 모달 열기
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA3D3FE),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          time,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  // 개별 시간 버튼들을 표시하는 함수
  void _showTimeSlots(BuildContext context, List<String> timeSlots) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: timeSlots.length,
            itemBuilder: (context, index) {
              String selectedTime = timeSlots[index];
              return ListTile(
                title: Text(
                  selectedTime,
                  style: const TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Navigator.pop(context); // 모달 닫기
                  // 선택한 시간 정보를 InputFormScreen으로 전달
                  TimeOfDay timeOfDay = TimeOfDay(
                    hour: int.parse(selectedTime.split(':')[0]),
                    minute: int.parse(selectedTime.split(':')[1]),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InputFormScreen(selectedTime: timeOfDay),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
