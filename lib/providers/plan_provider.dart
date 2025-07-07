// lib/providers/plan_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_item.dart';
import '../models/daily_plan.dart';
import '../models/schedule_entry.dart';

class PlanProvider with ChangeNotifier {
  final CollectionReference _locationsCollection = FirebaseFirestore.instance.collection('locations');
  final CollectionReference _plansCollection = FirebaseFirestore.instance.collection('plans');
  // --- PHẦN MỚI: QUẢN LÝ LỊCH TRÌNH ---

  String? _selectedDayId;
  String? get selectedDayId => _selectedDayId;

  // HÀM MỚI: Đọc lịch trình từ Firestore
  Stream<List<DailyPlan>> getDailyPlansStream() {
    return _plansCollection
        .orderBy('date') // Sắp xếp các ngày theo thứ tự thời gian
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => DailyPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  // HÀM MỚI: Thêm một ngày mới
  Future<void> addDailyPlan(DateTime date, String title) async {
    final newPlan = DailyPlan(
      id: _plansCollection.doc().id, // Firestore tự tạo ID
      date: date,
      title: title,
      entries: [],
    );
    // Dùng ID đã tạo để set document
    await _plansCollection.doc(newPlan.id).set(newPlan.toMap());
  }

  // HÀM CẬP NHẬT: Thêm một địa điểm vào lịch trình
  Future<void> addLocationToSchedule(LocationItem location) async {
    if (_selectedDayId == null) return;

    final newEntry = ScheduleEntry(
      entryId: DateTime.now().millisecondsSinceEpoch.toString(),
      locationId: location.id,
      locationName: location.name,
    );

    // Dùng FieldValue.arrayUnion để thêm một phần tử vào mảng 'entries'
    await _plansCollection.doc(_selectedDayId).update({
      'entries': FieldValue.arrayUnion([newEntry.toMap()])
    });
    // Không cần notifyListeners() vì StreamBuilder sẽ tự cập nhật
  }

  void selectDay(String? dayId) {
    _selectedDayId = dayId;
    notifyListeners();
  }
  // VẪN LÀ QUẢN LÍ LỊCH TRÌNH
  // HÀM MỚI: Xóa một hoạt động khỏi một ngày cụ thể
  Future<void> removeLocationFromSchedule(String dayId, ScheduleEntry entryToRemove) async {
    // Dùng FieldValue.arrayRemove để xóa một phần tử khỏi mảng
    await _plansCollection.doc(dayId).update({
      'entries': FieldValue.arrayRemove([entryToRemove.toMap()])
    });
  }

  // HÀM MỚI: Xóa toàn bộ một ngày
  Future<void> deleteDailyPlan(String dayId) async {
    // Nếu ngày bị xóa đang được chọn, hãy bỏ chọn nó
    if (_selectedDayId == dayId) {
      _selectedDayId = null;
      // Cần notifyListeners ở đây vì đây là thay đổi state cục bộ
      notifyListeners();
    }
    await _plansCollection.doc(dayId).delete();
  }

  // TODO: Cần thêm hàm updateDailyPlan để logic Sửa ngày hoạt động


  // PHẦN CŨ

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