import 'package:cloud_firestore/cloud_firestore.dart';

class Departments {
  final String id;
  final String name;
  final String code;
  final String? headId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Departments({
    required this.id,
    required this.name,
    required this.code,
    this.headId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Departments.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Departments(
      id: id,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      headId: json['headId'] as String?,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'headId': headId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Departments copyWith({
    String? id,
    String? name,
    String? code,
    String? headId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Departments(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      headId: headId ?? this.headId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}


