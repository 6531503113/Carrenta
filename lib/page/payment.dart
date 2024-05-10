import 'dart:async';
import 'package:carrentalll/service/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:carrentalll/page/userpage.dart';

class PaymentPage extends StatelessWidget {
  final double total;
  final String userEmail;
  const PaymentPage(
      {super.key,
      required this.total,
      required this.userEmail,
      required DateTime checkOutDate,
      required DateTime checkInDate,
      required String carBrand,
      required String carName,
      required String carImage,
      required double carPrice,
      required isRented});
  int calculateCRC(String payload) {
    int crc = 0xFFFF;
    int polynomial = 0x1021;

    List<int> bytes = payload.codeUnits;

    for (int byte in bytes) {
      crc ^= (byte << 8);
      for (int i = 0; i < 8; i++) {
        if ((crc & 0x8000) != 0) {
          crc = ((crc << 1) ^ polynomial) & 0xFFFF;
        } else {
          crc <<= 1;
        }
      }
    }

    return crc & 0xFFFF;
  }

  String generateQRCodeData(int total) {
    int num = 0;
    if (total >= 1000) {
      num = 7;
    } else if (total >= 100) {
      num = 6;
    } else if (total >= 10) {
      num = 5;
    } else if (total >= 1) {
      num = 4;
    }
    String payload =
        "00020101021229370016A000000677010111021309930001518365802TH5303764540$num$total.006304";

    int crc = calculateCRC(payload);
    String crcHex = crc.toRadixString(16).toUpperCase();
    // Pad with leading zeros if necessary to ensure the CRC is 4 digits long
    crcHex = crcHex.padLeft(4, '0');

    String qrCodeData = payload + crcHex;
    return qrCodeData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(userEmail),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200.0,
              child: QrImageView(
                data: generateQRCodeData(total
                    .toInt()), // เรียกใช้ generateQRCodeData และส่งค่า total เข้าไป
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 200.0,
              child: ElevatedButton(
                onPressed: () async {
                  await addPayment(total, userEmail);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentStatusPage(),
                    ),
                  );
                },
                child: const Text('Make Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> addPayment(double total, String userEmail) async {
  try {
    await FirebaseFirestore.instance.collection('payments').add({
      'total': total,
      'status': 'Pending',
      'userEmail': userEmail,
    });
    print('Payment added successfully!');
  } catch (error) {
    print('Failed to add payment: $error');
  }
}

class PaymentStatusPage extends StatelessWidget {
  const PaymentStatusPage({Key? key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Status'),
        actions: [
          IconButton(
            icon: Icon(Icons.house),
            color: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserPage(
                    providerConfigs: [],
                  ), // เปลี่ยนเป็นหน้าที่คุณต้องการไป
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Your History payment: $userEmail',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirestoreService().getChecksStreamForCurrentUser(userEmail),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  final checks = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: checks.length,
                    itemBuilder: (context, index) {
                      final check = checks[index];
                      final docID = check.id; // รับค่า docID จาก snapshot
                      final checkInDate = check['checkInDate'] as Timestamp;
                      final checkOutDate = check['checkOutDate'] as Timestamp;
                      final name = check['name'];
                      final carimg = check['carimg'];
                      final total = check['total'] as double;
                      final difference = checkOutDate
                          .toDate()
                          .difference(checkInDate.toDate());
                      final differenceInDays = difference.inDays;

                      print(
                          'จำนวนวันระหว่างเช็คอินและเช็คเอาท์: $differenceInDays วัน');

                      // Display relevant payment status information
                      return ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'จำนวนวันระหว่างเช็คอินและเช็คเอาท์: $differenceInDays วัน',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height: 8), // Add some vertical spacing
                            Text(
                              'ค่าใช้จ่ายทั้งหมด: $total',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                                height: 8), // Add some vertical spacing
                            Text(
                              'Name Car: $name',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        leading: SizedBox(
                          width: 100,
                          height: 100,
                          child: carimg.isNotEmpty
                              ? Image.network(
                                  carimg,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  'https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
