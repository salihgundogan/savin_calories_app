import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_services.dart';
import 'tabloGoruntuleme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final FirestoreService _firestoreService = FirestoreService();

  // Yeni veri ekleme için metin kontrolcüleri
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  List<Widget> body = const [
    Icon(Icons.home),
    Icon(Icons.menu),
    Icon(Icons.person_3_outlined),
    Icon(Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("data"),
      ),
      body: Center(
        child: body[_currentIndex],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/beslenme2.png",
                    width: 240,
                    height: 90,
                  ),
                  const SizedBox(height: 17),
                  const Text(
                    'HOŞGELDİNİZ',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text("Besin Ekleme"),
              onTap: () {
                _showAddDataDialog(context);
              },
            ),
            ListTile(
              title: const Text("Besinleri Görüntüleme ve Silme"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => tabloGoruntuleme()),
                );
              },
            ),
            ListTile(
              title: const Text("tus_4"),
              onTap: () {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.purple,
        items: const [
          BottomNavigationBarItem(
            label: "Home",
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: "Menu",
            icon: Icon(Icons.menu),
          ),
          BottomNavigationBarItem(
            label: "Person",
            icon: Icon(Icons.person),
          ),
          BottomNavigationBarItem(
            label: "Settings",
            icon: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  // Veri ekleme diyalog kutusu
  void _showAddDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Kalori Verisi Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _foodNameController,
                decoration: const InputDecoration(labelText: 'Yemek Adı'),
              ),
              TextField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Kalori'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _addData();
                Navigator.pop(context);
              },
              child: const Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _showOverlayMessage(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height *
            0.1, // Ekranın üst kısmına konumlandırma
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    // Overlay Mesajını Göster
    overlay.insert(overlayEntry);

    // 2 Saniye Sonra Mesajı Kaldır
    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // Veri ekleme işlemi
  void _addData() {
    final String foodName = _foodNameController.text.trim();
    final String caloriesText = _caloriesController.text.trim();
    if (foodName.isNotEmpty && caloriesText.isNotEmpty) {
      final int calories = int.parse(caloriesText);
      _firestoreService.addData(foodName, calories);
      _foodNameController.clear();
      _caloriesController.clear();
    } else {
      _showOverlayMessage('Lütfen tüm alanları doldurun.');
    }
  }
}
