// lib/providers/plan_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_item.dart';

class PlanProvider with ChangeNotifier {
  final CollectionReference _locationsCollection =
  FirebaseFirestore.instance.collection('locations');

  Stream<List<LocationItem>> getLocationsStream() {
    return _locationsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return LocationItem.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id, // Tham số thứ hai chính là ID của document
        );
      }).toList();
    });
  }

  // Hàm Thêm mới
  Future<void> addLocation(LocationItem newLocation) async {
    try {
      await _locationsCollection.doc(newLocation.id).set(newLocation.toMap());
    } catch (error) {
      print("Lỗi khi thêm địa điểm: $error");
      // Trong ứng dụng thực tế, bạn nên hiển thị thông báo lỗi cho người dùng
      rethrow; // Ném lại lỗi để có thể bắt ở UI nếu cần
    }
  }
  // Hàm Cập nhật
  Future<void> updateLocation(LocationItem updatedLocation) async {
    try {
      await _locationsCollection
          .doc(updatedLocation.id)
          .update(updatedLocation.toMap());
    } catch (error) {
      print("Lỗi khi cập nhật địa điểm: $error");
      rethrow;
    }
  }
  // Hàm Xóa
  Future<void> deleteLocation(String locationId) async {
    try {
      await _locationsCollection.doc(locationId).delete();
    } catch (error) {
      print("Lỗi khi xóa địa điểm: $error");
      rethrow;
    }
  }

}