import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyFirestoreWidget extends StatelessWidget {
  const MyFirestoreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('database').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData) {
          return const Text('No data found');
        }

        final docs = snapshot.data?.docs ?? [];
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            return ListTile(
              title: Text(
                'Date: ${doc['Date']}\n'
                'Day: ${doc['Day']}\n'
                'Event: ${doc['Event']}\n'
                'Time: ${doc['Time']}\n'
                'Train Arrival: ${doc['Train_Arrival']}\n'
                'Waiting Passengers: ${doc['Waiting_Passengers']}\n'
                'Weather: ${doc['Weather']}',
                style: const TextStyle(fontSize: 16),
              ),
              isThreeLine: true,
            );
          },
        );
      },
    );
  }
}
