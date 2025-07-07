// lib/widgets/location_list_item.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/location_item.dart';
import '../providers/plan_provider.dart';
import 'add_location_form.dart';

class LocationListItem extends StatelessWidget {
  // Widget này nhận một đối tượng LocationItem để hiển thị
  final LocationItem location;

  const LocationListItem({
    super.key,
    required this.location,
  });

  // Hàm trợ giúp để mở URL
  void _launchURL(BuildContext context) async {
    if (location.referenceUrl.isEmpty) return;

    final Uri url = Uri.parse(location.referenceUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Nếu không mở được, hiển thị một thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở link: ${location.referenceUrl}')),
      );
    }
  }

  void _showEditForm(BuildContext context, LocationItem locationToEdit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        // Đây là điểm mấu chốt: truyền dữ liệu vào form
        return AddLocationForm(existingLocation: locationToEdit);
      },
    );
  }

  // Hàm trợ giúp để lấy icon tương ứng với category
  IconData _getCategoryIcon(ItemCategory category) {
    switch (category) {
      case ItemCategory.sightseeing:
        return Icons.camera_alt;
      case ItemCategory.food:
        return Icons.restaurant;
      case ItemCategory.shopping:
        return Icons.shopping_bag;
      case ItemCategory.other:
        return Icons.place;
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String locationId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa địa điểm này không? Hành động này không thể hoàn tác.'),
        actions: <Widget>[
          // Nút "Hủy"
          TextButton(
            child: const Text('Hủy'),
            onPressed: () {
              // Đóng hộp thoại
              Navigator.of(ctx).pop();
            },
          ),
          // Nút "Xóa"
          TextButton(
            child: Text(
              'Xóa',
              style: TextStyle(color: Colors.red[700]),
            ),
            onPressed: () {
              // Gọi hàm xóa từ provider
              Provider.of<PlanProvider>(context, listen: false).deleteLocation(locationId);
              // Đóng hộp thoại
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Card để tạo hiệu ứng nổi và có bo tròn
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hàng đầu tiên: Tên địa điểm và nút mở link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dùng Flexible để tên địa điểm không bị tràn khi quá dài
                Flexible(
                  child: Text(
                    location.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Chỉ hiển thị nút link nếu có URL
                Row(
                  children: [
                    if (location.referenceUrl.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.link, color: Colors.blue),
                        onPressed: () => _launchURL(context),
                        tooltip: 'Mở link tham khảo',
                      ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.grey[700]),
                      onPressed: () {
                        // Gọi hàm để hiển thị form
                        _showEditForm(context, location);
                      },
                      tooltip: 'Sửa địa điểm',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red[700]),
                      onPressed: () {
                        // Chúng ta sẽ gọi hộp thoại xác nhận từ đây
                        _showDeleteConfirmationDialog(context, location.id);
                      },
                      tooltip: 'Xóa địa điểm',
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),

            // Địa chỉ
            if (location.address.isNotEmpty)
              Text(
                location.address,
                style: TextStyle(color: Colors.grey[600]),
              ),
            const SizedBox(height: 16),

            // Hàng cuối cùng: Loại và Chi phí
            Row(
              children: [
                // Hiển thị loại địa điểm
                Icon(_getCategoryIcon(location.category), color: Colors.teal, size: 20),
                const SizedBox(width: 4),
                Text(
                  // Chuyển 'ItemCategory.sightseeing' thành 'Sightseeing'
                  toBeginningOfSentenceCase(location.category.name) ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                ),

                const Spacer(), // Đẩy phần chi phí sang phải

                // Hiển thị chi phí
                if (location.estimatedCost > 0)
                  Text(
                    // Định dạng số thành tiền tệ Việt Nam
                    NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(location.estimatedCost),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}