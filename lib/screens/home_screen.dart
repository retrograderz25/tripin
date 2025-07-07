// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/plan_provider.dart';
import '../widgets/location_list_item.dart';
import '../widgets/add_location_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddLocationForm(BuildContext context) {
    // showModalBottomSheet is a built-in Flutter function that
    // displays a slick, dismissible sheet from the bottom.
    showModalBottomSheet(
      context: context,
      // isScrollControlled allows the sheet to take up more
      // screen space, which is needed for a form with a keyboard.
      isScrollControlled: true,
      // We use a dummy container for now. We will replace this.
      builder: (_) {
        return const AddLocationForm();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Journey Planner'),
        backgroundColor: Colors.teal, // Cho một chút màu mè
      ),
      body: Consumer<PlanProvider>(
        builder: (context, planProvider, child) {
          // Lấy danh sách địa điểm từ provider
          final locations = planProvider.locations;

          // Nếu danh sách rỗng, hiển thị một thông báo
          if (locations.isEmpty) {
            return const Center(
              child: Text('Chưa có địa điểm nào. Hãy thêm một vài nơi nhé!'),
            );
          }

          // Nếu có dữ liệu, hiển thị dưới dạng ListView
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),

            itemCount: locations.length,
            itemBuilder: (ctx, index) {
              final location = locations[index];
              // Hiện tại, chỉ hiển thị tên trong một ListTile đơn giản
              return LocationListItem(location: location);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // We will define this function in the next step
          _showAddLocationForm(context);
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        tooltip: 'Thêm địa điểm mới',
      ),
    );
  }
}