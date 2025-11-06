import 'package:cloud_firestore/cloud_firestore.dart';

class CourseSections {
  final String id;
  final String subjectId;
  final String teacherId;
  final String classroomId;
  final String roomId;
  final String semesterId;
  final int totalSessions;
  final String scheduleString; // Tên biến này vẫn giữ nguyên
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseSections({
    required this.id,
    required this.subjectId,
    required this.teacherId,
    required this.classroomId,
    required this.roomId,
    required this.semesterId,
    required this.totalSessions,
    required this.scheduleString,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseSections.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return CourseSections(
      id: id,
      subjectId: json['subjectId'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
      classroomId: json['classroomId'] as String? ?? '',
      roomId: json['roomId'] as String? ?? '',
      semesterId: json['semesterId'] as String? ?? '',
      totalSessions: json['totalSessions'] as int? ?? 0,

      // [SỬA LỖI] Đọc từ 'schedule' (trong Firebase) thay vì 'scheduleString'
      scheduleString: json['schedule'] as String? ?? '',

      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'teacherId': teacherId,
      'classroomId': classroomId,
      'roomId': roomId,
      'semesterId': semesterId,
      'totalSessions': totalSessions,

      // [SỬA LỖI] Ghi vào 'schedule' (trong Firebase)
      'schedule': scheduleString,

      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CourseSections copyWith({
    String? id,
    String? subjectId,
    String? teacherId,
    String? classroomId,
    String? roomId,
    String? semesterId,
    int? totalSessions,
    String? scheduleString,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseSections(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      classroomId: classroomId ?? this.classroomId,
      roomId: roomId ?? this.roomId,
      semesterId: semesterId ?? this.semesterId,
      totalSessions: totalSessions ?? this.totalSessions,
      scheduleString: scheduleString ?? this.scheduleString,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}