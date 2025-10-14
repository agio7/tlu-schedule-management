import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveRequestStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

class LeaveRequest {
  final String id;
  final String teacherId;
  final String scheduleId;
  final String reason;
  final List<String> attachments; // URLs của file đính kèm
  final LeaveRequestStatus status;
  final String? approverId;
  final String? approverNotes;
  final DateTime requestDate;
  final DateTime? approvedDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequest({
    required this.id,
    required this.teacherId,
    required this.scheduleId,
    required this.reason,
    required this.attachments,
    required this.status,
    this.approverId,
    this.approverNotes,
    required this.requestDate,
    this.approvedDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      teacherId: json['teacherId'],
      scheduleId: json['scheduleId'],
      reason: json['reason'],
      attachments: List<String>.from(json['attachments'] ?? []),
      status: LeaveRequestStatus.values.firstWhere(
        (e) => e.toString() == 'LeaveRequestStatus.${json['status']}',
        orElse: () => LeaveRequestStatus.pending,
      ),
      approverId: json['approverId'],
      approverNotes: json['approverNotes'],
      requestDate: (json['requestDate'] as Timestamp).toDate(),
      approvedDate: json['approvedDate'] != null 
          ? (json['approvedDate'] as Timestamp).toDate() 
          : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'scheduleId': scheduleId,
      'reason': reason,
      'attachments': attachments,
      'status': status.toString().split('.').last,
      'approverId': approverId,
      'approverNotes': approverNotes,
      'requestDate': Timestamp.fromDate(requestDate),
      'approvedDate': approvedDate != null ? Timestamp.fromDate(approvedDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}



