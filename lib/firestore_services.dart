import 'package:cloud_firestore/cloud_firestore.dart';
import 'tabloGoruntuleme.dart';

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
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['documentId'] = doc.id; // Firestore docId'yi de ekliyoruz
        return data;
      }).toList();
    });
  }

  // FirestoreService'de silme fonksiyonunu ekleyin
  Future<void> deleteFood(String docId) async {
    try {
      await _firestore.collection('calorieData').doc(docId).delete();
      print('Veri başarıyla silindi!');
    } catch (e) {
      print('Veri silinirken hata oluştu: $e');
    }
  }
  // FirestoreService'deki yeni düzenleme fonksiyonu
  Future<void> updateFood(String docId, String newFoodName, int newCalories) async {
    try {
      await _firestore.collection('calorieData').doc(docId).update({
        'foodName': newFoodName,
        'calories': newCalories,
      });
      print('Veri başarıyla güncellendi!');
    } catch (e) {
      print('Veri güncellenirken hata oluştu: $e');
    }
  }
}
