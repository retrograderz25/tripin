// lib/widgets/schedule_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_plan.dart';
import '../models/location_item.dart';
import '../providers/plan_provider.dart';
import 'package:intl/intl.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng Row để tạo giao diện 2 cột
    return Row(
      children: [
        // --- CỘT TRÁI: DANH SÁCH CÁC NGÀY ---
        _buildDaysList(context),

        // Dấu ngăn cách
        const VerticalDivider(thickness: 1, width: 1),

        // --- CỘT PHẢI: THƯ VIỆN ĐỊA ĐIỂM ---
        _buildLocationsLibrary(context),
      ],
    );
  }

  // Widget cho cột trái
  Widget _buildDaysList(BuildContext context) {
    final provider = context.watch<PlanProvider>();

    return SizedBox(
      width: 350, // Tăng chiều rộng một chút
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kế hoạch', style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.add_box_rounded, color: Colors.teal),
                  onPressed: () {
                    // TODO: Hiển thị form thêm ngày mới
                    // Tạm thời thêm ngày hôm nay
                    context.read<PlanProvider>().addDailyPlan(DateTime.now(), "Ngày mới");
                  },
                  tooltip: 'Thêm ngày mới',
                )
              ],
            ),
          ),
          Expanded(
            // DÙNG STREAMBUILDER ĐỂ LẤY DỮ LIỆU NGÀY
            child: StreamBuilder<List<DailyPlan>>(
              stream: provider.getDailyPlansStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Chưa có ngày nào.'));
                }

                final plans = snapshot.data!;

                // Tự động chọn ngày đầu tiên nếu chưa có ngày nào được chọn
                if (provider.selectedDayId == null && plans.isNotEmpty) {
                  Future.microtask(() => provider.selectDay(plans.first.id));
                }

                return ListView.builder(
                  itemCount: plans.length,
                  itemBuilder: (ctx, index) {
                    final day = plans[index];
                    final isSelected = provider.selectedDayId == day.id;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: isSelected ? Colors.teal.withOpacity(0.2) : null,
                      child: ListTile(
                        title: Text(day.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(day.date)),
                            const SizedBox(height: 4),
                            if (day.entries.isEmpty)
                              const Text('Chưa có hoạt động', style: TextStyle(fontStyle: FontStyle.italic)),
                            for (var entry in day.entries)
                              Text('• ${entry.locationName}', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        onTap: () {
                          provider.selectDay(day.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho cột phải
  Widget _buildLocationsLibrary(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Thư viện địa điểm', style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            // Dùng StreamBuilder để lấy danh sách địa điểm từ Firestore
            child: StreamBuilder<List<LocationItem>>(
              stream: planProvider.getLocationsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final locations = snapshot.data!;
                locations.sort((a,b) => a.name.compareTo(b.name));

                return ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (ctx, index) {
                    final location = locations[index];
                    return ListTile(
                      title: Text(location.name),
                      subtitle: Text(location.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                        onPressed: () {
                          // Gọi hàm thêm vào lịch trình
                          context.read<PlanProvider>().addLocationToSchedule(location);

                          // Hiển thị thông báo nhỏ
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã thêm "${location.name}" vào lịch trình.'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Thêm vào ngày đang chọn',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}