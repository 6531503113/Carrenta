import 'package:flutter/material.dart';

class DetailPage extends StatelessWidget {
  final int checkInDays;
  final double total;
  final String name;
  final String carImage;
  final String docID;
  final String isRented;

  const DetailPage({
    Key? key,
    required this.checkInDays,
    required this.total,
    required this.name,
    required this.carImage,
    required this.docID,
    required this.isRented,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Total: $total'), // แสดงค่า total
            Text('Name: $name'), // แสดงค่า name
            Text('Is Rented: $isRented'), // แสดงค่า isRented
            // คุณสามารถแสดงข้อมูลอื่น ๆ ตามต้องการได้ที่นี่
          ],
        ),
      ),
    );
  }
}
