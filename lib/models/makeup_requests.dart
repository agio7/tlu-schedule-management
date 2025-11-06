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
  final String? originalScheduleId; // <-- TRƯỜNG BỊ THIẾU
  final String reason;
  final String proposedRoomId; // Giả sử bạn có trường này
  final DateTime proposedStartTime; // Giả sử bạn có trường này
  final DateTime proposedEndTime; // Giả sử bạn có trường này
  final MakeupRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // [SỬA LỖI] Thêm leaveRequestId (dùng trong provider)
  final String leaveRequestId;

  MakeupRequests({
    required this.id,
    required this.teacherId,
    this.approverId,
    this.originalScheduleId,
    required this.reason,
    required this.proposedRoomId,
    required this.proposedStartTime,
    required this.proposedEndTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.leaveRequestId, // Thêm vào constructor
  });

  factory MakeupRequests.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return MakeupRequests(
      id: id,
      teacherId: json['teacherId'] as String? ?? '',
      approverId: json['approverId'] as String?,
      originalScheduleId: json['originalScheduleId'] as String?, // <-- ĐÃ THÊM
      reason: json['reason'] as String? ?? '',

      // [SỬA LỖI] Giả sử tên trường trong Firebase
      proposedRoomId: json['proposedRoomId'] as String? ?? '',
      proposedStartTime: parseTimestamp(json['requestedTime'] ?? json['proposedStartTime']), // Dùng requestedTime
      proposedEndTime: parseTimestamp(json['requestedTime'] ?? json['proposedEndTime']), // Cần endTime

      status: MakeupRequestStatus.values.firstWhere(
            (e) => e.toString() == 'MakeupRequestStatus.${json['status']}',
        orElse: () => MakeupRequestStatus.pending,
      ),
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),

      // [SỬA LỖI] Đọc 'leaveRequestId' (nếu có)
      leaveRequestId: json['leaveRequestId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'approverId': approverId,
      'originalScheduleId': originalScheduleId,
      'reason': reason,
      'proposedRoomId': proposedRoomId,
      'proposedStartTime': Timestamp.fromDate(proposedStartTime),
      'proposedEndTime': Timestamp.fromDate(proposedEndTime),
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'leaveRequestId': leaveRequestId,
    };
  }
}