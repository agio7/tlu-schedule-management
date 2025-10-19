// models/user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? departmentId;
  final String? phoneNumber;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.departmentId,
    this.phoneNumber,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  // PHIÊN BẢN CẬP NHẬT - AN TOÀN HƠN
  factory User.fromJson(String id, Map<String, dynamic> json) {
    // Hàm an toàn để chuyển đổi Timestamp sang DateTime
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      // Nếu dữ liệu là String (từ code cũ), thử parse
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return User(
      // 1. Lấy ID từ tham số truyền vào, không phải từ json
      id: id,
      // 2. Cung cấp giá trị mặc định để tránh lỗi 'null'
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Người dùng không tên',
      role: json['role'] as String? ?? 'teacher', // Mặc định là teacher nếu thiếu
      departmentId: json['departmentId'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatar: json['avatar'] as String?,
      // 3. Xử lý Timestamp một cách an toàn
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  // Các hàm toJson và copyWith không cần thay đổi
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'departmentId': departmentId,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? departmentId,
    String? phoneNumber,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}