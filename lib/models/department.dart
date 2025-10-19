class Department {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? headId; // ID của trưởng bộ môn
  final DateTime createdAt;
  final DateTime updatedAt;

  Department({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.headId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      headId: json['headId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'headId': headId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}



