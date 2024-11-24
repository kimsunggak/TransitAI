import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RealTimeGraph extends StatefulWidget {
  const RealTimeGraph({super.key});

  @override
  _RealTimeGraphState createState() => _RealTimeGraphState();
}

class _RealTimeGraphState extends State<RealTimeGraph> with SingleTickerProviderStateMixin {
  String? selectedDay; // 요일
  String? selectedDate; // 날짜
  String? selectedTime; // 시간 입력
  List<String> filteredTimes = [];
  bool showErrorMessage = false; // 에러 메시지 표시 여부

  final List<String> days = ['1', '2', '3', '4', '5']; // 요일 리스트 (월요일=1, 화요일=2 등)
  final TextEditingController timeController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 애니메이션 컨트롤러 초기화
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // 애니메이션 설정 (오른쪽에서 왼쪽으로)
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // 애니메이션 실행
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // 애니메이션 컨트롤러 해제
    timeController.dispose();
    super.dispose();
  }

  int timeToMinutes(String time) {
    final parts = time.split(":").map(int.parse).toList();
    return parts[0] * 60 + parts[1];
  }

  List<String> generateTimeRange(String startTime) {
    final startMinutes = timeToMinutes(startTime);
    List<String> times = [];
    for (int i = 0; i < 6; i++) {
      final totalMinutes = startMinutes + (i * 10);
      final hour = (totalMinutes ~/ 60).toString().padLeft(2, '0');
      final minute = (totalMinutes % 60).toString().padLeft(2, '0');
      times.add('$hour:$minute');
    }
    return times;
  }

  Future<String> getPreviousDate(String date) async {
    final currentDate = DateTime.parse(date);
    final previousWeekDate = currentDate.subtract(const Duration(days: 7));
    return "${previousWeekDate.year}-${previousWeekDate.month.toString().padLeft(2, '0')}-${previousWeekDate.day.toString().padLeft(2, '0')}";
  }

  Future<List<QuerySnapshot>> fetchCurrentAndPreviousData(
      String currentDate, String day, List<String> times) async {
    final previousDate = await getPreviousDate(currentDate);

    // 현재 날짜와 전주 날짜 데이터를 병렬로 가져옴
    return Future.wait([
      FirebaseFirestore.instance
          .collection('database')
          .where('Date', isEqualTo: currentDate)
          .where('Day', isEqualTo: day)
          .where('Time', whereIn: times)
          .get(),
      FirebaseFirestore.instance
          .collection('database')
          .where('Date', isEqualTo: previousDate)
          .where('Day', isEqualTo: day)
          .where('Time', whereIn: times)
          .get(),
    ]);
  }

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022, 1, 1), // 최소 날짜 설정
      lastDate: DateTime(2025, 12, 31), // 최대 날짜 설정
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void onTimeSubmitted(String time) {
    setState(() {
      selectedTime = time; // 입력된 시간을 저장
      filteredTimes = generateTimeRange(time); // 시간대 범위 생성
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87C6FE), // 배경 흰색
      appBar: AppBar(
        backgroundColor: const Color(0xFF87C6FE), // 앱바 색상 유지
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 20,
                  child: Image.asset('assets/img/stop01.png', height: 100),
                ),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Positioned(
                      top: 25,
                      left: MediaQuery.of(context).size.width * _animation.value,
                      child: Image.asset('assets/img/bus.png', height: 100),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white, // 그래프 배경 흰색
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // 날짜 선택 버튼
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: pickDate,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF66BB6A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black26),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.date_range, color: Color(0xFFFFC84A), size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  selectedDate ?? "날짜를 선택하세요",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFC84A),
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down, color: Color(0xFFFFC84A), size: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 요일 선택 Dropdown
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: const Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color(0xFFFFC84A),
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '요일을 선택하세요',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFC84A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        items: days
                            .map((String day) => DropdownMenuItem<String>(
                                  value: day,
                                  child: Text(
                                    'Day $day',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFFC84A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        value: selectedDay,
                        onChanged: (value) {
                          setState(() {
                            selectedDay = value;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 50,
                          padding: const EdgeInsets.only(left: 14, right: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black26),
                            color: const Color(0xFF66BB6A),
                          ),
                          elevation: 2,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_forward_ios_outlined),
                          iconSize: 14,
                          iconEnabledColor: Color(0xFFFFC84A),
                          iconDisabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFF66BB6A),
                          ),
                          offset: const Offset(-20, 0),
                          scrollbarTheme: ScrollbarThemeData(
                            radius: const Radius.circular(40),
                            thickness: WidgetStateProperty.all(6),
                            thumbVisibility: WidgetStateProperty.all(true),
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.only(left: 14, right: 14),
                        ),
                      ),
                    ),
                  ),
                  // 시간대 입력 TextField
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        labelText: '시간을 입력해주세요 (ex:07:50 or 10:00)',
                        labelStyle: const TextStyle(color: Colors.black), // 텍스트 색상
                        filled: false,
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black, width: 2), // 기본 테두리 색상
                          borderRadius: BorderRadius.circular(10), // 둥근 테두리
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2), // 포커스 상태 테두리 색상
                          borderRadius: BorderRadius.circular(10), // 둥근 테두리
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFC8E6C9), width: 2), // 기본 테두리
                          borderRadius: BorderRadius.circular(10), // 둥근 테두리
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.black, // 입력 텍스트 색상
                        fontWeight: FontWeight.bold,
                      ),
                      onSubmitted: onTimeSubmitted, // 시간 입력 완료 시 처리
                    ),
                  ),
                  // 에러 메시지 표시
                  if (showErrorMessage)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "날짜와 요일을 다시 입력해주세요",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // 그래프 영역
                  Expanded(
                    child: FutureBuilder(
                      future: (selectedDate != null &&
                              selectedDay != null &&
                              filteredTimes.isNotEmpty)
                          ? fetchCurrentAndPreviousData(
                              selectedDate!, selectedDay!, filteredTimes)
                          : null,
                      builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                        if (selectedDate == null || selectedDay == null || selectedTime == null) {
                          // 초기 상태일 때 아무것도 표시하지 않음
                          return const SizedBox.shrink();
                        }
                      
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(), // 로딩 중 상태
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.any((qs) => qs.docs.isEmpty)) {
                          return const Center(
                            child: Text(
                              "날짜와 요일을 다시 선택하세요",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          );
                        }
                        final currentDocs = snapshot.data![0].docs;
                        final previousDocs = snapshot.data![1].docs;

                        final xAxisTimes = currentDocs
                            .map((doc) => doc['Time'] as String)
                            .toList(); // 데이터베이스에 존재하는 시간대만 가져옴

                        Map<String, double> currentData = {
                          for (var doc in currentDocs)
                            doc['Time']: double.parse(doc['Waiting_Passengers']),
                        };
                        Map<String, double> previousData = {
                          for (var doc in previousDocs)
                            doc['Time']: double.parse(doc['Waiting_Passengers']),
                        };
                        final List<String> sortedTimes = xAxisTimes..sort((a, b) => a.compareTo(b));

                        List<BarChartGroupData> barGroups = xAxisTimes.asMap().entries.map((entry) {
                          int index = entry.key;
                          String time = entry.value;

                          double currentValue = currentData[time] ?? 0.0;
                          double previousValue = previousData[time] ?? 0.0;

                          return BarChartGroupData(
                        x: index,
                      barRods: [
                        // 과거 데이터가 왼쪽
                        BarChartRodData(
                          toY: previousValue,
                          width: 12,
                          gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.red], // 과거 데이터 색상
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          ),
                         // 현재 데이터가 오른쪽
                      BarChartRodData(
                          toY: currentValue,
                          width: 12,
                          gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.cyan], // 현재 데이터 색상
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      );}).toList();

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: BarChart(
                            BarChartData(
                              maxY: currentDocs
                                  .map((doc) => double.parse(doc['Waiting_Passengers']))
                                  .reduce((a, b) => a > b ? a : b),
                              barGroups: barGroups,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 10, color: Colors.black),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() < xAxisTimes.length) {
                                        return Text(
                                          xAxisTimes[value.toInt()],
                                          style: const TextStyle(fontSize: 10, color: Colors.black),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[400]!,
                                    strokeWidth: 0.5,
                                  );
                                },
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                 getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                // rodIndex가 0일 때 과거 데이터, 1일 때 현재 데이터
                                final isPrevious = rodIndex == 0; // 과거 데이터는 첫 번째 막대
                                 return BarTooltipItem(
                                  isPrevious
                                    ? 'Previous: ${rod.toY.toInt()}'
                                    : 'Current: ${rod.toY.toInt()}',
                                    const TextStyle(color: Colors.black),
                                  );
                                },
                              ),

                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}