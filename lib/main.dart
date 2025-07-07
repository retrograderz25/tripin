// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/plan_provider.dart';
import './screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider có nhiệm vụ "cung cấp" PlanProvider cho tất cả
    // các widget con của nó (ở đây là toàn bộ ứng dụng).
    return ChangeNotifierProvider(
      create: (ctx) => PlanProvider(),
      child: MaterialApp(
        title: 'Our Journey Planner',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeScreen(), // Màn hình đầu tiên là HomeScreen
        debugShowCheckedModeBanner: false, // Tắt banner debug
      ),
    );
  }
}