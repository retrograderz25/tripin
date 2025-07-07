// lib/widgets/schedule_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripin/widgets/simple_location_card.dart';
import '../models/daily_plan.dart';
import '../models/location_item.dart';
import '../providers/plan_provider.dart';
import 'package:intl/intl.dart';
import '../screens/daily_schedule_detail_screen.dart';
import 'add_edit_day_dialog.dart';

class ScheduleTab extends StatelessWidget {
  const ScheduleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildDaysList(context),
        const VerticalDivider(thickness: 1, width: 1),
        _buildLocationsLibrary(context),
      ],
    );
  }

  // Cột trái: Danh sách các ngày trong kế hoạch
  Widget _buildDaysList(BuildContext context) {
    // Dùng .watch<T>() để widget này tự động build lại khi provider thay đổi
    // (ví dụ: khi selectDay)
    final provider = context.watch<PlanProvider>();

    return SizedBox(
      width: 350,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kế hoạch', style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.add_box_rounded, color: Colors.lightBlueAccent ),
                  onPressed: () {
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
            child: StreamBuilder<List<DailyPlan>>(
              stream: provider.getDailyPlansStream(),
              builder: (context, snapshotPlans) {
                if (snapshotPlans.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // CẢI TIẾN #1: Giao diện trạng thái trống tốt hơn
                if (!snapshotPlans.hasData || snapshotPlans.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có ngày nào trong kế hoạch.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Nhấn vào nút + ở trên để bắt đầu.',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final plans = snapshotPlans.data!;
                if (provider.selectedDayId == null && plans.isNotEmpty) {
                  Future.microtask(() => provider.selectDay(plans.first.id));
                }

                // CẢI TIẾN #3: Lồng StreamBuilder để lấy dữ liệu thư viện và tính chi phí
                return StreamBuilder<List<LocationItem>>(
                  stream: provider.getLocationsStream(),
                  builder: (context, snapshotLocations) {
                    // Nếu chưa có dữ liệu locations, vẫn hiển thị list ngày nhưng chưa có chi phí
                    final allLocations = snapshotLocations.data ?? [];

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: plans.length,
                      itemBuilder: (ctx, index) {
                        final day = plans[index];
                        final isSelected = provider.selectedDayId == day.id;

                        // Tính toán tổng chi phí cho ngày
                        double totalCost = 0;
                        if (allLocations.isNotEmpty) {
                          for (var entry in day.entries) {
                            final location = allLocations.firstWhere(
                                  (loc) => loc.id == entry.locationId,
                              orElse: () => LocationItem(id: '', name: 'Not Found'),
                            );
                            totalCost += location.estimatedCost;
                          }
                        }

                        return Card(
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: isSelected ? Colors.greenAccent : null,
                          
                          child: InkWell(
                            onTap: () {
                              // Vẫn chọn ngày để highlight
                              provider.selectDay(day.id);

                              // Mở màn hình chi tiết trong một tab mới
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DailyScheduleDetailScreen(dayId: day.id),
                                ),
                              );
                            },
                            child: ListTile(
                              // onTap: () => provider.selectDay(day.id),
                              title: Row(
                                children: [
                                  Expanded(child: Text(day.title, style: const TextStyle(fontWeight: FontWeight.bold))),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20, color: Colors.black),
                                    onPressed: () => showDialog(context: context, builder: (ctx) => AddEditDayDialog(dailyPlan: day)),
                                    tooltip: 'Sửa ngày',
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'Xóa ngày này',
                                onPressed: () => _showDeleteDayConfirmation(context, day),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(day.date)),
                            
                                  // Hiển thị tổng chi phí
                                  if (totalCost > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Chi phí: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(totalCost)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  if (day.entries.isEmpty)
                                    const Text('Chưa có hoạt động', style: TextStyle(fontStyle: FontStyle.italic)),
                                  for (var entry in day.entries)
                                    Row(
                                      children: [
                                        Expanded(child: Text('• ${entry.locationName}', style: const TextStyle(fontSize: 13))),
                                        SizedBox(
                                          height: 24, width: 24,
                                          child: IconButton(
                                            padding: EdgeInsets.zero, iconSize: 16,
                                            icon: const Icon(Icons.close, color: Colors.redAccent),
                                            onPressed: () => context.read<PlanProvider>().removeLocationFromSchedule(day.id, entry),
                                            tooltip: 'Xóa hoạt động này',
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  // Tách dialog xóa ra một hàm riêng cho sạch sẽ
  void _showDeleteDayConfirmation(BuildContext context, DailyPlan day) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa "${day.title}" và tất cả hoạt động trong đó?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dCtx).pop(), child: const Text('Hủy')),
          TextButton(
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            onPressed: () {
              context.read<PlanProvider>().deleteDailyPlan(day.id);
              Navigator.of(dCtx).pop();
              // CẢI TIẾN #2: Thêm SnackBar xác nhận
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa ngày "${day.title}"'),
                  backgroundColor: Colors.red[800],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Cột phải: Thư viện các địa điểm
  Widget _buildLocationsLibrary(BuildContext context) {
    // ... code của hàm này không thay đổi ...
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Thư viện địa điểm', style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: StreamBuilder<List<LocationItem>>(
              stream: planProvider.getLocationsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final locations = snapshot.data!;
                locations.sort((a,b) => a.name.compareTo(b.name));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  itemCount: locations.length,
                  itemBuilder: (ctx, index) {
                    final location = locations[index];
                    return SimpleLocationCard(location: location);
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