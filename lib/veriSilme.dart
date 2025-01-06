import 'package:flutter/material.dart';
import 'firestore_services.dart';

class veriSilme extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Besinler"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getCalorieData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu'));
          }

          final foodData = snapshot.data!;

          return ListView.builder(
            itemCount: foodData.length,
            itemBuilder: (context, index) {
              final food = foodData[index];
              final docId = food['documentId']; // Firestore'dan gelen docId
              return ListTile(
                title: Text(food['foodName']),
                subtitle: Text('Kalori: ${food['calories']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () async {
                    try {
                      await _firestoreService
                          .deleteFood(docId); // Silme fonksiyonunu çağırma
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Besin başarıyla silindi!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Silme işlemi sırasında hata oluştu.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
