import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveRequestStatus {
  pending,
  approved,
  rejected,
}

class LeaveRequests {
  final String id;
  final String teacherId;
  final String? scheduleId; // có thể null nếu dùng lessonId
  final String? lessonId; // fallback if scheduleId is not used
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
    this.scheduleId,
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

    // Xử lý trường hợp dữ liệu có thể ở top-level hoặc trong attachments
    final attachments = json['attachments'] as Map<String, dynamic>?;
    dynamic getField(String key) {
      if (json.containsKey(key) && json[key] != null) return json[key];
      if (attachments != null && attachments.containsKey(key) && attachments[key] != null) {
        return attachments[key];
      }
      return null;
    }

    // Parse status từ top-level hoặc attachments
    final statusStr = getField('status') as String?;
    final statusValue = statusStr ?? 'pending';

    return LeaveRequests(
      id: id,
      teacherId: (getField('teacherId') as String?) ?? '',
      scheduleId: getField('scheduleId') as String?,
      lessonId: getField('lessonId') as String?,
      reason: (getField('reason') as String?) ?? '',
      status: LeaveRequestStatus.values.firstWhere(
        (e) => e.toString() == 'LeaveRequestStatus.$statusValue',
        orElse: () => LeaveRequestStatus.pending,
      ),
      approverId: getField('approverId') as String?,
      approvedDate: getField('approvedDate') != null ? parseTimestamp(getField('approvedDate')) : null,
      approverNotes: getField('approverNotes') as String?,
      createdAt: getField('createdAt') != null ? parseTimestamp(getField('createdAt')) : DateTime.now(),
      updatedAt: getField('updatedAt') != null ? parseTimestamp(getField('updatedAt')) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'scheduleId': scheduleId,
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
