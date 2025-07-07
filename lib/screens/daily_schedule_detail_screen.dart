// lib/screens/daily_schedule_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/daily_plan.dart';
import '../models/location_item.dart';
import '../models/schedule_entry.dart';
import '../providers/plan_provider.dart';

class DailyScheduleDetailScreen extends StatelessWidget {
  final String dayId;

  const DailyScheduleDetailScreen({super.key, required this.dayId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PlanProvider>();

    return StreamBuilder<List<DailyPlan>>(
      stream: provider.getDailyPlansStream(),
      builder: (context, snapshotPlans) {
        if (snapshotPlans.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshotPlans.hasError) {
          return Scaffold(body: Center(child: Text('Lỗi tải lịch trình: ${snapshotPlans.error}')));
        }
        if (!snapshotPlans.hasData || snapshotPlans.data!.isEmpty) {
          return const Scaffold(appBar: null, body: Center(child: Text('Không có dữ liệu lịch trình.')));
        }

        final dayPlan = snapshotPlans.data!.firstWhere(
              (plan) => plan.id == dayId,
          orElse: () => DailyPlan(id: '', date: DateTime.now(), entries: [], title: 'Lỗi: Không tìm thấy ngày'),
        );

        if (dayPlan.id.isEmpty) {
          return Scaffold(appBar: AppBar(title: const Text("Lỗi")), body: const Center(child: Text('Không tìm thấy thông tin cho ngày này.')));
        }

        return StreamBuilder<List<LocationItem>>(
          stream: provider.getLocationsStream(),
          builder: (context, snapshotLocations) {
            if (snapshotLocations.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (snapshotLocations.hasError) {
              return Scaffold(body: Center(child: Text('Lỗi tải thư viện địa điểm: ${snapshotLocations.error}')));
            }

            final allLocations = snapshotLocations.data ?? [];

            return Scaffold(
              appBar: AppBar(
                title: Text(dayPlan.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download_for_offline_rounded),
                    onPressed: () {
                      provider.exportDailyPlanToExcel(dayPlan, allLocations);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đang tạo file Excel...'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    tooltip: 'Xuất ra Excel',
                  )
                ],
              ),
              body: _buildDetailedView(context, dayPlan, allLocations),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailedView(BuildContext context, DailyPlan dayPlan, List<LocationItem> allLocations) {
    double totalCost = 0;
    Duration totalActivityTime = Duration.zero;
    Duration totalTravelTime = Duration.zero;

    for (var entry in dayPlan.entries) {
      final location = allLocations.firstWhere(
              (loc) => loc.id == entry.locationId,
          orElse: () => LocationItem(id: '', name: '')
      );
      totalCost += location.estimatedCost;
      totalActivityTime += entry.activityDuration;
      totalTravelTime += entry.travelTime;
    }
    Duration totalTime = totalActivityTime + totalTravelTime;

    // --- Tách việc xây dựng danh sách hoạt động ra một biến riêng ---
    List<Widget> activityWidgets = [];
    for (var i = 0; i < dayPlan.entries.length; i++) {
      // Tìm location tương ứng với entry
      final location = allLocations.firstWhere(
              (loc) => loc.id == dayPlan.entries[i].locationId,
          orElse: () => LocationItem(id: '', name: 'Không tìm thấy')
      );
      // Thêm Card
      activityWidgets.add(_buildActivityCard(context, dayPlan.entries[i], location, i + 1));
      // Thêm khoảng cách
      activityWidgets.add(const SizedBox(height: 8));
    }
    // -------------------------------------------------------------

    return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
        Text(dayPlan.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
    Text(DateFormat('EEEE, dd MMMM yyyy', 'vi_VN').format(dayPlan.date), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
    const SizedBox(height: 16),
    Card(
    elevation: 2,
    child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
    _buildSummaryInfo('Tổng chi phí', NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalCost), Icons.monetization_on_outlined, Colors.orange),
    _buildSummaryInfo('Tổng thời gian', '${totalTime.inHours}h ${totalTime.inMinutes.remainder(60)}m', Icons.hourglass_bottom_rounded, Colors.blue),
    ],
    ),
    ),
    ),
    const Divider(height: 32, thickness: 1),
    Text('Các hoạt động', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 8),

    if (dayPlan.entries.isEmpty)
    const Padding(
    padding: EdgeInsets.symmetric(vertical: 24.0),
    child: Center(child: Text('Chưa có hoạt động nào trong ngày này.', style: TextStyle(color: Colors.grey))),
    ),

          ...activityWidgets,
    ],
    );
  }

  Widget _buildSummaryInfo(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Khi định nghĩa hàm private thì có dấu gạch dưới
  Widget _buildActivityCard(BuildContext context, ScheduleEntry entry, LocationItem location, int index) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          child: Text('$index'),
        ),
        title: Text(location.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (location.address.isNotEmpty)
              Text(location.address),
            if (location.notes.isNotEmpty)
              Text('Ghi chú chung: ${location.notes}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            if (entry.scheduleNotes.isNotEmpty)
              Text('Ghi chú riêng: ${entry.scheduleNotes}', style: const TextStyle(fontStyle: FontStyle.italic)),
            Text('Thời gian tại đây: ~${entry.activityDuration.inMinutes} phút'),
          ],
        ),
      ),
    );
  }
}