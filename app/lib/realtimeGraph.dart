import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class RealTimeGraph extends StatefulWidget {
  const RealTimeGraph({super.key});

  @override
  _RealTimeGraphState createState() => _RealTimeGraphState();
}

class _RealTimeGraphState extends State<RealTimeGraph> {
  String? selectedDay; // 요일
  String? selectedDate; // 날짜
  List<String> filteredTimes = [];

  final List<String> days = ['1', '2', '3', '4', '5']; // 요일 리스트 (월요일=1, 화요일=2 등)
  final TextEditingController timeController = TextEditingController();

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

  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022, 1, 1),
      lastDate: DateTime(2025, 12, 31),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
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
                  right: 155,
                  child: Image.asset('assets/img/stop.png', height: 100),
                ),
                Positioned(
                  right: 0,
                  top: -15,
                  bottom: -42,
                  child: Image.asset('assets/img/bus.png', height: 40),
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
                          color:  const Color(0xFF4CAF50), // 버튼 파란색 유지
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black26),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.date_range, color: Colors.yellow, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  selectedDate ?? "날짜를 선택하세요",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.arrow_drop_down, color: Colors.yellow, size: 24),
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
                              color: Colors.yellow,
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                'Select Day',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow,
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
                                      color: Colors.yellow,
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
                            color: const Color(0xFF4CAF50), // 드롭다운 버튼 회색
                          ),
                          elevation: 2,
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_forward_ios_outlined,
                          ),
                          iconSize: 14,
                          iconEnabledColor: Colors.yellow,
                          iconDisabledColor: Colors.grey,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFF66BB6A), // 드롭다운 메뉴 회색
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
                      ),
                    ),
                  // 그래프 영역
                  Expanded(
                    child: StreamBuilder(
                      stream: (selectedDate != null && selectedDay != null && filteredTimes.isNotEmpty)
                          ? FirebaseFirestore.instance
                              .collection('database')
                              .where('Date', isEqualTo: selectedDate)
                              .where('Day', isEqualTo: selectedDay)
                              .where('Time', whereIn: filteredTimes)
                              .snapshots()
                          : null,
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data!.docs;
                        docs.sort((a, b) => timeToMinutes(a['Time']).compareTo(timeToMinutes(b['Time'])));

                        List<BarChartGroupData> barGroups = docs.asMap().entries.map((entry) {
                          int index = entry.key;
                          final doc = entry.value;
                          final y = double.parse(doc['Waiting_Passengers']);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: y,
                                width: 12,
                                gradient: const LinearGradient(
                                  colors: [Colors.blue, Colors.cyan],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList();

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: BarChart(
                            BarChartData(
                              maxY: docs.map((doc) => double.parse(doc['Waiting_Passengers'])).reduce((a, b) => a > b ? a : b),
                              barGroups: barGroups,
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
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
                                      if (value.toInt() < docs.length) {
                                        final timeString = docs[value.toInt()]['Time'];
                                        return Text(
                                          timeString,
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
                                    return BarTooltipItem(
                                      'Time: ${docs[groupIndex]['Time']}\n',
                                      const TextStyle(color: Colors.black),
                                      children: [
                                        TextSpan(
                                          text: 'Passengers: ${rod.toY.toInt()}',
                                          style: const TextStyle(color: Colors.blue),
                                        ),
                                      ],
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
