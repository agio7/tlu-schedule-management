import 'package:cloud_firestore/cloud_firestore.dart';

class Lessons {
  final String id;
  final String className;
  final String? classroomId;
  final String? room;
  final String? roomId;
  final String? subject; // subject name text
  final String? subjectId;
  final String? sessionTitle;
  final int? sessionNumber;
  final String status; // completed | upcoming | ongoing
  final DateTime date; // day of lesson
  final String startTime; // e.g. "07:30"
  final String endTime;   // e.g. "09:30"
  final DateTime createdAt;
  final String? teacherId; // ID của giảng viên
  final List<String>? attendanceList; // [THÊM MỚI]

  Lessons({
    required this.id,
    required this.className,
    this.classroomId,
    this.room,
    this.roomId,
    this.subject,
    this.subjectId,
    this.sessionTitle,
    this.sessionNumber,
    required this.status,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.teacherId,
    this.attendanceList, // [THÊM MỚI]
  });

  factory Lessons.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTs(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
      return DateTime.now();
    }

    return Lessons(
      id: id,
      className: json['className'] as String? ?? '',
      classroomId: json['classroomId'] as String?,
      room: json['room'] as String?,
      roomId: json['roomId'] as String?,
      subject: json['subject'] as String?,
      subjectId: json['subjectId'] as String?,
      sessionTitle: json['sessionTitle'] as String?,
      sessionNumber: (json['sessionNumber'] is int)
          ? json['sessionNumber'] as int
          : int.tryParse('${json['sessionNumber']}'),
      status: json['status'] as String? ?? 'upcoming',
      date: parseTs(json['date']),
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      createdAt: parseTs(json['createdAt']),
      teacherId: json['teacherId'] as String?,
      // [THÊM MỚI] Đọc danh sách điểm danh
      attendanceList: json['attendanceList'] != null
          ? List<String>.from(json['attendanceList'] as List)
          : null,
    );
  }
}