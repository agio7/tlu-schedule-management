import 'package:cloud_firestore/cloud_firestore.dart';

enum AttendanceStatus {
  present,
  absent,
  late,
  excused,
}

class Attendance {
  final String id;
  final String scheduleId;
  final String studentId;
  final String studentName;
  final AttendanceStatus status;
  final DateTime? checkInTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Attendance({
    required this.id,
    required this.scheduleId,
    required this.studentId,
    required this.studentName,
    required this.status,
    this.checkInTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      scheduleId: json['scheduleId'],
      studentId: json['studentId'],
      studentName: json['studentName'],
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == 'AttendanceStatus.${json['status']}',
        orElse: () => AttendanceStatus.present,
      ),
      checkInTime: json['checkInTime'] != null 
          ? (json['checkInTime'] as Timestamp).toDate() 
          : null,
      notes: json['notes'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleId': scheduleId,
      'studentId': studentId,
      'studentName': studentName,
      'status': status.toString().split('.').last,
      'checkInTime': checkInTime != null ? Timestamp.fromDate(checkInTime!) : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}



