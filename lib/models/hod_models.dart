import 'package:flutter/material.dart';

// Enums
enum SessionStatus {
  chuaDay,
  daDay,
  nghi,
  dayBu,
}

enum RequestStatus {
  pending,
  approved,
  rejected,
}

enum AlertType {
  conflict,
  noMakeup,
  delay,
}

enum AlertState {
  unresolved,
  inProgress,
  resolved,
}

// Lecturer Model
class Lecturer {
  final String name;
  final String email;
  final String phone;
  final String title;
  final String subject;
  final int hoursPlanned;
  final int hoursActual;

  Lecturer({
    required this.name,
    required this.email,
    required this.phone,
    required this.title,
    required this.subject,
    required this.hoursPlanned,
    required this.hoursActual,
  });

  Lecturer copyWith({
    String? name,
    String? email,
    String? phone,
    String? title,
    String? subject,
    int? hoursPlanned,
    int? hoursActual,
  }) {
    return Lecturer(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      hoursPlanned: hoursPlanned ?? this.hoursPlanned,
      hoursActual: hoursActual ?? this.hoursActual,
    );
  }
}

// [SỬA LỖI] Đã thêm 'id'
class LeaveRequest {
  final String id; // <-- ĐÃ THÊM
  final String lecturer;
  final String subject;
  final String className;
  final String room;
  final DateTime date;
  final String session;
  final String reason;
  final RequestStatus status;
  final DateTime submittedAt;
  final String? approvedBy;
  final String? rejectedBy;
  final String? rejectionReason;
  final DateTime? approvedDate;

  LeaveRequest({
    required this.id, // <-- ĐÃ THÊM
    required this.lecturer,
    required this.subject,
    required this.className,
    required this.room,
    required this.date,
    required this.session,
    required this.reason,
    required this.status,
    required this.submittedAt,
    this.approvedBy,
    this.rejectedBy,
    this.rejectionReason,
    this.approvedDate,
  });
}

// [SỬA LỖI] Đã thêm 'id'
class MakeupRegistration {
  final String id; // <-- ĐÃ THÊM
  final String lecturer;
  final String subject;
  final String className;
  final DateTime originalDate;
  final String originalSession;
  final DateTime makeupDate;
  final String makeupSession;
  final String makeupRoom;
  final RequestStatus status;
  final String? approvedBy;
  final String? rejectedBy;
  final String? rejectionReason;
  final DateTime? approvedDate;
  final DateTime submittedAt;

  MakeupRegistration({
    required this.id, // <-- ĐÃ THÊM
    required this.lecturer,
    required this.originalDate,
    required this.originalSession,
    required this.makeupDate,
    required this.makeupSession,
    required this.makeupRoom,
    this.status = RequestStatus.pending,
    this.subject = '',
    this.className = '',
    this.approvedBy,
    this.rejectedBy,
    this.rejectionReason,
    this.approvedDate,
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();
}

// [SỬA LỖI] Đã thêm 'totalSessions'
class ScheduleItem {
  final String lecturer;
  final String subject;
  final String className;
  final String? classroomId;
  final DateTime date;
  final String session;
  final String room;
  final SessionStatus status;
  final List<String>? attendanceList;
  final int studentCount;
  final int totalSessions; // <-- ĐÃ THÊM

  ScheduleItem({
    required this.lecturer,
    required this.subject,
    required this.className,
    this.classroomId,
    required this.date,
    required this.session,
    required this.room,
    required this.status,
    this.attendanceList,
    required this.studentCount,
    required this.totalSessions, // <-- ĐÃ THÊM
  });
}

// Alert Item Model
class AlertItem {
  final AlertType type;
  final String detail;
  final DateTime date;
  final String priority;
  final AlertState state;

  AlertItem({
    required this.type,
    required this.detail,
    required this.date,
    required this.priority,
    required this.state,
  });
}

// Helper function to format date
String dmy(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}