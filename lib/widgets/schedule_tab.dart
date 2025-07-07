// lib/widgets/schedule_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_plan.dart';
import '../models/location_item.dart';
import '../providers/plan_provider.dart';
import 'package:intl/intl.dart';

import 'add_edit_day_dialog.dart';

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
                    // HIỂN THỊ DIALOG
                    showDialog(
                      context: context,
                      builder: (ctx) => const AddEditDayDialog(),
                    );
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
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                day.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            // Nút sửa ngày
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: Colors.black54),
                              onPressed: () {
                                // Mở dialog ở chế độ sửa, truyền ngày hiện tại vào
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AddEditDayDialog(dailyPlan: day),
                                );
                              },
                              tooltip: 'Sửa ngày',
                            ),
                          ],
                        ),
                        // Thêm nút xóa cho cả ngày
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            // Thêm dialog xác nhận trước khi xóa
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: Text('Bạn có chắc muốn xóa "${day.title}" và tất cả hoạt động trong đó?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(dCtx).pop(), child: const Text('Hủy')),
                                  TextButton(
                                    onPressed: () {
                                      context.read<PlanProvider>().deleteDailyPlan(day.id);
                                      Navigator.of(dCtx).pop();
                                    },
                                    child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Xóa ngày này',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(day.date)),
                            const SizedBox(height: 4),
                            if (day.entries.isEmpty)
                              const Text('Chưa có hoạt động', style: TextStyle(fontStyle: FontStyle.italic)),
                            for (var entry in day.entries)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text('• ${entry.locationName}', style: const TextStyle(fontSize: 13))),
                                  // Nút xóa nhỏ cho từng hoạt động
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      iconSize: 16,
                                      icon: const Icon(Icons.close, color: Colors.grey),
                                      onPressed: () {
                                        context.read<PlanProvider>().removeLocationFromSchedule(day.id, entry);
                                      },
                                      tooltip: 'Xóa hoạt động này',
                                    ),
                                  ),
                                ],
                              ),
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