import 'package:cloud_firestore/cloud_firestore.dart';

class Subjects {
  final String id;
  final String name;
  final String code;
  final String departmentId;
  final int credits;
  final int totalHours;
  final String? description; // Mô tả môn học
  final List<String>? prerequisites; // Môn học tiên quyết
  final DateTime createdAt;
  final DateTime updatedAt;

  Subjects({
    required this.id,
    required this.name,
    required this.code,
    required this.departmentId,
    required this.credits,
    required this.totalHours,
    this.description,
    this.prerequisites,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subjects.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Subjects(
      id: id,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      departmentId: json['departmentId'] as String? ?? '',
      credits: json['credits'] as int? ?? 0,
      totalHours: json['totalHours'] as int? ?? 0,
      description: json['description'] as String?,
      prerequisites: json['prerequisites'] != null 
          ? List<String>.from(json['prerequisites'] as List)
          : null,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'departmentId': departmentId,
      'credits': credits,
      'totalHours': totalHours,
      'description': description,
      'prerequisites': prerequisites,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Subjects copyWith({
    String? id,
    String? name,
    String? code,
    String? departmentId,
    int? credits,
    int? totalHours,
    String? description,
    List<String>? prerequisites,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subjects(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      departmentId: departmentId ?? this.departmentId,
      credits: credits ?? this.credits,
      totalHours: totalHours ?? this.totalHours,
      description: description ?? this.description,
      prerequisites: prerequisites ?? this.prerequisites,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
