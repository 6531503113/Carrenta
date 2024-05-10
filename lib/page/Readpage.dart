import 'package:carrentalll/page/payment.dart';
import 'package:carrentalll/service/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> addCheck(
  DateTime checkInDate,
  DateTime checkOutDate,
  String name,
  String brand,
  double price,
  String carimg,
  String userEmail,
  double total,
) async {
  CollectionReference checks = FirebaseFirestore.instance.collection('checks');
  try {
    await checks.add({
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'name': name,
      'brand': brand,
      'price': price,
      'carimg': carimg,
      'userEmail': userEmail,
      'total': total,
    });
    print("Check-in and Check-out information added successfully!");
    int differenceInMilliseconds = checkOutDate.millisecondsSinceEpoch -
        checkInDate.millisecondsSinceEpoch;

    double differenceInSeconds = differenceInMilliseconds / 1000;

    double differenceInDays = differenceInSeconds / (3600 * 24);
    double pricetojau = differenceInDays * price;

    print("ราคาที่ต้องจ่าย = $pricetojau");
  } catch (error) {
    print("Failed to add Check-in and Check-out information: $error");
  }
}

FirestoreService firestoreService = FirestoreService();

class NewPopup {
  Future<void> openCheckinCheckoutBox(
      BuildContext context, String docID) async {
    // Get the currently logged in user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userEmail =
          user.email!; // Get the email of the currently logged in user

      DateTime? checkInDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2024),
        lastDate: DateTime(2100),
        helpText: 'Check-in Date', // Label for the check-in date picker
      );

      if (checkInDate != null) {
        DateTime? checkOutDate = await showDatePicker(
          context: context,
          initialDate: checkInDate,
          firstDate: checkInDate,
          lastDate: DateTime(2100),
          helpText: 'Check-out Date', // Label for the check-out date picker
        );

        if (checkOutDate != null) {
          // Both check-in and check-out dates are selected

          print('Check-in Date: $checkInDate');
          print('Check-out Date: $checkOutDate');

          // Retrieve existing car information
          DocumentSnapshot carSnapshot = await FirebaseFirestore.instance
              .collection('cars')
              .doc(docID)
              .get();
          Map<String, dynamic> carData =
              carSnapshot.data() as Map<String, dynamic>;
          // Extract car information

          String name = carData['name'];
          String brand = carData['brand'];
          double price = carData['price'].toDouble(); // Convert price to double
          String carimg = carData['carimg'];
          bool isRented = carData['isRented'] as bool; // Get rental status

          if (isRented) {
            // If isRented is true, it means the car is already rented and cannot be booked
            print('ไม่สามารถจองได้ เนื่องจากมีการจองแล้ว');
            return;
          }
          if (isRented == false) {
            // If isRented is true, it means the car is already rented and cannot be booked
            isRented = true;
            firestoreService.updateIsRented(
              docID,
              isRented, // ใช้ค่า newValue ที่เป็นค่าที่เปลี่ยนแปลงของ Switch
            );
          }

          int differenceInMilliseconds = checkOutDate.millisecondsSinceEpoch -
              checkInDate.millisecondsSinceEpoch;
          print("มีคนจอง $isRented");
          double differenceInSeconds = differenceInMilliseconds / 1000;

          double differenceInDays = differenceInSeconds / (3600 * 24);
          double pricetojau = differenceInDays * price;

          double total = pricetojau;

          // Instantiate FirestoreService and call updateIsRented method

          // Show a form to collect user information
          await addCheck(
            checkInDate,
            checkOutDate,
            name,
            brand,
            price,
            carimg,
            userEmail,
            total,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentPage(
                checkInDate: checkInDate,
                checkOutDate: checkOutDate,
                carName: name,
                carBrand: brand,
                carPrice: price,
                carImage: carimg,
                userEmail: userEmail,
                total: total, isRented: bool,

                // Set isRented to false since the booking is completed
              ),
            ),
          );

          print("มีคนจอง $isRented");
        }
      }
    } else {
      // User is not logged in
      // Handle this case according to your app's logic
      print('User is not logged in!');
    }
  }
}

class CarDetailPage extends StatelessWidget {
  final String docID;
  final String userEmail;

  const CarDetailPage({Key? key, required this.docID, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Detail',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(userEmail),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NewPopup().openCheckinCheckoutBox(context, docID),
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('cars').doc(docID).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            String carimg = data['carimg'] as String;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
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
                  SizedBox(height: 20),
                  Text(
                    'Name: ${data['name']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Brand: ${data['brand']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Price: ${data['price']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Status: ${data['isRented'] ? 'Rented' : 'Available'}',
                    style: TextStyle(
                      fontSize: 16,
                      color: data['isRented'] ? Colors.red : Colors.green,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Car ID: $docID',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
