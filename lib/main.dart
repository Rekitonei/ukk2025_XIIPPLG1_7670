import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ukk_isnaini_2025/homepage.dart';
import 'package:ukk_isnaini_2025/loginpage.dart';
import 'package:ukk_isnaini_2025/registerpage.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<Widget> _checkUserStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return LoginPage(); // Jika belum login, arahkan ke LoginScreen
      } else {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc['role'] ?? 'member';
          return Homepage(role: role);
        } else {
          // Jika akun ada di Auth tetapi tidak di Firestore, logout dulu
          await FirebaseAuth.instance.signOut();
          return LoginPage();
        }
      }
    } catch (e) {
      print("❌ ERROR saat mengecek status pengguna: $e");
      return LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ToDo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<Widget>(
        future: _checkUserStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text("Terjadi kesalahan")));
          } else {
            return snapshot.data ?? LoginPage();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => Registerpage(),
        '/dashboard': (context) => Homepage(role: 'member')
      },
    );
  }
}