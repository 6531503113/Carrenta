import 'package:carrentalll/page/Readpage.dart';
import 'package:carrentalll/page/history.dart';
import 'package:carrentalll/page/userpage.dart';
import 'package:carrentalll/service/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void signUser() {
    FirebaseAuth.instance.signOut();
  }

  // Firestore service instance
  final FirestoreService _firestoreService = FirestoreService();

  // Text controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _carimgController = TextEditingController();

  // Method to show dialog for adding or updating car details
  void openNoteBox({String? docID, bool isRented = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Car'),
              ),
              TextField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextField(
                controller: _carimgController,
                decoration: const InputDecoration(labelText: 'URL IMG'),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                // Add new car
                _firestoreService.addCar(
                  _nameController.text,
                  _brandController.text,
                  double.parse(_priceController.text),
                  _carimgController.text,
                  isRented,
                );
              } else {
                // Update existing car
                _firestoreService.updateCars(
                  docID,
                  _nameController.text,
                  _brandController.text,
                  double.parse(_priceController.text),
                  _carimgController.text,
                  isRented,
                );
              }
              _nameController.clear();
              _brandController.clear();
              _priceController.clear();
              _carimgController.clear();
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Car Rental",
          style: TextStyle(
            color: Colors.white, // ระบุสีข้อความเป็นสีขาว
          ),
        ),
        backgroundColor: Colors.blue, // เพิ่มสีพื้นหลังสีฟ้า
        actions: [
          IconButton(
            onPressed: signUser,
            icon: const Icon(Icons.logout),
            color: Colors.white,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(),
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getCarsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<DocumentSnapshot> carsList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: carsList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = carsList[index];
                String docID = document.id;
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String carText = data['name'] as String;
                String carBrand = data['brand'] as String;
                double carPrice = data['price'] as double;
                String carImg = data['carimg'] as String;
                bool isRented = data['isRented'] as bool;

                return ListTile(
                  title: Text(
                    carText,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  leading: carImg.isNotEmpty
                      ? Image.network(carImg)
                      : Image.network(
                          'https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg',
                        ),
                  trailing: SizedBox(
                    width: 110,
                    height: 100,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Brand: $carBrand"),
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () =>
                                openNoteBox(docID: docID, isRented: isRented),
                          ),
                          IconButton(
                            onPressed: () =>
                                _firestoreService.deleteCars(docID),
                            icon: const Icon(Icons.delete),
                          ),
                          Switch.adaptive(
                            value: isRented ?? false,
                            onChanged: (newValue) {
                              _firestoreService.updateIsRented(
                                docID,
                                newValue,
                              );
                              setState(() {
                                isRented = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  subtitle: Text(
                    "Price: $carPrice",
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarDetailPage(
                          docID: docID,
                          userEmail: '',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserPage(providerConfigs: []),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckListPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserPage(providerConfigs: []),
              ),
            );
          }
        },
        selectedItemColor: Colors.blue, // สีของไอคอนที่ถูกเลือก
        unselectedItemColor: Colors.grey, // สีของไอคอนที่ไม่ถูกเลือก
        showUnselectedLabels: true, // แสดง label ของไอคอนที่ไม่ถูกเลือก
      ),
    );
  }
}
