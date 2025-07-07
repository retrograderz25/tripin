// lib/providers/plan_provider.dart

import 'package:flutter/material.dart';
import '../models/location_item.dart';

class PlanProvider with ChangeNotifier {
  // Danh sách private để lưu trữ tất cả địa điểm trong "thư viện"
  final List<LocationItem> _locations = [
    // --- DỮ LIỆU GIẢ (DUMMY DATA) ĐỂ BẮT ĐẦU ---
    LocationItem(
      id: 'loc1',
      name: 'Lăng Chủ tịch Hồ Chí Minh',
      address: 'Số 2 Hùng Vương, Ba Đình, Hà Nội',
      category: ItemCategory.sightseeing,
      referenceUrl: 'https://goo.gl/maps/dJ5q4Q8g8Jp3s8F8A',
    ),
    LocationItem(
        id: 'loc2',
        name: 'Phở Thìn 13 Lò Đúc',
        address: '13 P. Lò Đúc, Phạm Đình Hổ, Hai Bà Trưng, Hà Nội',
        category: ItemCategory.food,
        estimatedCost: 50000,
        costNotes: 'Giá cho 1 bát phở',
        referenceUrl: 'https://goo.gl/maps/bKjR6nN2qYF8s7t99'
    ),
    LocationItem(
      id: 'loc3',
      name: 'Hồ Gươm (Hồ Hoàn Kiếm)',
      address: 'Hàng Trống, Hoàn Kiếm, Hà Nội',
      category: ItemCategory.sightseeing,
    ),
  ];

  // Getter public để UI có thể truy cập danh sách này một cách an toàn
  List<LocationItem> get locations => [..._locations];

  void addLocation(LocationItem newLocation) {
    // Thêm địa điểm mới vào đầu danh sách để dễ thấy nhất
    _locations.insert(0, newLocation);

    // Thông báo cho tất cả các "listener" (ở đây là Consumer trong HomeScreen)
    // rằng dữ liệu đã thay đổi, và chúng cần phải xây dựng lại giao diện.
    notifyListeners();
  }

  // Hàm để xóa một LocationItem dựa trên ID của nó
  void deleteLocation(String locationId) {
    // Tìm và xóa item có ID tương ứng khỏi danh sách
    _locations.removeWhere((item) => item.id == locationId);

    // Thông báo cho UI để cập nhật lại
    notifyListeners();
  }

  // Hàm để cập nhật một LocationItem đã có
  void updateLocation(LocationItem updatedLocation) {
    // Tìm vị trí (index) của item cần cập nhật trong danh sách
    final locationIndex = _locations.indexWhere((loc) => loc.id == updatedLocation.id);

    // Nếu tìm thấy (index >= 0)
    if (locationIndex >= 0) {
      // Thay thế item cũ bằng item đã được cập nhật
      _locations[locationIndex] = updatedLocation;

      // Thông báo cho UI để cập nhật lại
      notifyListeners();
    }
  }
}