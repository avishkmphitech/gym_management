import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../models/reception_checkin.dart';
import 'member_identity.dart';
import 'member_provider.dart';
import 'reception_checkin_provider.dart';
import 'trainer_provider.dart';

class MemberNotificationsState {
  const MemberNotificationsState({
    required this.items,
    required this.readIds,
  });

  final List<AppNotification> items;
  final Set<String> readIds;

  int get unreadCount => items.where((n) => !readIds.contains(n.id)).length;

  List<AppNotification> get displayItems {
    return [for (final n in items) n.copyWith(read: readIds.contains(n.id))];
  }
}

class MemberNotificationsNotifier extends Notifier<MemberNotificationsState> {
  @override
  MemberNotificationsState build() {
    ref.listen(trainerProvider, (_, _) => _rebuild());
    ref.listen(receptionAttendanceProvider, (_, _) => _rebuild());
    ref.listen(memberMembershipProvider, (_, _) => _rebuild());
    return _buildState();
  }

  MemberNotificationsState _buildState() {
    final trainerId = ref.read(memberTrainerIdProvider);
    final deskId = ref.read(memberReceptionIdProvider);
    final trainer = ref.read(trainerProvider);
    final membership = ref.read(memberMembershipProvider);
    final attendance = ref.read(receptionAttendanceProvider);
    final items = <AppNotification>[];

    for (final a in trainer.assignmentsForMember(trainerId)) {
      final isDiet = a.type == 'diet';
      items.add(
        AppNotification(
          id: 'mn_${a.id}',
          title: isDiet ? 'New meal plan' : 'New workout plan',
          body: 'Your trainer assigned ${a.planName}.',
          timeLabel: a.assignedAtLabel,
          category: AppNotificationCategory.planAssigned,
          severity: AppNotificationSeverity.info,
        ),
      );
    }

    final weekLabel = trainer.weeklyWorkoutLabelForMember(trainerId);
    if (weekLabel != null) {
      items.add(
        AppNotification(
          id: 'mn_week_active',
          title: 'Active week plan',
          body: weekLabel,
          timeLabel: 'Current program',
          category: AppNotificationCategory.planUpdated,
        ),
      );
    }

    for (final entry in attendance.log) {
      if (entry.memberId != deskId) continue;
      if (entry.action == AttendanceAction.checkIn) {
        items.add(
          AppNotification(
            id: 'mn_log_${entry.id}',
            title: 'Checked in',
            body: 'Desk scan at ${entry.timeLabel}.',
            timeLabel: _formatRecorded(entry.recordedAt),
            category: AppNotificationCategory.memberCheckIn,
          ),
        );
      }
    }

    if (membership.daysRemaining <= 7) {
      items.add(
        AppNotification(
          id: 'mn_renew',
          title: 'Membership ending soon',
          body:
              '${membership.planLabel} expires in ${membership.daysRemaining} days. Visit reception to renew your plan.',
          timeLabel: 'Reminder',
          category: AppNotificationCategory.system,
          severity: AppNotificationSeverity.warning,
        ),
      );
    }

    items.add(
      const AppNotification(
        id: 'mn_welcome',
        title: 'FitCore member alerts',
        body: 'Plan updates, check-ins, and renewal reminders appear here.',
        timeLabel: 'Getting started',
        category: AppNotificationCategory.system,
      ),
    );

    return MemberNotificationsState(items: items, readIds: stateOrNull?.readIds ?? {});
  }

  static String _formatRecorded(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  void _rebuild() {
    final readIds = state.readIds;
    state = MemberNotificationsState(items: _buildState().items, readIds: readIds);
  }

  void markRead(String id) {
    state = MemberNotificationsState(items: state.items, readIds: {...state.readIds, id});
  }

  void markAllRead() {
    state = MemberNotificationsState(
      items: state.items,
      readIds: {...state.readIds, ...state.items.map((e) => e.id)},
    );
  }
}

final memberNotificationsProvider =
    NotifierProvider<MemberNotificationsNotifier, MemberNotificationsState>(
  MemberNotificationsNotifier.new,
);

final memberUnreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(memberNotificationsProvider).unreadCount;
});
