import 'package:cloud_firestore/cloud_firestore.dart';

class Students {
  final String id;
  final String fullName;
  final String email;
  final String classroomId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Students({
    required this.id,
    required this.fullName,
    required this.email,
    required this.classroomId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Students.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Students(
      id: id,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      classroomId: json['classroomId'] as String? ?? '',
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'classroomId': classroomId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Students copyWith({
    String? id,
    String? fullName,
    String? email,
    String? classroomId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Students(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      classroomId: classroomId ?? this.classroomId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


