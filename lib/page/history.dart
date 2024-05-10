import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CheckListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Check History'),
        backgroundColor: Colors.blue, // เพิ่มสีพื้นหลังสีฟ้า
      ),
      body: CheckList(),
    );
  }
}

class CheckList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userEmail = currentUser?.email ?? '';

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('checks')
          .where('userEmail', isEqualTo: userEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          final checkDocs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: checkDocs.length,
            itemBuilder: (context, index) {
              final checkData = checkDocs[index].data();
              String carimg = checkData['carimg'];
              return ListTile(
                title: Text(checkData['name']),
                subtitle: Text('Total: \$${checkData['total']}'),
                leading: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(carimg.isNotEmpty
                          ? carimg
                          : 'https://t4.ftcdn.net/jpg/04/73/25/49/360_F_473254957_bxG9yf4ly7OBO5I0O5KABlN930GwaMQz.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // You can display more information here as needed
              );
            },
          );
        }
      },
    );
  }
}
