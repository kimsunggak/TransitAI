import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class InputFormScreen extends StatefulWidget {
  const InputFormScreen({super.key, required this.selectedTime});
  final TimeOfDay selectedTime;

  @override
  InputFormScreenState createState() => InputFormScreenState();
}

class InputFormScreenState extends State<InputFormScreen> with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();
  int? day;
  late TimeOfDay selectedTime;
  int? weather;
  bool event = false;
  bool trainArrival = false;
  String result = '';
  final _formKey = GlobalKey<FormState>();

  late AnimationController _moveController;
  late AnimationController _scaleController;
  late Animation<double> _moveAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    selectedTime = widget.selectedTime;

    // 버스 이동 애니메이션 초기화
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _moveAnimation = Tween<double>(begin: 1.0, end: 0.08).animate(CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeInOut,
    ));

    // 버스 크기 변화 애니메이션 초기화
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // 애니메이션 실행 및 크기 변화 시작
    _moveController.forward().whenComplete(() {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF87C6FE)),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFF87C6FE),
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 30,
                        child: Image.asset('assets/img/stop01.png', height: 100),
                      ),
                      AnimatedBuilder(
                        animation: Listenable.merge([_moveAnimation, _scaleAnimation]),
                        builder: (context, child) {
                          return Positioned(
                            top: 34,
                            left: MediaQuery.of(context).size.width * _moveAnimation.value,
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Image.asset('assets/img/bus.png', height: 80),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            // Date 입력
                            GestureDetector(
                              onTap: () async {
                                final result = await showBoardDateTimePicker(
                                  context: context,
                                  pickerType: DateTimePickerType.date,
                                  initialDate: selectedDate,
                                  minimumDate: DateTime(2022, 1, 1), // 최소 날짜 설정
                                  maximumDate: DateTime(2025, 12, 31), // 최대 날짜 설정
                                  options: const BoardDateTimeOptions(
                                    languages: BoardPickerLanguages.en(),
                                    pickerFormat: PickerFormat.ymd,
                                  ),
                                );

                                if (result != null) {
                                  setState(() {
                                    selectedDate = result;
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                child: Row(
                                  children: [
                                    Material(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(8),
                                      child: const SizedBox(
                                        height: 32,
                                        width: 32,
                                        child: Center(
                                          child: Icon(
                                            Icons.date_range_rounded,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        '날짜 선택',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat('yyyy/MM/dd').format(selectedDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Day 입력
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<int>(
                                isExpanded: true,
                                hint: const Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.yellow,
                                    ),
                                    SizedBox(width: 4),
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
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('월요일')),
                                  DropdownMenuItem(value: 2, child: Text('화요일')),
                                  DropdownMenuItem(value: 3, child: Text('수요일')),
                                  DropdownMenuItem(value: 4, child: Text('목요일')),
                                  DropdownMenuItem(value: 5, child: Text('금요일')),
                                ]
                                    .map((DropdownMenuItem<int> item) =>
                                        DropdownMenuItem<int>(
                                          value: item.value,
                                          child: Text(
                                            (item.child as Text).data!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: day,
                                onChanged: (value) {
                                  setState(() {
                                    day = value;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 60,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.black26),
                                    color: const Color(0xFF4CAF50),
                                  ),
                                  elevation: 2,
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(Icons.arrow_forward_ios_outlined),
                                  iconSize: 14,
                                  iconEnabledColor: Colors.yellow,
                                  iconDisabledColor: Colors.grey,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xFF66BB6A),
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: WidgetStateProperty.all(6),
                                    thumbVisibility: WidgetStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Weather 입력
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<int>(
                                isExpanded: true,
                                hint: const Row(
                                  children: [
                                    Icon(
                                      Icons.wb_sunny,
                                      size: 16,
                                      color: Colors.yellow,
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Select Weather',
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
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('맑음')),
                                  DropdownMenuItem(value: 2, child: Text('흐림')),
                                  DropdownMenuItem(value: 3, child: Text('비')),
                                  DropdownMenuItem(value: 4, child: Text('눈')),
                                ]
                                    .map((DropdownMenuItem<int> item) =>
                                        DropdownMenuItem<int>(
                                          value: item.value,
                                          child: Text(
                                            (item.child as Text).data!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: weather,
                                onChanged: (value) {
                                  setState(() {
                                    weather = value;
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 60,
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.black26),
                                    color: const Color(0xFF4CAF50),
                                  ),
                                  elevation: 2,
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(Icons.arrow_forward_ios_outlined),
                                  iconSize: 14,
                                  iconEnabledColor: Colors.yellow,
                                  iconDisabledColor: Colors.grey,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: const Color(0xFF66BB6A),
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: WidgetStateProperty.all(6),
                                    thumbVisibility: WidgetStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Time 입력
                            ListTile(
                              title: Text(
                                '시간: ${selectedTime.format(context)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: const Icon(Icons.access_time),
                              onTap: _pickTime,
                            ),
                            // Event 입력
                            SwitchListTile(
                              title: const Text('이벤트 여부', style: TextStyle(fontWeight: FontWeight.bold)),
                              value: event,
                              onChanged: (value) {
                                setState(() {
                                  event = value;
                                });
                              },
                              activeColor: Colors.yellow,
                              activeTrackColor: const Color(0xFF87C6FE),
                              inactiveThumbColor: const Color(0xFFC0C0C0),
                              inactiveTrackColor: const Color(0xFF808080),
                            ),
                            // Train Arrival 입력
                            SwitchListTile(
                              title: const Text('기차 도착 여부', style: TextStyle(fontWeight: FontWeight.bold)),
                              value: trainArrival,
                              onChanged: (value) {
                                setState(() {
                                  trainArrival = value;
                                });
                              },
                              activeColor: Colors.yellow,
                              activeTrackColor: const Color(0xFF87C6FE),
                              inactiveThumbColor: const Color(0xFFC0C0C0),
                              inactiveTrackColor: const Color(0xFF808080),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _submitData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF87C6FE),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '예측하기',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.search,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (result.isNotEmpty)
                              Text(
                                result,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> requestData = {
        'Date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'Day': day,
        'Time': '${selectedTime.hour}:${selectedTime.minute}',
        'Weather': weather,
        'Event': event ? 1 : 0,
        'Train_Arrival': trainArrival ? 1 : 0,
      };

      try {
        final url = Uri.parse('https://5260-211-238-109-139.ngrok-free.app/predict');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          setState(() {
            result = '예측된 대기 인원 수: ${responseData['prediction']}명';
          });
        } else {
          setState(() {
            result = '예측에 실패했습니다. 상태 코드: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          result = '에러 발생: $e';
        });
      }
    }
  }
}
