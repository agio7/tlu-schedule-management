import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String code;
  final String building;
  final int capacity;
  final String type; // 'lecture', 'lab', 'seminar'
  final List<String> equipment; // Thiết bị có sẵn
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.name,
    required this.code,
    required this.building,
    required this.capacity,
    required this.type,
    required this.equipment,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    // Xử lý createdAt và updatedAt an toàn
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is DateTime) {
        return value;
      }
      return DateTime.now();
    }

    // Xử lý capacity (có thể là number hoặc string)
    int parseCapacity(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return Room(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      building: json['building']?.toString() ?? '',
      capacity: parseCapacity(json['capacity']),
      type: json['type']?.toString() ?? 'lecture',
      equipment: List<String>.from(json['equipment'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'building': building,
      'capacity': capacity,
      'type': type,
      'equipment': equipment,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}



