import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;

  const CustomTimePicker({super.key, required this.initialTime});

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late int selectedHour;
  late int selectedMinute;
  late int selectedPeriod; // 0: AM, 1: PM

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hourOfPeriod;
    selectedMinute = widget.initialTime.minute;
    selectedPeriod = widget.initialTime.period == DayPeriod.am ? 0 : 1;
  }

  /// 시간/분 입력을 위한 다이얼로그
  Future<String?> _showInputDialog(BuildContext context, String title, String initialValue) async {
    final TextEditingController controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Enter value",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF3E8FF), // 배경 색상 설정
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        "시간을 입력해주세요",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4, // 화면 너비의 90%로 설정
        height: MediaQuery.of(context).size.height * 0.4, // 화면 높이의 50%로 설정
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 시간 선택 Picker
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final input = await _showInputDialog(
                            context,
                            "시를 입력해주세요",
                            (selectedHour + 1).toString(),
                          );
                          if (input != null) {
                            final int? hour = int.tryParse(input);
                            if (hour != null && hour >= 1 && hour <= 12) {
                              setState(() {
                                selectedHour = hour - 1; // Picker 인덱스는 0부터 시작
                              });
                            }
                          }
                        },
                        child: Text(
                          "${selectedHour + 1} 시",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: selectedHour),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (value) {
                          setState(() {
                            selectedHour = value;
                          });
                        },
                        children: List<Widget>.generate(12, (index) {
                          return Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 24, color: Colors.black), // 텍스트 스타일
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const Text(
                  ":",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                // 분 선택 Picker
                Expanded(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final input = await _showInputDialog(
                            context,
                            "분을 입력해주세요",
                            selectedMinute.toString().padLeft(2, '0'),
                          );
                          if (input != null) {
                            final int? minute = int.tryParse(input);
                            if (minute != null && minute >= 0 && minute <= 59) {
                              setState(() {
                                selectedMinute = minute;
                              });
                            }
                          }
                        },
                        child: Text(
                          "${selectedMinute.toString().padLeft(2, '0')}분",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: selectedMinute),
                        itemExtent: 32.0,
                        onSelectedItemChanged: (value) {
                          setState(() {
                            selectedMinute = value;
                          });
                        },
                        children: List<Widget>.generate(60, (index) {
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 24, color: Colors.black), // 텍스트 스타일
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                // AM/PM 선택 Picker
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: selectedPeriod),
                    itemExtent: 32.0,
                    onSelectedItemChanged: (value) {
                      setState(() {
                        selectedPeriod = value;
                      });
                    },
                    children: const [
                      Center(
                        child: Text(
                          "AM",
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                      Center(
                        child: Text(
                          "PM",
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.purple, // 'primary' 대신 'foregroundColor' 사용
          ),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final time = TimeOfDay(
              hour: selectedPeriod == 0 ? selectedHour + 1 : selectedHour + 13, // AM/PM에 따른 24시간 변환
              minute: selectedMinute,
            );
            Navigator.pop(context, time);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.purple, // 'primary' 대신 'foregroundColor' 사용
          ),
          child: const Text("OK"),
        ),
      ],
    );
  }
}

Future<TimeOfDay?> showCustomTimePicker(BuildContext context, TimeOfDay initialTime) async {
  return await showDialog<TimeOfDay>(
    context: context,
    builder: (context) => CustomTimePicker(initialTime: initialTime),
  );
}