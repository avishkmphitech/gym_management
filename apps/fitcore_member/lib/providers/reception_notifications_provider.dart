import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import 'reception_checkin_provider.dart';

/// Members still checked in longer than this trigger a reception alert.
const receptionOverstayHours = 23;

class ReceptionNotificationsState {
  const ReceptionNotificationsState({
    required this.items,
    required this.readIds,
  });

  final List<AppNotification> items;
  final Set<String> readIds;

  int get unreadCount => items.where((n) => !readIds.contains(n.id)).length;

  List<AppNotification> get displayItems {
    return [
      for (final n in items)
        n.copyWith(read: readIds.contains(n.id)),
    ];
  }
}

class ReceptionNotificationsNotifier extends Notifier<ReceptionNotificationsState> {
  @override
  ReceptionNotificationsState build() {
    ref.listen(receptionAttendanceProvider, (_, _) => _rebuild());
    return _buildState();
  }

  ReceptionNotificationsState _buildState() {
    final attendance = ref.read(receptionAttendanceProvider);
    final now = DateTime.now();
    final items = <AppNotification>[];

    for (final entry in attendance.activeSessions.entries) {
      final session = entry.value;
      final hoursIn = now.difference(session.checkedInAt).inHours;
      if (hoursIn >= receptionOverstayHours) {
        final memberName = _memberName(attendance, session.memberId);
        items.add(
          AppNotification(
            id: 'rn_overstay_${session.memberId}',
            title: 'No checkout · over 23 hours',
            body:
                '$memberName checked in at ${session.checkInTimeLabel} and has not checked out (${hoursIn}h in gym). Please verify.',
            timeLabel: 'Alert · now',
            category: AppNotificationCategory.overstayCheckout,
            memberId: session.memberId,
            memberName: memberName,
            severity: AppNotificationSeverity.critical,
          ),
        );
      }
    }

    items.addAll(const [
      AppNotification(
        id: 'rn_plan_1',
        title: 'Membership plan updated',
        body: 'Trainer assigned "Athletic · 3-day" week plan to Meera Shah.',
        timeLabel: 'Today · 9:10 AM',
        category: AppNotificationCategory.planAssigned,
        memberId: 'M-21004',
        memberName: 'Meera Shah',
      ),
      AppNotification(
        id: 'rn_plan_2',
        title: 'Meal plan assigned',
        body: 'Vegetarian cut phase assigned to Meera Shah by Coach Riya.',
        timeLabel: 'Today · 8:45 AM',
        category: AppNotificationCategory.planAssigned,
        memberId: 'M-21004',
        memberName: 'Meera Shah',
      ),
      AppNotification(
        id: 'rn_plan_3',
        title: 'New member plan',
        body: 'Dev Malhotra — membership renewed to Pro (desk note: collect payment).',
        timeLabel: 'Yesterday · 4:20 PM',
        category: AppNotificationCategory.planUpdated,
        memberId: 'M-21110',
        memberName: 'Dev Malhotra',
        severity: AppNotificationSeverity.warning,
      ),
    ]);

    items.sort((a, b) {
      final sa = a.severity == AppNotificationSeverity.critical ? 0 : 1;
      final sb = b.severity == AppNotificationSeverity.critical ? 0 : 1;
      return sa.compareTo(sb);
    });

    return ReceptionNotificationsState(items: items, readIds: stateOrNull?.readIds ?? {});
  }

  String _memberName(ReceptionAttendanceState attendance, String memberId) {
    for (final log in attendance.log) {
      if (log.memberId == memberId) return log.memberName;
    }
    return memberId;
  }

  void _rebuild() {
    final readIds = state.readIds;
    state = ReceptionNotificationsState(items: _buildState().items, readIds: readIds);
  }

  void markRead(String id) {
    state = ReceptionNotificationsState(
      items: state.items,
      readIds: {...state.readIds, id},
    );
  }

  void markAllRead() {
    state = ReceptionNotificationsState(
      items: state.items,
      readIds: {...state.readIds, ...state.items.map((e) => e.id)},
    );
  }
}

final receptionNotificationsProvider =
    NotifierProvider<ReceptionNotificationsNotifier, ReceptionNotificationsState>(
  ReceptionNotificationsNotifier.new,
);
