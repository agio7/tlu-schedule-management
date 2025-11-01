import 'package:cloud_firestore/cloud_firestore.dart';

class Classrooms {
  final String id;
  final String name;
  final String code;
  final String departmentId;
  final String academicYear;
  final String? description; // Mô tả lớp học
  final int? studentCount; // Số lượng sinh viên
  final String? semester; // Học kỳ
  final DateTime createdAt;
  final DateTime updatedAt;

  Classrooms({
    required this.id,
    required this.name,
    required this.code,
    required this.departmentId,
    required this.academicYear,
    this.description,
    this.studentCount,
    this.semester,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Classrooms.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Classrooms(
      id: id,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      departmentId: json['departmentId'] as String? ?? '',
      academicYear: json['academicYear'] as String? ?? '',
      description: json['description'] as String?,
      studentCount: json['studentCount'] as int?,
      semester: json['semester'] as String?,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'departmentId': departmentId,
      'academicYear': academicYear,
      'description': description,
      'studentCount': studentCount,
      'semester': semester,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Classrooms copyWith({
    String? id,
    String? name,
    String? code,
    String? departmentId,
    String? academicYear,
    String? description,
    int? studentCount,
    String? semester,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Classrooms(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      departmentId: departmentId ?? this.departmentId,
      academicYear: academicYear ?? this.academicYear,
      description: description ?? this.description,
      studentCount: studentCount ?? this.studentCount,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
