class User {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'admin', 'teacher', 'department_head'
  final String? departmentId;
  final String? phoneNumber;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.departmentId,
    this.phoneNumber,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      role: json['role'],
      departmentId: json['departmentId'],
      phoneNumber: json['phoneNumber'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'departmentId': departmentId,
      'phoneNumber': phoneNumber,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? departmentId,
    String? phoneNumber,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}



