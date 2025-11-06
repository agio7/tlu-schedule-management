import 'package:cloud_firestore/cloud_firestore.dart';

enum MakeupRequestStatus {
  pending,
  approved,
  rejected,
}

class MakeupRequests {
  final String id;
  final String teacherId;
  final String? approverId;

  // --- Bổ sung các trường cần thiết ---
  final String? departmentId;
  final String? lessonId; // để khớp với Firestore (bạn có field "lessonId")
  final String? originalScheduleId; // vẫn giữ để dùng nếu có
  final String reason;
  final String? proposedRoomId;
  final DateTime proposedStartTime;
  final DateTime proposedEndTime;
  final MakeupRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? leaveRequestId;
  final DateTime? makeupDate; // thêm nếu Firestore có field makeupDate
  final String? approverNotes;

  MakeupRequests({
    required this.id,
    required this.teacherId,
    this.approverId,
    this.departmentId,
    this.lessonId,
    this.originalScheduleId,
    required this.reason,
    this.proposedRoomId,
    required this.proposedStartTime,
    required this.proposedEndTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.leaveRequestId,
    this.makeupDate,
    this.approverNotes,
  });

  /// --- Factory khởi tạo từ Firestore ---
  factory MakeupRequests.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) return DateTime.now();
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is String) return DateTime.tryParse(timestamp) ?? DateTime.now();
      return DateTime.now();
    }

    return MakeupRequests(
      id: id,
      teacherId: json['teacherId'] as String? ?? '',
      approverId: json['approverId'] as String?,
      departmentId: json['departmentId'] as String?,
      lessonId: json['lessonId'] as String?, // thêm dòng này
      originalScheduleId: json['originalScheduleId'] as String?,
      reason: json['reason'] as String? ?? '',
      proposedRoomId: json['proposedRoomId'] as String?,
      proposedStartTime: parseTimestamp(
          json['proposedStartTime'] ?? json['requestedTime']),
      proposedEndTime:
      parseTimestamp(json['proposedEndTime'] ?? json['requestedTime']),
      status: _parseStatus(json['status']),
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
      leaveRequestId: json['leaveRequestId'] as String?,
      makeupDate: parseTimestamp(json['makeupDate']),
      approverNotes: json['approverNotes'] as String?,
    );
  }

  /// --- Chuyển từ enum sang string khi lưu ---
  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'approverId': approverId,
      'departmentId': departmentId,
      'lessonId': lessonId,
      'originalScheduleId': originalScheduleId,
      'reason': reason,
      'proposedRoomId': proposedRoomId,
      'proposedStartTime': Timestamp.fromDate(proposedStartTime),
      'proposedEndTime': Timestamp.fromDate(proposedEndTime),
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'leaveRequestId': leaveRequestId,
      'makeupDate': makeupDate != null ? Timestamp.fromDate(makeupDate!) : null,
      'approverNotes': approverNotes,
    };
  }

  /// --- Helper: chuyển string sang enum ---
  static MakeupRequestStatus _parseStatus(dynamic value) {
    if (value == null) return MakeupRequestStatus.pending;
    final str = value.toString().toLowerCase();
    if (str.contains('approved')) return MakeupRequestStatus.approved;
    if (str.contains('rejected')) return MakeupRequestStatus.rejected;
    return MakeupRequestStatus.pending;
  }
}
