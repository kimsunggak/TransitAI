import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'custom_time_picker.dart'; // CustomTimePicker import

class InputFormScreen extends StatefulWidget {
  const InputFormScreen({super.key, required this.selectedTime});
  final TimeOfDay selectedTime;

  @override
  InputFormScreenState createState() => InputFormScreenState();
}

class InputFormScreenState extends State<InputFormScreen> {
  DateTime selectedDate = DateTime.now();
  int? day; // 초기값 null 설정
  late TimeOfDay selectedTime;
  int? weather; // 초기값 null 설정
  bool event = false; // 이벤트 여부
  bool trainArrival = false; // 기차 도착 여부
  String result = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedTime = widget.selectedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( backgroundColor: const Color(0xFF87C6FE)),
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
                                  // 날짜 선택 함수 호출
                                  final result = await showBoardDateTimePicker(
                                  context: context,
                                  pickerType: DateTimePickerType.date, // 날짜 선택으로 설정
                                  initialDate: selectedDate, // 현재 선택된 날짜로 초기화
                                  options: const BoardDateTimeOptions(
                                  languages: BoardPickerLanguages.en(), // 언어 설정 (영어)
                                  pickerFormat: PickerFormat.ymd, // 연-월-일 형식
                                  ),
                                );

                               if (result != null) {
                                setState(() {
                                selectedDate = result; // 선택한 날짜를 업데이트
                                });
                              }
                            },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            child: Row(
                               children: [
                                // 날짜 아이콘
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
                          // "날짜 선택" 텍스트
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
                        // 선택된 날짜 표시
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
                                items: const [
                                  DropdownMenuItem(value: 1, child: Text('월요일')),
                                  DropdownMenuItem(value: 2, child: Text('화요일')),
                                  DropdownMenuItem(value: 3, child: Text('수요일')),
                                  DropdownMenuItem(value: 4, child: Text('목요일')),
                                  DropdownMenuItem(value: 5, child: Text('금요일')),
                                  DropdownMenuItem(value: 6, child: Text('토요일')),
                                  DropdownMenuItem(value: 7, child: Text('일요일')),
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
                                    SizedBox(
                                      width: 4,
                                    ),
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
                                  '시간: ${selectedTime.format(context)}',style:const TextStyle(fontWeight: FontWeight.bold)),
                              trailing: const Icon(Icons.access_time),
                              onTap: _pickTime, // Custom Time Picker 호출
                            ),
                            // Event 입력
                            SwitchListTile(
                              title: const Text('이벤트 여부',style:TextStyle(fontWeight: FontWeight.bold)),
                              value: event,
                              onChanged: (value) {
                                setState(() {
                                  event = value;
                                });
                              },
                              activeColor:Colors.yellow, // 활성화 상태의 버튼 색상
                              activeTrackColor: const Color(0xFF87C6FE), // 활성화 상태의 트랙 색상
                              inactiveThumbColor: const Color(0xFFC0C0C0), // 비활성화 상태의 버튼 색상
                              inactiveTrackColor: const Color(0xFF808080), // 비활성화 상태의 트랙 색상
                              
                            ),
                            // Train Arrival 입력
                            SwitchListTile(
                              title: const Text('기차 도착 여부',style:TextStyle(fontWeight: FontWeight.bold)),
                              value: trainArrival,
                              onChanged: (value) {
                                setState(() {
                                  trainArrival = value;
                                });
                              },
                              activeColor:Colors.yellow, // 활성화 상태의 버튼 색상
                              activeTrackColor: const Color(0xFF87C6FE), // 활성화 상태의 트랙 색상
                              inactiveThumbColor: const Color(0xFFC0C0C0), // 비활성화 상태의 버튼 색상
                              inactiveTrackColor: const Color(0xFF808080), // 비활성화 상태의 트랙 색상
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
  onPressed: _submitData,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF87C6FE), // 버튼 배경색 설정
    foregroundColor: Colors.black, // 버튼 텍스트 색상
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(60), // 버튼 모서리 둥글게 설정
    ),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // 내부 여백 설정
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min, // 버튼 크기 최소화
    mainAxisAlignment: MainAxisAlignment.center, // 텍스트와 아이콘 중앙 정렬
    children: [
      Text(
        '예측하기',
        style: TextStyle(
          fontWeight: FontWeight.bold, // 글씨체 굵게 설정
          fontSize: 16, // 글씨 크기 설정
        ),
      ),
      SizedBox(width: 8), // 텍스트와 아이콘 사이 간격 설정
      Icon(
        Icons.search, // 돋보기 아이콘
        size: 20, // 아이콘 크기 설정
        color: Colors.black, // 아이콘 색상 설정
      ),
    ],
  ),
),

                            const SizedBox(height: 20),
                            if (result.isNotEmpty)
                              Text(
                                result,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
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

  void _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? time = await showCustomTimePicker(
      context,
      selectedTime,
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
        final url =
            Uri.parse('https://fc49-1-237-70-43.ngrok-free.app/predict');
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
