import 'firebase_service.dart';
import 'prediction.dart';

class PredictionService {
  final FirestoreService _firestoreService = FirestoreService();

  Stream<List<Prediction>> streamPredictions() {
    return _firestoreService.getPredictions();
  }
}
