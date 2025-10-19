import 'package:cloud_firestore/cloud_firestore.dart';

enum ScheduleStatus {
  scheduled,
  completed,
  cancelled,
  makeUp,
}

class Schedule {
  final String id;
  final String subjectId;
  final String classroomId;
  final String teacherId;
  final String roomId;
  final DateTime startTime;
  final DateTime endTime;
  final int sessionNumber; // Số thứ tự buổi học
  final String content; // Nội dung buổi học
  final ScheduleStatus status;
  final String? notes;
  final String? makeUpReason; // Lý do dạy bù
  final String? originalScheduleId; // ID của buổi học gốc (nếu là dạy bù)
  final DateTime createdAt;
  final DateTime updatedAt;

  Schedule({
    required this.id,
    required this.subjectId,
    required this.classroomId,
    required this.teacherId,
    required this.roomId,
    required this.startTime,
    required this.endTime,
    required this.sessionNumber,
    required this.content,
    required this.status,
    this.notes,
    this.makeUpReason,
    this.originalScheduleId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      subjectId: json['subjectId'],
      classroomId: json['classroomId'],
      teacherId: json['teacherId'],
      roomId: json['roomId'],
      startTime: (json['startTime'] as Timestamp).toDate(),
      endTime: (json['endTime'] as Timestamp).toDate(),
      sessionNumber: json['sessionNumber'],
      content: json['content'],
      status: ScheduleStatus.values.firstWhere(
        (e) => e.toString() == 'ScheduleStatus.${json['status']}',
        orElse: () => ScheduleStatus.scheduled,
      ),
      notes: json['notes'],
      makeUpReason: json['makeUpReason'],
      originalScheduleId: json['originalScheduleId'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'classroomId': classroomId,
      'teacherId': teacherId,
      'roomId': roomId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'sessionNumber': sessionNumber,
      'content': content,
      'status': status.toString().split('.').last,
      'notes': notes,
      'makeUpReason': makeUpReason,
      'originalScheduleId': originalScheduleId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Schedule copyWith({
    String? id,
    String? subjectId,
    String? classroomId,
    String? teacherId,
    String? roomId,
    DateTime? startTime,
    DateTime? endTime,
    int? sessionNumber,
    String? content,
    ScheduleStatus? status,
    String? notes,
    String? makeUpReason,
    String? originalScheduleId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Schedule(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      classroomId: classroomId ?? this.classroomId,
      teacherId: teacherId ?? this.teacherId,
      roomId: roomId ?? this.roomId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      content: content ?? this.content,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      makeUpReason: makeUpReason ?? this.makeUpReason,
      originalScheduleId: originalScheduleId ?? this.originalScheduleId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}



