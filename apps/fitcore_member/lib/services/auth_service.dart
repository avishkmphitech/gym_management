import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../models/user_model.dart';

/// Mock JWT-style token prefix (prototype).
String _mockToken(String userId) => 'mock_jwt_${userId}_${DateTime.now().millisecondsSinceEpoch}';

UserModel _userMember(String token) {
  return UserModel(
    id: 'usr_member_01',
    name: 'Aarav Khanna',
    email: 'member@fitcore.com',
    role: 'MEMBER',
    gymId: 'gym_apex_iron',
    gymName: 'Apex Iron Gym',
    token: token,
    permissions: const [
      'workouts:read',
      'diet:read',
      'attendance:read',
      'profile:read',
      'profile:write',
    ],
    avatarUrl: null,
  );
}

UserModel _userTrainer(String token) {
  return UserModel(
    id: 'usr_trainer_01',
    name: 'Riya Kapoor',
    email: 'trainer@fitcore.com',
    role: 'TRAINER',
    gymId: 'gym_apex_iron',
    gymName: 'Apex Iron Gym',
    token: token,
    permissions: const [
      'members:read',
      'plans:write',
      'diet:read',
      'diet:write',
      'schedule:read',
      'schedule:write',
      'profile:read',
    ],
    avatarUrl: null,
  );
}

UserModel _userReceptionist(String token) {
  return UserModel(
    id: 'usr_reception_01',
    name: 'Neha Desai',
    email: 'reception@fitcore.com',
    role: 'RECEPTIONIST',
    gymId: 'gym_apex_iron',
    gymName: 'Apex Iron Gym',
    token: token,
    permissions: const [
      'checkin:write',
      'members:read',
      'attendance_log:read',
      'profile:read',
    ],
    avatarUrl: null,
  );
}

/// Keeps trainer meal-plan actions working for sessions saved before [diet:write] existed.
UserModel _ensureTrainerPermissions(UserModel user) {
  if (user.role != 'TRAINER') return user;
  const required = ['members:read', 'plans:write', 'diet:read', 'diet:write', 'schedule:read', 'schedule:write'];
  final merged = {...user.permissions, ...required}.toList();
  if (merged.length == user.permissions.length) return user;
  return user.copyWith(permissions: merged);
}

class AuthService extends StateNotifier<UserModel?> {
  AuthService() : super(null);

  UserModel? get currentUser => state;

  bool get isLoggedIn => state != null;

  String get role => state?.role ?? '';

  bool hasPermission(String key) => state?.permissions.contains(key) ?? false;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(StorageKeys.authUserJson);
    final token = prefs.getString(StorageKeys.authToken);
    if (raw == null || token == null || raw.isEmpty || token.isEmpty) {
      state = null;
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      var user = UserModel.fromJson(map).copyWith(token: token);
      user = _ensureTrainerPermissions(user);
      state = user;
    } catch (_) {
      state = null;
      await prefs.remove(StorageKeys.authUserJson);
      await prefs.remove(StorageKeys.authToken);
    }
  }

  Future<UserModel> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    final normalized = email.trim().toLowerCase();
    UserModel? user;
    if (normalized == 'member@fitcore.com' && password == '123456') {
      user = _userMember(_mockToken('member'));
    } else if (normalized == 'trainer@fitcore.com' && password == '123456') {
      user = _userTrainer(_mockToken('trainer'));
    } else if (normalized == 'reception@fitcore.com' && password == '123456') {
      user = _userReceptionist(_mockToken('reception'));
    } else {
      throw AuthException('Invalid email or password');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.authToken, user.token);
    await prefs.setString(StorageKeys.authUserJson, user.toJsonString());
    state = user;
    return user;
  }

  /// Dev-only: switch mock user without password (keeps storage in sync).
  Future<void> setMockUserForRole(String role) async {
    final token = _mockToken(role.toLowerCase());
    final UserModel user;
    switch (role) {
      case 'MEMBER':
        user = _userMember(token);
        break;
      case 'TRAINER':
        user = _userTrainer(token);
        break;
      case 'RECEPTIONIST':
        user = _userReceptionist(token);
        break;
      default:
        return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.authToken, user.token);
    await prefs.setString(StorageKeys.authUserJson, user.toJsonString());
    state = user;
  }

  Future<void> logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.authToken);
    await prefs.remove(StorageKeys.authUserJson);
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

final authServiceProvider = StateNotifierProvider<AuthService, UserModel?>((ref) {
  return AuthService();
});
