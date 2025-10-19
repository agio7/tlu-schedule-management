class Classroom {
  final String id;
  final String name;
  final String code;
  final String departmentId;
  final int year; // Năm học
  final String semester; // Học kỳ
  final int studentCount;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Classroom({
    required this.id,
    required this.name,
    required this.code,
    required this.departmentId,
    required this.year,
    required this.semester,
    required this.studentCount,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      departmentId: json['departmentId'],
      year: json['year'],
      semester: json['semester'],
      studentCount: json['studentCount'],
      description: json['description'],
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
      'year': year,
      'semester': semester,
      'studentCount': studentCount,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}



