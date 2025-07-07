// lib/widgets/locations_library_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_item.dart';
import '../providers/plan_provider.dart';
import './location_list_item.dart';

class LocationsLibraryTab extends StatelessWidget {
  const LocationsLibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context, listen: false);

    return StreamBuilder<List<LocationItem>>(
      stream: planProvider.getLocationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('Thư viện trống. Hãy thêm một vài địa điểm nhé!'),
          );
        }

        final locations = snapshot.data!;
        // Sắp xếp danh sách theo tên để dễ tìm
        locations.sort((a, b) => a.name.compareTo(b.name));

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: locations.length,
          itemBuilder: (ctx, index) {
            final location = locations[index];
            return LocationListItem(location: location);
          },
        );
      },
    );
  }
}