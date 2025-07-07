// lib/screens/daily_schedule_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/daily_plan.dart';
import '../models/location_item.dart';
import '../providers/plan_provider.dart';

class DailyScheduleDetailScreen extends StatelessWidget {
  final String dayId;

  const DailyScheduleDetailScreen({super.key, required this.dayId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PlanProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch trình chi tiết'),
        // Nút Export sẽ được đặt ở đây sau
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement export to Excel
            },
            tooltip: 'Xuất ra Excel',
          )
        ],
      ),
      body: StreamBuilder<List<DailyPlan>>(
        // Lắng nghe toàn bộ stream lịch trình
        stream: provider.getDailyPlansStream(),
        builder: (context, snapshotPlans) {
          if (!snapshotPlans.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          // Tìm đúng ngày cần hiển thị dựa trên dayId
          final dayPlan = snapshotPlans.data!.firstWhere(
                (plan) => plan.id == dayId,
            orElse: () => DailyPlan(id: '', date: DateTime.now(), entries: [], title: 'Không tìm thấy ngày'),
          );

          return StreamBuilder<List<LocationItem>>(
            // Lắng nghe stream thư viện để lấy thông tin chi tiết
            stream: provider.getLocationsStream(),
            builder: (context, snapshotLocations) {
              if (!snapshotLocations.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allLocations = snapshotLocations.data!;

              return _buildDetailedView(context, dayPlan, allLocations);
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailedView(BuildContext context, DailyPlan dayPlan, List<LocationItem> allLocations) {
    // Tính toán tổng hợp
    double totalCost = 0;
    Duration totalActivityTime = Duration.zero;

    for (var entry in dayPlan.entries) {
      final location = allLocations.firstWhere(
              (loc) => loc.id == entry.locationId,
          orElse: () => LocationItem(id: '', name: '')
      );
      totalCost += location.estimatedCost;
      totalActivityTime += entry.activityDuration;
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // --- THÔNG TIN TỔNG QUAN ---
        Text(dayPlan.title, style: Theme.of(context).textTheme.headlineMedium),
        Text(DateFormat('EEEE, dd MMMM yyyy', 'vi_VN').format(dayPlan.date), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryInfo('Tổng chi phí', NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalCost), Icons.attach_money, Colors.orange),
                _buildSummaryInfo('Thời gian hoạt động', '${totalActivityTime.inHours}h ${totalActivityTime.inMinutes.remainder(60)}m', Icons.timer_outlined, Colors.blue),
              ],
            ),
          ),
        ),
        const Divider(height: 32, thickness: 1),

        // --- DANH SÁCH HOẠT ĐỘNG CHI TIẾT ---
        Text('Các hoạt động', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),

        for (var entry in dayPlan.entries) ...[
          _buildActivityCard(context, entry, allLocations.firstWhere((loc) => loc.id == entry.locationId)),
          const SizedBox(height: 8),
        ],
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

  Widget _buildActivityCard(BuildContext context, entry, LocationItem location) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.location_on_outlined)),
        title: Text(location.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location.address),
            if(location.notes.isNotEmpty) Text('Ghi chú chung: ${location.notes}'),
            if(entry.scheduleNotes.isNotEmpty) Text('Ghi chú riêng: ${entry.scheduleNotes}'),
            Text('Thời gian tại đây: ~${entry.activityDuration.inMinutes} phút'),
          ],
        ),
      ),
    );
  }
}