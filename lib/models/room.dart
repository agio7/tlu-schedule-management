import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String id;
  final String name;
  final String code;
  final String? building;
  final int capacity;
  final String type; // 'lecture', 'lab', 'seminar'
  final int floor;
  final List<String> equipment; // Thiết bị có sẵn
  final String? description;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Room({
    required this.id,
    required this.name,
    required this.code,
    this.building,
    required this.capacity,
    required this.type,
    required this.floor,
    required this.equipment,
    this.description,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Room(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      building: json['building'],
      capacity: json['capacity'] ?? 0,
      type: json['type'] ?? 'lecture',
      floor: json['floor'] ?? 1,
      equipment: List<String>.from(json['equipment'] ?? []),
      description: json['description'],
      isAvailable: json['isAvailable'] ?? true,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
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
      'floor': floor,
      'equipment': equipment,
      'description': description,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Room copyWith({
    String? id,
    String? name,
    String? code,
    String? building,
    int? capacity,
    String? type,
    int? floor,
    List<String>? equipment,
    String? description,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      building: building ?? this.building,
      capacity: capacity ?? this.capacity,
      type: type ?? this.type,
      floor: floor ?? this.floor,
      equipment: equipment ?? this.equipment,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}



