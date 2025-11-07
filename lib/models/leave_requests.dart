import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveRequestStatus {
  pending,
  approved,
  rejected,
}

class LeaveRequests {
  final String id;
  final String teacherId;
  final String scheduleId;
  final String? lessonId;
  final String reason;
  final LeaveRequestStatus status;
  final String? approverId;
  final DateTime? approvedDate;
  final String? approverNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequests({
    required this.id,
    required this.teacherId,
    required this.scheduleId,
    this.lessonId,
    required this.reason,
    required this.status,
    this.approverId,
    this.approvedDate,
    this.approverNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveRequests.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return LeaveRequests(
      id: id,
      teacherId: json['teacherId'] as String? ?? '',
      scheduleId: json['scheduleId'] as String? ?? '',
      lessonId: json['lessonId'] as String?,
      reason: json['reason'] as String? ?? '',
      status: LeaveRequestStatus.values.firstWhere(
        (e) => e.toString() == 'LeaveRequestStatus.${json['status']}',
        orElse: () => LeaveRequestStatus.pending,
      ),
      approverId: json['approverId'] as String?,
      approvedDate: json['approvedDate'] != null ? parseTimestamp(json['approvedDate']) : null,
      approverNotes: json['approverNotes'] as String?,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'scheduleId': scheduleId,
      'lessonId': lessonId,
      'reason': reason,
      'status': status.toString().split('.').last,
      'approverId': approverId,
      'approvedDate': approvedDate != null ? Timestamp.fromDate(approvedDate!) : null,
      'approverNotes': approverNotes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  LeaveRequests copyWith({
    String? id,
    String? teacherId,
    String? scheduleId,
    String? reason,
    LeaveRequestStatus? status,
    String? approverId,
    DateTime? approvedDate,
    String? approverNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequests(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      scheduleId: scheduleId ?? this.scheduleId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approverId: approverId ?? this.approverId,
      approvedDate: approvedDate ?? this.approvedDate,
      approverNotes: approverNotes ?? this.approverNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
