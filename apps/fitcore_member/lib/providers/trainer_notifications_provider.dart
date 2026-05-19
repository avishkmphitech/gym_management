import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import 'trainer_provider.dart';

class TrainerNotificationsState {
  const TrainerNotificationsState({
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

class TrainerNotificationsNotifier extends Notifier<TrainerNotificationsState> {
  @override
  TrainerNotificationsState build() {
    ref.listen(trainerProvider, (_, __) => _rebuild());
    return _buildState();
  }

  TrainerNotificationsState _buildState() {
    final trainer = ref.read(trainerProvider);
    final prefs = trainer.notificationPrefs;
    final items = <AppNotification>[];

    for (final a in trainer.assignmentHistory.take(8)) {
      final isDiet = a.type == 'diet';
      items.add(
        AppNotification(
          id: 'tn_${a.id}',
          title: isDiet ? 'Meal plan assigned' : 'Week plan assigned',
          body: '${a.planName} → ${a.memberName}',
          timeLabel: a.assignedAtLabel,
          category: AppNotificationCategory.planAssigned,
          memberName: a.memberName,
          severity: AppNotificationSeverity.info,
        ),
      );
    }

    if (prefs.memberCheckInAlerts) {
      items.add(
        const AppNotification(
          id: 'tn_checkin_1',
          title: 'Member checked in',
          body: 'Aarav Khanna checked in at the front desk.',
          timeLabel: 'Today · 6:42 AM',
          category: AppNotificationCategory.memberCheckIn,
          memberId: 'm1',
          memberName: 'Aarav Khanna',
        ),
      );
    }

    if (prefs.sessionReminders) {
      items.add(
        const AppNotification(
          id: 'tn_session_1',
          title: 'Session in 15 minutes',
          body: 'PT · Upper body with Priya Shah · Studio A',
          timeLabel: 'Today · 10:15 AM',
          category: AppNotificationCategory.sessionReminder,
          memberName: 'Priya Shah',
          severity: AppNotificationSeverity.warning,
        ),
      );
    }

    if (prefs.workoutReminders) {
      items.add(
        const AppNotification(
          id: 'tn_workout_1',
          title: 'Workout completed',
          body: 'Meera Shah finished Lower B (assigned week plan).',
          timeLabel: 'Yesterday · 6:10 PM',
          category: AppNotificationCategory.planUpdated,
          memberName: 'Meera Shah',
        ),
      );
    }

    items.add(
      const AppNotification(
        id: 'tn_system_1',
        title: 'Welcome to FitCore alerts',
        body: 'Assignment and session notifications appear here. Toggle types in Settings.',
        timeLabel: 'This week',
        category: AppNotificationCategory.system,
      ),
    );

    return TrainerNotificationsState(items: items, readIds: stateOrNull?.readIds ?? {});
  }

  void _rebuild() {
    final readIds = state.readIds;
    state = _buildState().copyWithReadIds(readIds);
  }

  void markRead(String id) {
    state = state.copyWithReadIds({...state.readIds, id});
  }

  void markAllRead() {
    state = state.copyWithReadIds({...state.readIds, ...state.items.map((e) => e.id)});
  }
}

extension on TrainerNotificationsState {
  TrainerNotificationsState copyWithReadIds(Set<String> readIds) {
    return TrainerNotificationsState(items: items, readIds: readIds);
  }
}

final trainerNotificationsProvider =
    NotifierProvider<TrainerNotificationsNotifier, TrainerNotificationsState>(
  TrainerNotificationsNotifier.new,
);
