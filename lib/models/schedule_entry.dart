// lib/models/schedule_entry.dart
import 'package:flutter/material.dart';

class ScheduleEntry {
  final String entryId;
  final String locationId; // ID để liên kết tới LocationItem
  final String locationName; // Lưu lại tên để hiển thị nhanh

  Duration travelTime;
  TimeOfDay? startTime;
  Duration activityDuration;
  String scheduleNotes;

  ScheduleEntry({
    required this.entryId,
    required this.locationId,
    required this.locationName,
    this.travelTime = Duration.zero,
    this.startTime,
    this.activityDuration = const Duration(hours: 1),
    this.scheduleNotes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'locationId': locationId,
      'locationName': locationName,
      'travelTimeMinutes': travelTime.inMinutes,
      // startTime có thể null, cần xử lý
      'startTimeHour': startTime?.hour,
      'startTimeMinute': startTime?.minute,
      'activityDurationMinutes': activityDuration.inMinutes,
      'scheduleNotes': scheduleNotes,
    };
  }

  factory ScheduleEntry.fromMap(Map<String, dynamic> map) {
    return ScheduleEntry(
      entryId: map['entryId'] ?? '',
      locationId: map['locationId'] ?? '',
      locationName: map['locationName'] ?? '',
      travelTime: Duration(minutes: map['travelTimeMinutes'] ?? 0),
      // Xử lý việc tạo lại TimeOfDay từ dữ liệu có thể null
      startTime: (map['startTimeHour'] != null && map['startTimeMinute'] != null)
          ? TimeOfDay(hour: map['startTimeHour'], minute: map['startTimeMinute'])
          : null,
      activityDuration: Duration(minutes: map['activityDurationMinutes'] ?? 60),
      scheduleNotes: map['scheduleNotes'] ?? '',
    );
  }
}