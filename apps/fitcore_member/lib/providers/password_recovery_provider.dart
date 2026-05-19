import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory draft for forgot-password flow (prototype).
class PasswordRecoveryDraft {
  const PasswordRecoveryDraft({this.email, this.otpVerified = false});

  final String? email;
  final bool otpVerified;
}

class PasswordRecoveryNotifier extends Notifier<PasswordRecoveryDraft> {
  @override
  PasswordRecoveryDraft build() => const PasswordRecoveryDraft();

  void setEmail(String email) {
    state = PasswordRecoveryDraft(email: email.trim().toLowerCase());
  }

  void markOtpVerified() {
    if (state.email == null) return;
    state = PasswordRecoveryDraft(email: state.email, otpVerified: true);
  }

  void clear() => state = const PasswordRecoveryDraft();
}

final passwordRecoveryProvider =
    NotifierProvider<PasswordRecoveryNotifier, PasswordRecoveryDraft>(PasswordRecoveryNotifier.new);
