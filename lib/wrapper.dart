// lib/wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng Stream của Firebase Auth để lắng nghe trạng thái đăng nhập
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Nếu đang chờ kết nối
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Nếu đã đăng nhập (snapshot có dữ liệu User)
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Nếu chưa đăng nhập
        return const AuthScreen();
      },
    );
  }
}