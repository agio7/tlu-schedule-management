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
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      departmentId: json['departmentId'],
      credits: json['credits'],
      totalHours: json['totalHours'],
      description: json['description'],
      prerequisites: json['prerequisites'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
}



