import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// Mock push preference (no Firebase in prototype).
class PushNotificationPrefsNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(StorageKeys.pushNotificationsEnabled) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.pushNotificationsEnabled, value);
  }
}

final pushNotificationPrefsProvider =
    NotifierProvider<PushNotificationPrefsNotifier, bool>(PushNotificationPrefsNotifier.new);
