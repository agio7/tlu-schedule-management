import 'package:cloud_firestore/cloud_firestore.dart';

class Subject {
  final String id;
  final String name;
  final String code;
  final String departmentId;
  final int credits;
  final int totalHours;
  final String? description;
  final String? prerequisites; // Môn học tiên quyết
  final DateTime createdAt;
  final DateTime updatedAt;

  Subject({
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

  factory Subject.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      departmentId: json['departmentId'] ?? '',
      credits: json['credits'] ?? 0,
      totalHours: json['totalHours'] ?? 0,
      description: json['description'],
      prerequisites: json['prerequisites'],
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
      'credits': credits,
      'totalHours': totalHours,
      'description': description,
      'prerequisites': prerequisites,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? departmentId,
    int? credits,
    int? totalHours,
    String? description,
    String? prerequisites,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
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



