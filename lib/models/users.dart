import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'teacher', 'staff', 'admin'
  final String? departmentId;
  final String? employeeId;
  final String? academicRank;
  final String? avatar;
  final String? specialization;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Users({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.departmentId,
    this.employeeId,
    this.academicRank,
    this.avatar,
    this.specialization,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Users.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Users(
      id: id,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Người dùng không tên',
      role: json['role'] as String? ?? 'teacher',
      departmentId: json['departmentId'] as String?,
      employeeId: json['employeeId'] as String?,
      academicRank: json['academicRank'] as String?,
      avatar: json['avatar'] as String?,
      specialization: json['specialization'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullName': fullName,
      'role': role,
      'departmentId': departmentId,
      'employeeId': employeeId,
      'academicRank': academicRank,
      'avatar': avatar,
      'specialization': specialization,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Users copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? departmentId,
    String? employeeId,
    String? academicRank,
    String? avatar,
    String? specialization,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Users(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      employeeId: employeeId ?? this.employeeId,
      academicRank: academicRank ?? this.academicRank,
      avatar: avatar ?? this.avatar,
      specialization: specialization ?? this.specialization,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
