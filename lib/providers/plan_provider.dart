// lib/providers/plan_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/location_item.dart';
import '../models/daily_plan.dart';
import '../models/schedule_entry.dart';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlanProvider with ChangeNotifier {
  // =======================================================
  // KHAI BÁO CÁC DỊCH VỤ FIREBASE
  // =======================================================
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =======================================================
  // BIẾN TRẠNG THÁI (STATE VARIABLES)
  // =======================================================
  // Các biến này sẽ được khởi tạo khi người dùng đăng nhập
  CollectionReference? _locationsCollection;
  CollectionReference? _plansCollection;
  String? _selectedDayId;

  // GETTER
  String? get selectedDayId => _selectedDayId;

  // =======================================================
  // KHỞI TẠO VÀ LẮNG NGHE AUTHENTICATION
  // =======================================================

  // Constructor: Được gọi khi PlanProvider được tạo ra
  PlanProvider() {
    // Lắng nghe sự thay đổi trạng thái đăng nhập
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Hàm được gọi mỗi khi người dùng đăng nhập hoặc đăng xuất
  void _onAuthStateChanged(User? user) {
    if (user != null) {
      // Người dùng đã đăng nhập: trỏ collection vào đúng document của họ
      print('PlanProvider: User is signed in! UID: ${user.uid}');
      final userDoc = _firestore.collection('users').doc(user.uid);
      _locationsCollection = userDoc.collection('locations');
      _plansCollection = userDoc.collection('plans');
    } else {
      // Người dùng đã đăng xuất: xóa tham chiếu để tránh rò rỉ dữ liệu
      print('PlanProvider: User is signed out!');
      _locationsCollection = null;
      _plansCollection = null;
      _selectedDayId = null; // Reset ngày đang chọn
    }
    // Thông báo cho các listener (như Wrapper, HomeScreen) để build lại
    // và cập nhật lại các Stream
    notifyListeners();
  }

  // =======================================================
  // PHẦN QUẢN LÝ THƯ VIỆN ĐỊA ĐIỂM (LOCATIONS)
  // =======================================================

  Stream<List<LocationItem>> getLocationsStream() {
    // Nếu chưa đăng nhập hoặc collection chưa được khởi tạo, trả về một stream rỗng
    if (_locationsCollection == null) return Stream.value([]);

    return _locationsCollection!.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LocationItem.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      )).toList();
    });
  }

  Future<void> addLocation(LocationItem newLocation) async {
    if (_locationsCollection == null) return;
    await _locationsCollection!.doc(newLocation.id).set(newLocation.toMap());
  }

  Future<void> updateLocation(LocationItem updatedLocation) async {
    if (_locationsCollection == null) return;
    await _locationsCollection!.doc(updatedLocation.id).update(updatedLocation.toMap());
  }

  Future<void> deleteLocation(String locationId) async {
    if (_locationsCollection == null) return;
    await _locationsCollection!.doc(locationId).delete();
  }

  // =======================================================
  // PHẦN QUẢN LÝ LỊCH TRÌNH (SCHEDULE)
  // =======================================================

  Stream<List<DailyPlan>> getDailyPlansStream() {
    if (_plansCollection == null) return Stream.value([]);

    return _plansCollection!
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => DailyPlan.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> addDailyPlan(DateTime date, String title) async {
    if (_plansCollection == null) return;
    final newPlan = DailyPlan(id: _plansCollection!.doc().id, date: date, title: title, entries: []);
    await _plansCollection!.doc(newPlan.id).set(newPlan.toMap());
  }

  Future<void> updateDailyPlan(String dayId, String newTitle, DateTime newDate) async {
    if (_plansCollection == null) return;
    await _plansCollection!.doc(dayId).update({
      'title': newTitle,
      'date': Timestamp.fromDate(newDate),
    });
  }

  Future<void> deleteDailyPlan(String dayId) async {
    if (_plansCollection == null) return;
    if (_selectedDayId == dayId) {
      _selectedDayId = null;
      notifyListeners();
    }
    await _plansCollection!.doc(dayId).delete();
  }

  void selectDay(String? dayId) {
    _selectedDayId = dayId;
    notifyListeners();
  }

  Future<void> addLocationToSchedule(LocationItem location) async {
    if (_plansCollection == null || _selectedDayId == null) return;
    final newEntry = ScheduleEntry(
      entryId: DateTime.now().millisecondsSinceEpoch.toString(),
      locationId: location.id,
      locationName: location.name,
    );
    await _plansCollection!.doc(_selectedDayId).update({
      'entries': FieldValue.arrayUnion([newEntry.toMap()])
    });
  }

  Future<void> removeLocationFromSchedule(String dayId, ScheduleEntry entryToRemove) async {
    if (_plansCollection == null) return;
    await _plansCollection!.doc(dayId).update({
      'entries': FieldValue.arrayRemove([entryToRemove.toMap()])
    });
  }

  // =======================================================
// EXPORT TO EXCEL
// =======================================================
  Future<void> exportDailyPlanToExcel(DailyPlan dayPlan, List<LocationItem> allLocations) async {
    if (!kIsWeb) {
      print("Export to Excel is currently only supported on Web.");
      return;
    }

    // 1. Tạo đối tượng Excel
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Lịch trình'];

    // 2. Thiết kế tiêu đề chính
    CellStyle titleStyle = CellStyle(bold: true, fontSize: 18, verticalAlign: VerticalAlign.Center);
    sheetObject.appendRow([TextCellValue(dayPlan.title)]);
    // Định dạng hàng tiêu đề chính
    sheetObject.rows.last.forEach((cell) => cell?.cellStyle = titleStyle);

    sheetObject.appendRow([TextCellValue(DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(dayPlan.date))]);
    sheetObject.appendRow([]); // Dòng trống

    // 3. Tạo tiêu đề cho bảng
    CellStyle headerStyle = CellStyle(
      bold: true,
      // Sửa lại mã màu hex
      backgroundColorHex: ExcelColor.grey,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );
    List<String> header = [
      'STT', 'Tên hoạt động', 'Địa chỉ', 'Thời gian (phút)',
      'Ghi chú', 'Chi phí (VNĐ)', 'Link tham khảo'
    ];
    sheetObject.appendRow(header.map((e) => TextCellValue(e)).toList());
    // Định dạng hàng header
    sheetObject.rows.last.forEach((cell) => cell?.cellStyle = headerStyle);

    // 4. Thêm dữ liệu cho mỗi hoạt động
    double totalCost = 0;
    for (int i = 0; i < dayPlan.entries.length; i++) {
      final entry = dayPlan.entries[i];
      final location = allLocations.firstWhere((loc) => loc.id == entry.locationId, orElse: () => LocationItem(id: '', name: ''));
      totalCost += location.estimatedCost;

      List<CellValue> row = [
        IntCellValue(i + 1),
        TextCellValue(location.name),
        TextCellValue(location.address),
        IntCellValue(entry.activityDuration.inMinutes),
        TextCellValue(entry.scheduleNotes.isNotEmpty ? entry.scheduleNotes : location.notes),
        DoubleCellValue(location.estimatedCost),
        TextCellValue(location.referenceUrl),
      ];
      sheetObject.appendRow(row);
    }

    // 5. Thêm dòng tổng kết
    CellStyle totalStyle = CellStyle(bold: true);
    sheetObject.appendRow([]); // Dòng trống
    List<CellValue> totalRow = [
      TextCellValue(''), TextCellValue(''), TextCellValue(''),
      TextCellValue(''), TextCellValue('TỔNG CỘNG'), DoubleCellValue(totalCost)
    ];
    sheetObject.appendRow(totalRow);
    // Định dạng hàng tổng cộng
    sheetObject.rows.last.forEach((cell) => cell?.cellStyle = totalStyle);

    // 6. Tự động điều chỉnh độ rộng các cột
    for (var i = 0; i < header.length; i++) {
      // Sửa lại tên hàm
      sheetObject.setColumnAutoFit(i);
    }

    // 7. Lưu và tải file về
    final safeTitle = dayPlan.title.replaceAll(RegExp(r'[^\w\s]+'),'').replaceAll(' ', '_');
    final fileName = "Lich_trinh_$safeTitle.xlsx";

    final bytes = excel.save();
    if (bytes != null) {
      final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

}