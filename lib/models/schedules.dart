import 'package:cloud_firestore/cloud_firestore.dart';

enum ScheduleStatus {
  scheduled,
  completed,
  cancelled,
}

class Schedules {
  final String id;
  final String courseSectionId;
  final int sessionNumber;
  final DateTime startTime;
  final DateTime endTime;
  final ScheduleStatus status;
  final String? content;
  final String? originalScheduleId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedules({
    required this.id,
    required this.courseSectionId,
    required this.sessionNumber,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.content,
    this.originalScheduleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedules.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Schedules(
      id: id,
      courseSectionId: json['courseSectionId'] as String? ?? '',
      sessionNumber: json['sessionNumber'] as int? ?? 0,
      startTime: parseTimestamp(json['startTime']),
      endTime: parseTimestamp(json['endTime']),
      status: ScheduleStatus.values.firstWhere(
        (e) => e.toString() == 'ScheduleStatus.${json['status']}',
        orElse: () => ScheduleStatus.scheduled,
      ),
      content: json['content'] as String?,
      originalScheduleId: json['originalScheduleId'] as String?,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseSectionId': courseSectionId,
      'sessionNumber': sessionNumber,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': status.toString().split('.').last,
      'content': content,
      'originalScheduleId': originalScheduleId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Schedules copyWith({
    String? id,
    String? courseSectionId,
    int? sessionNumber,
    DateTime? startTime,
    DateTime? endTime,
    ScheduleStatus? status,
    String? content,
    String? originalScheduleId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedules(
      id: id ?? this.id,
      courseSectionId: courseSectionId ?? this.courseSectionId,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      content: content ?? this.content,
      originalScheduleId: originalScheduleId ?? this.originalScheduleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


