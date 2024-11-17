class Prediction {
  final String date;
  final String day;
  final String event;
  final String time;
  final String trainArrival;
  final String waitingPassengers;
  final String weather;

  Prediction({
    required this.date,
    required this.day,
    required this.event,
    required this.time,
    required this.trainArrival,
    required this.waitingPassengers,
    required this.weather,
  });

  factory Prediction.fromSnapshot(Map<String, dynamic> snapshot) {
    return Prediction(
      date: snapshot['Date'] ?? '',
      day: snapshot['Day'] ?? '',
      event: snapshot['Event'] ?? '0',
      time: snapshot['Time'] ?? '',
      trainArrival: snapshot['Train_Arrival'] ?? '0',
      waitingPassengers: snapshot['Waiting_Passengers'] ?? '0',
      weather: snapshot['Weather'] ?? '1',
    );
  }
}
