import 'package:flutter/material.dart';
import 'firestore_services.dart';

class VeriDuzenleme extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Veri Düzenleme"),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getCalorieData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Bir hata oluştu.'));
          }

          final foodData = snapshot.data ?? [];

          if (foodData.isEmpty) {
            return const Center(child: Text('Hiçbir veri bulunamadı.'));
          }

          return ListView.builder(
            itemCount: foodData.length,
            itemBuilder: (context, index) {
              final food = foodData[index];
              final docId =
                  food['documentId']; // Firestore'dan alınan belge ID'si
              return ListTile(
                title: Text(food['foodName']),
                subtitle: Text('Kalori: ${food['calories']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VeriDuzenlemeForm(
                          docId: docId,
                          initialFoodName: food['foodName'],
                          initialCalories: food['calories'],
                        ),
                      ),
                    );
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

class VeriDuzenlemeForm extends StatefulWidget {
  final String docId;
  final String initialFoodName;
  final int initialCalories;

  const VeriDuzenlemeForm({
    Key? key,
    required this.docId,
    required this.initialFoodName,
    required this.initialCalories,
  }) : super(key: key);

  @override
  _VeriDuzenlemeFormState createState() => _VeriDuzenlemeFormState();
}

class _VeriDuzenlemeFormState extends State<VeriDuzenlemeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _foodNameController;
  late TextEditingController _caloriesController;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(text: widget.initialFoodName);
    _caloriesController =
        TextEditingController(text: widget.initialCalories.toString());
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _updateFood() {
    if (_formKey.currentState!.validate()) {
      final String updatedFoodName = _foodNameController.text.trim();
      final int updatedCalories = int.parse(_caloriesController.text.trim());

      _firestoreService
          .updateFood(widget.docId, updatedFoodName, updatedCalories)
          .then((_) {
        Navigator.pop(context); // Düzenleme sonrası geri dön
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veri başarıyla güncellendi!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Güncelleme sırasında hata oluştu: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Veriyi Düzenle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _foodNameController,
                decoration: const InputDecoration(labelText: 'Besin Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir besin adı girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Kalori'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir kalori değeri girin.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Lütfen geçerli bir sayı girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _updateFood,
                child: const Text('Güncelle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
