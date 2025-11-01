import 'package:cloud_firestore/cloud_firestore.dart';

class Rooms {
  final String id;
  final String name;
  final String code;
  final String? building;
  final int capacity;
  final String? type; // Loại phòng (lecture, lab, computer, etc.)
  final int? floor; // Tầng
  final String? description; // Mô tả phòng
  final List<String>? equipment; // Thiết bị trong phòng
  final DateTime createdAt;
  final DateTime updatedAt;

  Rooms({
    required this.id,
    required this.name,
    required this.code,
    this.building,
    required this.capacity,
    this.type,
    this.floor,
    this.description,
    this.equipment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Rooms.fromJson(String id, Map<String, dynamic> json) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Rooms(
      id: id,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      building: json['building'] as String?,
      capacity: json['capacity'] as int? ?? 0,
      type: json['type'] as String?,
      floor: json['floor'] as int?,
      description: json['description'] as String?,
      equipment: json['equipment'] != null 
          ? List<String>.from(json['equipment'] as List)
          : null,
      createdAt: parseTimestamp(json['createdAt']),
      updatedAt: parseTimestamp(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'building': building,
      'capacity': capacity,
      'type': type,
      'floor': floor,
      'description': description,
      'equipment': equipment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Rooms copyWith({
    String? id,
    String? name,
    String? code,
    String? building,
    int? capacity,
    String? type,
    int? floor,
    String? description,
    List<String>? equipment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Rooms(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      building: building ?? this.building,
      capacity: capacity ?? this.capacity,
      type: type ?? this.type,
      floor: floor ?? this.floor,
      description: description ?? this.description,
      equipment: equipment ?? this.equipment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
