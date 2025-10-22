import 'package:cloud_firestore/cloud_firestore.dart';

enum MakeupRequestStatus {
  pending,
  approved,
  rejected,
}

class MakeupRequests {
  final String id;
  final String leaveRequestId;
  final String teacherId;
  final DateTime proposedStartTime;
  final DateTime proposedEndTime;
  final String proposedRoomId;
  final MakeupRequestStatus status;
  final String? approverId;
  final DateTime createdAt;
  final DateTime updatedAt;

  MakeupRequests({
    required this.id,
    required this.leaveRequestId,
    required this.teacherId,
    required this.proposedStartTime,
    required this.proposedEndTime,
    required this.proposedRoomId,
    required this.status,
    this.approverId,
    required this.createdAt,
    required this.updatedAt,
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
      leaveRequestId: json['leaveRequestId'] as String? ?? '',
      teacherId: json['teacherId'] as String? ?? '',
      proposedStartTime: parseTimestamp(json['proposedStartTime']),
      proposedEndTime: parseTimestamp(json['proposedEndTime']),
      proposedRoomId: json['proposedRoomId'] as String? ?? '',
      status: MakeupRequestStatus.values.firstWhere(
        (e) => e.toString() == 'MakeupRequestStatus.${json['status']}',
        orElse: () => MakeupRequestStatus.pending,
      ),
      approverId: json['approverId'] as String?,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaveRequestId': leaveRequestId,
      'teacherId': teacherId,
      'proposedStartTime': Timestamp.fromDate(proposedStartTime),
      'proposedEndTime': Timestamp.fromDate(proposedEndTime),
      'proposedRoomId': proposedRoomId,
      'status': status.toString().split('.').last,
      'approverId': approverId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MakeupRequests copyWith({
    String? id,
    String? leaveRequestId,
    String? teacherId,
    DateTime? proposedStartTime,
    DateTime? proposedEndTime,
    String? proposedRoomId,
    MakeupRequestStatus? status,
    String? approverId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MakeupRequests(
      id: id ?? this.id,
      leaveRequestId: leaveRequestId ?? this.leaveRequestId,
      teacherId: teacherId ?? this.teacherId,
      proposedStartTime: proposedStartTime ?? this.proposedStartTime,
      proposedEndTime: proposedEndTime ?? this.proposedEndTime,
      proposedRoomId: proposedRoomId ?? this.proposedRoomId,
      status: status ?? this.status,
      approverId: approverId ?? this.approverId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


