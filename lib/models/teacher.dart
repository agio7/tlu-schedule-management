import 'package:cloud_firestore/cloud_firestore.dart';

class Teacher {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? departmentId;
  final String? phoneNumber;
  final String? avatar;
  final String? employeeId; // Mã số giảng viên
  final String? specialization; // Chuyên ngành
  final String? academicRank; // Học hàm, học vị
  final DateTime createdAt;
  final DateTime updatedAt;

  Teacher({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.departmentId,
    this.phoneNumber,
    this.avatar,
    this.employeeId,
    this.specialization,
    this.academicRank,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Teacher.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Teacher(
      id: id,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Giảng viên không tên',
      role: json['role'] as String? ?? 'teacher',
      departmentId: json['departmentId'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatar: json['avatar'] as String?,
      employeeId: json['employeeId'] as String?,
      specialization: json['specialization'] as String?,
      academicRank: json['academicRank'] as String? ?? 'Giảng viên',
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
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'employeeId': employeeId,
      'specialization': specialization,
      'academicRank': academicRank,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Teacher copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? departmentId,
    String? phoneNumber,
    String? avatar,
    String? employeeId,
    String? specialization,
    String? academicRank,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      employeeId: employeeId ?? this.employeeId,
      specialization: specialization ?? this.specialization,
      academicRank: academicRank ?? this.academicRank,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
