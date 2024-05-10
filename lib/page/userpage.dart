import 'package:carrentalll/page/Readpage.dart';
import 'package:carrentalll/page/history.dart';
import 'package:carrentalll/page/login.dart';
import 'package:carrentalll/service/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key, required this.providerConfigs}) : super(key: key);

  final List<dynamic> providerConfigs;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  void signUser() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Car",
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getCarsStream(),
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
                String cartext = data['name'] as String;
                String carbrand = data['brand'] as String;
                double carprice = data['price'] as double;
                String carimg = data['carimg'] as String;
                bool isRented = data['isRented'] as bool;

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      cartext,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                            carimg.isNotEmpty
                                ? carimg
                                : 'https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Brand: $carbrand",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          "isRented: $isRented",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isRented ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      "Price : $carprice",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        String? userEmail = user.email;
                        if (userEmail != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CarDetailPage(
                                docID: docID,
                                userEmail: userEmail,
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
        onTap: (int index) {
          if (index == 1) {
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
                builder: (context) => LoginPage(),
              ),
            );
          }
        },
      ),
    );
  }
}
