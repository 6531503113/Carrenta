import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  //get

  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  //create
  Future<void> addNote(String note) {
    return notes.add({
      'note': note,
    });
  }

  Future<void> addCheck(
      DateTime checkInDate,
      DateTime checkOutDate,
      String name,
      String brand,
      double price,
      String carimg,
      String userEmail,
      double total // New parameter for user email
      ) async {
    CollectionReference checks =
        FirebaseFirestore.instance.collection('checks');
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
    } catch (error) {
      print("Failed to add Check-in and Check-out information: $error");
    }
  }

  Future<void> addCar(
      String name, String brand, double price, String carimg, bool isRented) {
    CollectionReference cars = FirebaseFirestore.instance.collection('cars');

    return cars
        .add({
          'name': name,
          'brand': brand,
          'price': price,
          'carimg': carimg,
          'isRented': isRented, // เพิ่มข้อมูลสถานะเช่า
        })
        .then((value) => print("Car added successfully!"))
        .catchError((error) => print("Failed to add car: $error"));
  }

  //read
  Stream<QuerySnapshot> getChecksStream() {
    return FirebaseFirestore.instance.collection('checks').snapshots();
  }

  Stream<QuerySnapshot> getChecksStreamForCurrentUser(String userEmail) {
    return FirebaseFirestore.instance
        .collection('checks')
        .where('userEmail', isEqualTo: userEmail)
        .snapshots();
  }

  Stream<QuerySnapshot> getCarsStream() {
    return FirebaseFirestore.instance.collection('cars').snapshots();
  }

  //update
  Future<void> updateCars(String docID, String newName, String newBrand,
      double newPrice, String newCarimg, bool newIsRented) async {
    CollectionReference cars = FirebaseFirestore.instance.collection('cars');
    return cars.doc(docID).update({
      'name': newName,
      'brand': newBrand,
      'price': newPrice,
      'carimg': newCarimg,
      'isRented': newIsRented,

      // ทำการอัพเดทข้อมูลรถใหม่ที่ต้องการ ตามด้วยคอลัมน์และค่าใหม่
      // เช่น 'name': newName, 'brand': newBrand, 'price': newPrice
    });
  }

  Future<void> updateIsRented(String docID, bool isRented) {
    CollectionReference cars = FirebaseFirestore.instance.collection('cars');

    return cars
        .doc(docID)
        .update({'isRented': isRented})
        .then((value) => print("isRented updated successfully!"))
        .catchError((error) => print("Failed to update isRented: $error"));
  }

  Future<void> deleteCars(String docID) async {
    CollectionReference cars = FirebaseFirestore.instance.collection('cars');
    return cars.doc(docID).delete();
  }
}
