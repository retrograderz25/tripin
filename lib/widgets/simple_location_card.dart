// lib/widgets/simple_location_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/location_item.dart';
import '../providers/plan_provider.dart';

class SimpleLocationCard extends StatelessWidget {
  final LocationItem location;

  const SimpleLocationCard({super.key, required this.location});

  void _launchURL(BuildContext context) async {
    if (location.referenceUrl.isEmpty) return;

    final Uri url = Uri.parse(location.referenceUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở link: ${location.referenceUrl}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 12.0, right: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- CỘT THÔNG TIN (TÊN, ĐỊA CHỈ, CHI PHÍ) ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (location.address.isNotEmpty)
                    Text(
                      location.address,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  if (location.estimatedCost > 0)
                    Text(
                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                          .format(location.estimatedCost),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),

            // --- KHU VỰC CÁC NÚT HÀNH ĐỘNG ---
            // Nút Link Tham Khảo (chỉ hiển thị khi có url)
            if (location.referenceUrl.isNotEmpty)
              IconButton(
                icon: Icon(Icons.link_rounded, color: Colors.blue.shade700),
                onPressed: () => _launchURL(context),
                tooltip: 'Mở link tham khảo',
              ),

            // Nút Thêm vào lịch trình
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                context.read<PlanProvider>().addLocationToSchedule(location);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã thêm "${location.name}" vào lịch trình.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Thêm vào ngày đang chọn',
            ),
          ],
        ),
      ),
    );
  }
}