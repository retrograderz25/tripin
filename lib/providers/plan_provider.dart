// lib/providers/plan_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/location_item.dart';
import '../models/daily_plan.dart';
import '../models/schedule_entry.dart';

class PlanProvider with ChangeNotifier {
  // =======================================================
  // BIẾN THÀNH VIÊN (INSTANCE VARIABLES)
  // =======================================================
  final CollectionReference _locationsCollection = FirebaseFirestore.instance.collection('locations');
  final CollectionReference _plansCollection = FirebaseFirestore.instance.collection('plans');
  String? _selectedDayId;

  // =======================================================
  // GETTERS
  // =======================================================
  String? get selectedDayId => _selectedDayId;

  // =======================================================
  // PHẦN QUẢN LÝ LỊCH TRÌNH (SCHEDULE)
  // =======================================================

  Stream<List<DailyPlan>> getDailyPlansStream() {
    return _plansCollection
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => DailyPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addDailyPlan(DateTime date, String title) async {
    final newPlan = DailyPlan(id: _plansCollection.doc().id, date: date, title: title, entries: []);
    await _plansCollection.doc(newPlan.id).set(newPlan.toMap());
  }

  Future<void> updateDailyPlan(String dayId, String newTitle, DateTime newDate) async {
    await _plansCollection.doc(dayId).update({
      'title': newTitle,
      'date': Timestamp.fromDate(newDate),
    });
  }

  Future<void> deleteDailyPlan(String dayId) async {
    if (_selectedDayId == dayId) {
      _selectedDayId = null;
      notifyListeners();
    }
    await _plansCollection.doc(dayId).delete();
  }

  void selectDay(String? dayId) {
    _selectedDayId = dayId;
    notifyListeners();
  }

  Future<void> addLocationToSchedule(LocationItem location) async {
    if (_selectedDayId == null) return;
    final newEntry = ScheduleEntry(
      entryId: DateTime.now().millisecondsSinceEpoch.toString(),
      locationId: location.id,
      locationName: location.name,
    );
    await _plansCollection.doc(_selectedDayId).update({
      'entries': FieldValue.arrayUnion([newEntry.toMap()])
    });
  }

  Future<void> removeLocationFromSchedule(String dayId, ScheduleEntry entryToRemove) async {
    await _plansCollection.doc(dayId).update({
      'entries': FieldValue.arrayRemove([entryToRemove.toMap()])
    });
  }

  // =======================================================
  // PHẦN QUẢN LÝ THƯ VIỆN ĐỊA ĐIỂM (LOCATIONS)
  // =======================================================

  Stream<List<LocationItem>> getLocationsStream() {
    return _locationsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LocationItem.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      )).toList();
    });
  }

  Future<void> addLocation(LocationItem newLocation) async {
    await _locationsCollection.doc(newLocation.id).set(newLocation.toMap());
  }

  Future<void> updateLocation(LocationItem updatedLocation) async {
    await _locationsCollection
        .doc(updatedLocation.id)
        .update(updatedLocation.toMap());
  }

  Future<void> deleteLocation(String locationId) async {
    await _locationsCollection.doc(locationId).delete();
  }

} // <--- ĐÂY LÀ DẤU NGOẶC KẾT THÚC CLASS, TẤT CẢ CÁC HÀM PHẢI NẰM TRÊN DÒNG NÀY