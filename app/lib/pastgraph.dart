import 'prediction_chart.dart';
import 'package:flutter/material.dart';

class RealtimeGraphScreen extends StatelessWidget {
  const RealtimeGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Graph'),
      ),
      body: const CustomGraph(),
    );
  }
}
