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

  static const mockOtpCode = '123456';

  static const _knownEmails = {
    'member@fitcore.com',
    'trainer@fitcore.com',
    'reception@fitcore.com',
  };

  Future<bool> _passwordMatches(String normalized, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final custom = prefs.getString(StorageKeys.mockPasswordKey(normalized));
    if (custom != null) return password == custom;
    return password == '123456';
  }

  Future<UserModel> login(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    final normalized = email.trim().toLowerCase();
    if (!await _passwordMatches(normalized, password)) {
      throw AuthException('Invalid email or password');
    }

    UserModel? user;
    if (normalized == 'member@fitcore.com') {
      user = _userMember(_mockToken('member'));
    } else if (normalized == 'trainer@fitcore.com') {
      user = _userTrainer(_mockToken('trainer'));
    } else if (normalized == 'reception@fitcore.com') {
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

  /// Mock profile update — persists to SharedPreferences.
  Future<void> updateProfile({String? name, String? email}) async {
    final current = state;
    if (current == null) return;
    final updated = current.copyWith(
      name: name ?? current.name,
      email: email ?? current.email,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.authUserJson, updated.toJsonString());
    state = updated;
  }

  Future<void> sendPasswordResetOtp(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final normalized = email.trim().toLowerCase();
    if (!_knownEmails.contains(normalized)) {
      throw AuthException('No account found for this email');
    }
  }

  Future<void> verifyPasswordResetOtp(String email, String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (otp.trim() != mockOtpCode) {
      throw AuthException('Invalid or expired OTP');
    }
    final normalized = email.trim().toLowerCase();
    if (!_knownEmails.contains(normalized)) {
      throw AuthException('No account found for this email');
    }
  }

  Future<void> resetPassword({required String email, required String newPassword}) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (newPassword.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }
    final normalized = email.trim().toLowerCase();
    if (!_knownEmails.contains(normalized)) {
      throw AuthException('No account found for this email');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.mockPasswordKey(normalized), newPassword);
  }

  /// Invitation / first-login setup (gym-created account).
  Future<void> completeInvitationSetup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    final normalized = email.trim().toLowerCase();
    if (!_knownEmails.contains(normalized)) {
      throw AuthException('Invalid invitation. Use a demo gym email.');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.mockPasswordKey(normalized), password);
    await prefs.remove(StorageKeys.pendingInviteEmail);
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
