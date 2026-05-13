import 'dart:convert';

/// Mobile RBAC user — role matches JWT-style strings.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.gymId,
    required this.gymName,
    required this.token,
    required this.permissions,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  /// `'MEMBER' | 'TRAINER' | 'RECEPTIONIST'`
  final String role;
  final String gymId;
  final String gymName;
  final String token;
  final List<String> permissions;
  final String? avatarUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      gymId: json['gymId'] as String,
      gymName: json['gymName'] as String,
      token: json['token'] as String,
      permissions: (json['permissions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'gymId': gymId,
      'gymName': gymName,
      'token': token,
      'permissions': permissions,
      'avatarUrl': avatarUrl,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? gymId,
    String? gymName,
    String? token,
    List<String>? permissions,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      token: token ?? this.token,
      permissions: permissions ?? this.permissions,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
