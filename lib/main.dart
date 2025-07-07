// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import './providers/plan_provider.dart';
import './screens/home_screen.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart'; // Import
import 'wrapper.dart'; // Import

void main() async {
  // Đảm bảo các binding của Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo định dạng ngày tháng cho tiếng Việt
  await initializeDateFormatting('vi_VN', null);
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
      ],
      child: ChangeNotifierProvider(
        create: (ctx) => PlanProvider(),
        child: MaterialApp(
          title: 'tripin by hehe',
      
          // --- BẮT ĐẦU KHỐI THEME ĐÃ SỬA LỖI ---
          theme: ThemeData(
            // Sử dụng colorScheme làm nguồn màu chính.
            // fromSeed sẽ tự động tạo ra một bảng màu hài hòa.
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFA9FFF2), // Màu "hạt giống" là màu
              brightness: Brightness.light,       // Sử dụng theme sáng
            ),
      
            // Cho phép sử dụng các màu từ colorScheme cho các widget
            useMaterial3: true,
      
            // --- TÙY CHỈNH GIAO DIỆN CÁC WIDGET CỤ THỂ ---
      
            appBarTheme: const AppBarTheme(
              // Tự động sử dụng màu từ colorScheme nếu không được chỉ định
              // nhưng chúng ta có thể ghi đè nếu muốn một màu cụ thể.
              // Ví dụ: backgroundColor: Color(0xFFC2185B),
              elevation: 2,
              // foregroundColor sẽ được theme tự động chọn (đen hoặc trắng)
              // để đảm bảo độ tương phản tốt nhất với màu nền.
            ),
      
            cardTheme: CardThemeData(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
      
            // Bạn vẫn có thể tùy chỉnh các theme khác nếu cần
            // floatingActionButtonTheme: FloatingActionButtonThemeData(
            //   backgroundColor: const Color(0xFFE91E63),
            // ),
          ),
          // --- KẾT THÚC KHỐI THEME ---
      
          home: const Wrapper(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}