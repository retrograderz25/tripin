// lib/models/daily_plan.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'schedule_entry.dart';

class DailyPlan {
  final String id;
  DateTime date;
  String title;
  List<ScheduleEntry> entries;

  DailyPlan({
    required this.id,
    required this.date,
    this.title = '',
    required this.entries,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date), // Chuyển DateTime thành Timestamp của Firestore
      'title': title,
      // Chuyển đổi mỗi entry trong list thành map
      'entries': entries.map((entry) => entry.toMap()).toList(),
    };
  }

  factory DailyPlan.fromMap(Map<String, dynamic> map, String documentId) {
    return DailyPlan(
      id: documentId,
      // Chuyển Timestamp từ Firestore về DateTime
      date: (map['date'] as Timestamp).toDate(),
      title: map['title'] ?? '',
      // Chuyển đổi list các map về lại list các ScheduleEntry
      entries: (map['entries'] as List<dynamic>)
          .map((entryMap) => ScheduleEntry.fromMap(entryMap as Map<String, dynamic>))
          .toList(),
    );
  }
}