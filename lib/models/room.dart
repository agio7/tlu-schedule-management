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
    return Room(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      building: json['building'],
      capacity: json['capacity'],
      type: json['type'],
      equipment: List<String>.from(json['equipment'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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



