import '../data/mock/trainer_mock_data.dart';
import '../providers/reception_checkin_provider.dart';
import '../services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Trainer roster id (`m1`, `m2`, …) for the signed-in member user.
String trainerMemberIdForUser(String? displayName) {
  if (displayName == null) return assignedMembers.first.id;
  final lower = displayName.toLowerCase().trim();
  for (final m in assignedMembers) {
    if (m.name.toLowerCase() == lower) return m.id;
  }
  for (final m in assignedMembers) {
    if (lower.contains(m.name.split(' ').first.toLowerCase())) {
      return m.id;
    }
  }
  return assignedMembers.first.id;
}

/// Reception desk id (`M-20481`, …) for QR / attendance log.
String receptionMemberIdForUser(String? displayName) {
  return ReceptionMemberDirectory.memberIdForMemberUser(displayName);
}

final memberTrainerIdProvider = Provider<String>((ref) {
  final name = ref.watch(authServiceProvider)?.name;
  return trainerMemberIdForUser(name);
});

final memberReceptionIdProvider = Provider<String>((ref) {
  final name = ref.watch(authServiceProvider)?.name;
  return receptionMemberIdForUser(name);
});
