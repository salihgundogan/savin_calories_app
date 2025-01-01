import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Veri ekleme
  Future<void> addData(String foodName, int calories) async {
    try {
      await _firestore.collection('calorieData').add({
        'foodName': foodName,
        'calories': calories,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Veri başarıyla eklendi!');
    } catch (e) {
      print('Veri eklenirken hata oluştu: $e');
    }
  }

  // Veri okuma
  Stream<List<Map<String, dynamic>>> getCalorieData() {
    return _firestore.collection('calorieData').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }
}
