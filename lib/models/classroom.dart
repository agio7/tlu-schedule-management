import 'package:cloud_firestore/cloud_firestore.dart';

class Classroom {
  final String id;
  final String name;
  final String code;
  final String departmentId;
  final String academicYear; // Năm học (2024-2025)
  final String semester; // Học kỳ (1, 2, 3)
  final int studentCount;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Classroom({
    required this.id,
    required this.name,
    required this.code,
    required this.departmentId,
    required this.academicYear,
    required this.semester,
    required this.studentCount,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Classroom(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      departmentId: json['departmentId'] ?? '',
      academicYear: json['academicYear'] ?? '',
      semester: json['semester'] ?? '',
      studentCount: json['studentCount'] ?? 0,
      description: json['description'],
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'departmentId': departmentId,
      'academicYear': academicYear,
      'semester': semester,
      'studentCount': studentCount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Classroom copyWith({
    String? id,
    String? name,
    String? code,
    String? departmentId,
    String? academicYear,
    String? semester,
    int? studentCount,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      departmentId: departmentId ?? this.departmentId,
      academicYear: academicYear ?? this.academicYear,
      semester: semester ?? this.semester,
      studentCount: studentCount ?? this.studentCount,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}



