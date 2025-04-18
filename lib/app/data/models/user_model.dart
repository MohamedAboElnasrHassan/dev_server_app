import '../../../core/database/base_model.dart';

class UserModel implements BaseModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> roles;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.roles = const ['user'],
  }) :
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  @override
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'roles': roles.join(','),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'] ?? '',
      avatar: map['avatar'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at'] ?? map['created_at']),
      roles: map['roles']?.split(',') ?? ['user'],
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'] ?? '',
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at']),
      roles: json['roles'] is List
          ? List<String>.from(json['roles'])
          : json['roles']?.split(',') ?? ['user'],
    );
  }

  @override
  Map<String, dynamic> toJson() => toMap();

  @override
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roles: roles ?? this.roles,
    );
  }

  /// التحقق من وجود دور معين
  bool hasRole(String role) {
    return roles.contains(role);
  }

  /// التحقق من وجود أي دور من مجموعة أدوار
  bool hasAnyRole(List<String> roleList) {
    return roles.any((role) => roleList.contains(role));
  }

  /// التحقق من وجود جميع الأدوار
  bool hasAllRoles(List<String> roleList) {
    return roleList.every((role) => roles.contains(role));
  }
}
