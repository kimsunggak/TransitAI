import 'package:cloud_firestore/cloud_firestore.dart';
import 'prediction.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Prediction>> getPredictions() {
    return _db.collection('predictions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Prediction.fromSnapshot(doc.data())).toList();
    });
  }
}
