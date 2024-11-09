
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식 변환을 위해 사용
import 'package:http/http.dart' as http;
import 'dart:convert';

class InputFormScreen extends StatefulWidget {
  const InputFormScreen({super.key, required this.selectedTime});
  // super parameter 사용
  final TimeOfDay selectedTime; // 선택한 시간을 받을 변수 추가
  @override
  InputFormScreenState createState() => InputFormScreenState();
}

class InputFormScreenState extends State<InputFormScreen> {
  // 입력받을 변수들 선언
  DateTime selectedDate = DateTime.now();
  int day = 1; // 1: 월요일, ..., 7: 일요일
  late TimeOfDay selectedTime;
  int weather = 1;
  bool event = false; // 이벤트 여부
  bool trainArrival = false; // 기차 도착 여부

  // 예측 결과를 저장할 변수
  String result = '';

  // 폼 키
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    selectedTime = widget.selectedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: const Text(''),
      ),
      body: Stack(
        children: [
          // 배경 화면 (버스 정류장과 버스 포함)
          Container(
            color: const Color(0xFF87C6FE),
            child: Column(
              children: [
                SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 48,
                        left: 30,
                        child: Image.asset('assets/img/stop02.png', height: 100),
                      ),
                      Positioned(
                    left: 80,
                    top: 8,
                    bottom: -42,
                    child: Image.asset('assets/img/bus.png', height: 50),
                  ),
                      
                    ],
                  ),
                ),
                // 남은 화면 공간에 입력 폼
                Expanded(
                  child:Container(
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
                          ListTile(
                            title: Text('날짜: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: _pickDate,
                          ),
                          // Day 입력
                          DropdownButtonFormField<int>(
                            value: day,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('월요일')),
                              DropdownMenuItem(value: 2, child: Text('화요일')),
                              DropdownMenuItem(value: 3, child: Text('수요일')),
                              DropdownMenuItem(value: 4, child: Text('목요일')),
                              DropdownMenuItem(value: 5, child: Text('금요일')),
                              DropdownMenuItem(value: 6, child: Text('토요일')),
                              DropdownMenuItem(value: 7, child: Text('일요일')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                day = value!;
                              });
                            },
                            decoration: const InputDecoration(labelText: '요일'),
                          ),
                          // Time 입력
                          ListTile(
                            title: Text('시간: ${selectedTime.format(context)}'),
                            trailing: const Icon(Icons.access_time),
                            onTap: _pickTime,
                          ),
                          // Weather 입력
                          DropdownButtonFormField<int>(
                            value: weather,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('맑음')),
                              DropdownMenuItem(value: 2, child: Text('흐림')),
                              DropdownMenuItem(value: 3, child: Text('비')),
                              DropdownMenuItem(value: 4, child: Text('눈')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                weather = value!;
                              });
                            },
                            decoration: const InputDecoration(labelText: '날씨'),
                          ),
                          // Event 입력
                          SwitchListTile(
                            title: const Text('이벤트 여부'),
                            value: event,
                            onChanged: (value) {
                              setState(() {
                                event = value;
                              });
                            },
                          ),
                          // Train Arrival 입력
                          SwitchListTile(
                            title: const Text('기차 도착 여부'),
                            value: trainArrival,
                            onChanged: (value) {
                              setState(() {
                                trainArrival = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _submitData,
                            child: const Text('예측하기'),
                          ),
                          const SizedBox(height: 20),
                          // 결과를 표시하는 부분
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

  // 날짜 선택 함수 정의
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

  // 시간 선택 함수 정의
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

  // 데이터 제출 함수 정의
  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      // 데이터를 모아서 서버로 전송
      Map<String, dynamic> requestData = {
        'Date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'Day': day,
        'Time': '${selectedTime.hour}:${selectedTime.minute}',
        'Weather': weather,
        'Event': event ? 1 : 0,
        'Train_Arrival': trainArrival ? 1 : 0,
      };

      try {
        final url = Uri.parse('https://074d-121-166-5-31.ngrok-free.app/predict');
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
