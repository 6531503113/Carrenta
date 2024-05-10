import 'package:carrentalll/page/adminpage.dart';
import 'package:carrentalll/page/login.dart';
import 'package:carrentalll/page/userpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData && snapshot.data != null) {
              // Check if user is an admin using the admin token
              String adminToken = "CM4crgfxHBYCFj3QflhfGmb0HSz1";
              bool isAdmin = snapshot.data!.uid == adminToken;

              if (isAdmin) {
                // If user is an admin, navigate to admin page
                return HomePage(); // Replace AdminPage with your admin page widget
              } else {
                // If user is not an admin, navigate to home page
                return UserPage(
                  providerConfigs: [],
                ); // Replace HomePage with your home page widget
              }
            } else {
              return LoginPage(); // Replace LoginPage with your login page widget
            }
          }
        },
      ),
    );
  }
}
