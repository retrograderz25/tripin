// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// KHÔNG CẦN 'package:cloud_firestore/cloud_firestore.dart' nữa
import '../models/location_item.dart';
import '../providers/plan_provider.dart';
import '../widgets/location_list_item.dart';
import '../widgets/add_location_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddLocationForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder( // Thêm bo tròn cho đẹp
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return const AddLocationForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy provider ra để sử dụng
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Journey Planner'),
        backgroundColor: Colors.teal,
      ),
      // --- THAY ĐỔI LỚN BẮT ĐẦU TỪ ĐÂY ---
      body: StreamBuilder<List<LocationItem>>(
        // 1. Lấy stream từ provider, không gọi Firestore trực tiếp
        stream: planProvider.getLocationsStream(),
        builder: (context, snapshot) {
          // 2. Các bước kiểm tra trạng thái snapshot giữ nguyên
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Chưa có địa điểm nào. Hãy thêm một vài nơi nhé!'),
            );
          }

          // 3. Dữ liệu đã là List<LocationItem>, không cần chuyển đổi nữa
          final locations = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: locations.length,
            itemBuilder: (ctx, index) {
              final location = locations[index];
              return LocationListItem(location: location);
            },
          );
        },
      ),
      // --- KẾT THÚC THAY ĐỔI ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLocationForm(context);
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'Thêm địa điểm mới',
      ),
    );
  }
}