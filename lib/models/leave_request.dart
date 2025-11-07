import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequest {
  final String id;
  final String lessonId;
  final String type; // 'leave' | 'makeup'
  final String reason;
  final DateTime? makeupDate;
  final String startTime;
  final String endTime;
  final String? additionalNotes;
  final String teacherId;
  final DateTime requestDate;
  final String? roomId;
  final String? roomName;
  final String? departmentId;
  final String status; // 'pending' | 'approved' | 'rejected'
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
    required this.teacherId,
    required this.requestDate,
    this.roomId,
    this.roomName,
    this.departmentId,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  LeaveRequest copyWith({
    String? id,
    String? lessonId,
    String? type,
    String? reason,
    DateTime? makeupDate,
    String? startTime,
    String? endTime,
    String? additionalNotes,
    String? teacherId,
    DateTime? requestDate,
    String? roomId,
    String? roomName,
    String? departmentId,
    String? status,
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
      teacherId: teacherId ?? this.teacherId,
      requestDate: requestDate ?? this.requestDate,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      departmentId: departmentId ?? this.departmentId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory LeaveRequest.fromMap(Map<String, dynamic> map, String id) {
    return LeaveRequest(
      id: id,
      lessonId: map['lessonId']?.toString() ?? '',
      type: map['type']?.toString() ?? 'leave',
      reason: map['reason']?.toString() ?? '',
      makeupDate: map['makeupDate'] != null ? _parseTimestamp(map['makeupDate']) : null,
      startTime: map['startTime']?.toString() ?? '',
      endTime: map['endTime']?.toString() ?? '',
      additionalNotes: map['additionalNotes']?.toString(),
      teacherId: map['teacherId']?.toString() ?? '',
      requestDate: _parseTimestamp(map['requestDate']),
      roomId: map['roomId']?.toString(),
      roomName: map['roomName']?.toString(),
      departmentId: map['departmentId']?.toString(),
      status: map['status']?.toString() ?? 'pending',
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'type': type,
      'reason': reason,
      'makeupDate': makeupDate != null ? Timestamp.fromDate(makeupDate!) : null,
      'startTime': startTime,
      'endTime': endTime,
      'additionalNotes': additionalNotes,
      'teacherId': teacherId,
      'requestDate': Timestamp.fromDate(requestDate),
      'roomId': roomId,
      'roomName': roomName,
      'departmentId': departmentId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}


