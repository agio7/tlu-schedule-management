import 'package:cloud_firestore/cloud_firestore.dart';

enum LeaveRequestStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

class LeaveRequest {
  final String id;
  final String lessonId; // Thay vì scheduleId
  final String type; // 'leave' or 'makeup'
  final String reason;
  final DateTime? makeupDate;
  final String startTime;
  final String endTime;
  final String? additionalNotes;
  final String status; // 'pending', 'approved', 'rejected'
  final String teacherId;
  final List<String> attachments; // URLs của file đính kèm
  final String? approverId;
  final String? approverNotes;
  final DateTime requestDate;
  final DateTime? approvedDate;
  final String? roomId; // ID của phòng học đã chọn (cho dạy bù)
  final String? roomName; // Tên phòng học (để hiển thị)
  final String? departmentId; // ID của khoa/phòng ban (để phê duyệt)
  final DateTime createdAt;
  final DateTime updatedAt;

  LeaveRequest({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.reason,
    this.makeupDate,
    required this.startTime,
    required this.endTime,
    this.additionalNotes,
    this.status = 'pending',
    required this.teacherId,
    this.attachments = const [],
    this.approverId,
    this.approverNotes,
    required this.requestDate,
    this.approvedDate,
    this.roomId,
    this.roomName,
    this.departmentId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor để tạo LeaveRequest từ Map (Firestore document)
  factory LeaveRequest.fromMap(Map<String, dynamic> map, String id) {
    // Xử lý makeupDate từ Firestore Timestamp
    DateTime? makeupDate;
    if (map['makeupDate'] != null) {
      if (map['makeupDate'] is DateTime) {
        makeupDate = map['makeupDate'] as DateTime;
      } else {
        // Nếu là Timestamp từ Firestore
        makeupDate = (map['makeupDate'] as dynamic).toDate();
      }
    }

    return LeaveRequest(
      id: id,
      lessonId: map['lessonId']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      reason: map['reason']?.toString() ?? '',
      makeupDate: makeupDate,
      startTime: map['startTime']?.toString() ?? '',
      endTime: map['endTime']?.toString() ?? '',
      additionalNotes: map['additionalNotes']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      teacherId: map['teacherId']?.toString() ?? '',
      attachments: List<String>.from((map['attachments'] as List?)?.map((e) => e.toString()) ?? []),
      approverId: map['approverId']?.toString(),
      approverNotes: map['approverNotes']?.toString(),
      requestDate: map['requestDate'] != null 
          ? (map['requestDate'] is DateTime 
              ? map['requestDate'] as DateTime 
              : (map['requestDate'] as dynamic).toDate())
          : DateTime.now(),
      approvedDate: map['approvedDate'] != null 
          ? (map['approvedDate'] is DateTime 
              ? map['approvedDate'] as DateTime 
              : (map['approvedDate'] as dynamic).toDate())
          : null,
      roomId: map['roomId']?.toString(),
      roomName: map['roomName']?.toString(),
      departmentId: map['departmentId']?.toString(),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is DateTime 
              ? map['createdAt'] as DateTime 
              : (map['createdAt'] as dynamic).toDate())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? (map['updatedAt'] is DateTime 
              ? map['updatedAt'] as DateTime 
              : (map['updatedAt'] as dynamic).toDate())
          : DateTime.now(),
    );
  }

  // Method để chuyển LeaveRequest thành Map (để lưu vào Firestore)
  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'type': type,
      'reason': reason,
      'makeupDate': makeupDate != null ? Timestamp.fromDate(makeupDate!) : null,
      'startTime': startTime,
      'endTime': endTime,
      'additionalNotes': additionalNotes,
      'status': status,
      'teacherId': teacherId,
      'attachments': attachments,
      'approverId': approverId,
      'approverNotes': approverNotes,
      'requestDate': Timestamp.fromDate(requestDate),
      'approvedDate': approvedDate != null ? Timestamp.fromDate(approvedDate!) : null,
      'roomId': roomId,
      'roomName': roomName,
      'departmentId': departmentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest.fromMap(json, json['id']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  LeaveRequest copyWith({
    String? id,
    String? lessonId,
    String? type,
    String? reason,
    DateTime? makeupDate,
    String? startTime,
    String? endTime,
    String? additionalNotes,
    String? status,
    String? teacherId,
    List<String>? attachments,
    String? approverId,
    String? approverNotes,
    DateTime? requestDate,
    DateTime? approvedDate,
    String? roomId,
    String? roomName,
    String? departmentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      makeupDate: makeupDate ?? this.makeupDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      status: status ?? this.status,
      teacherId: teacherId ?? this.teacherId,
      attachments: attachments ?? this.attachments,
      approverId: approverId ?? this.approverId,
      approverNotes: approverNotes ?? this.approverNotes,
      requestDate: requestDate ?? this.requestDate,
      approvedDate: approvedDate ?? this.approvedDate,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      departmentId: departmentId ?? this.departmentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}



