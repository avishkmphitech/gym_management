abstract final class StorageKeys {
  /// When true, user has finished onboarding and should go to login on cold start.
  static const String onboardingComplete = 'fitcore_onboarding_complete';

  static const String authToken = 'fitcore_auth_token';
  static const String authUserJson = 'fitcore_auth_user_json';

  /// Mock per-email password override after reset / invite setup.
  static String mockPasswordKey(String normalizedEmail) => 'fitcore_mock_password_$normalizedEmail';

  static const String pushNotificationsEnabled = 'fitcore_push_notifications_enabled';

  /// When set, user should complete invitation setup before login.
  static const String pendingInviteEmail = 'fitcore_pending_invite_email';
}
