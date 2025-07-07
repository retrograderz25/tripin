// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
// --- CÁC WIDGET MỚI SẼ ĐƯỢC TẠO ---
import '../widgets/locations_library_tab.dart';
import '../widgets/schedule_tab.dart';
import '../widgets/add_location_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddLocationForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddLocationForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('trip planner'),
        backgroundColor: Colors.lightBlueAccent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.location_city), text: 'Thư viện'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Lịch trình'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // --- CÁC WIDGET TAB MỚI SẼ ĐƯỢC ĐẶT Ở ĐÂY ---
          LocationsLibraryTab(),
          ScheduleTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLocationForm(context),
        backgroundColor: Colors.lightBlueAccent,
        child: const Icon(Icons.add),
        tooltip: 'Thêm địa điểm mới',
      ),
    );
  }
}