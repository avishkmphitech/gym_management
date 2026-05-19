import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_models.dart';
import '../models/reception_checkin.dart';
import '../providers/member_identity.dart';
import '../providers/reception_checkin_provider.dart';
import '../services/auth_service.dart';
import 'trainer_provider.dart';

/// Membership shown on home / profile (mock; reception updates renewal at desk).
class MemberMembershipInfo {
  const MemberMembershipInfo({
    required this.planLabel,
    required this.tier,
    required this.status,
    required this.expiresAt,
    required this.daysRemaining,
    required this.daysTotal,
    required this.trainerName,
    required this.gymName,
    required this.memberDeskId,
  });

  final String planLabel;
  final String tier;
  final String status;
  final DateTime expiresAt;
  final int daysRemaining;
  final int daysTotal;
  final String trainerName;
  final String gymName;
  final String memberDeskId;

  double get progressFraction =>
      daysTotal <= 0 ? 0 : (daysTotal - daysRemaining).clamp(0, daysTotal) / daysTotal;
}

final memberWeeklyWorkoutPlanProvider = Provider<MockWeeklyWorkoutPlan?>((ref) {
  final trainerId = ref.watch(memberTrainerIdProvider);
  final trainer = ref.watch(trainerProvider);
  final planId = trainer.memberWeeklyWorkoutByMemberId[trainerId];
  if (planId == null) return null;
  return trainer.weeklyPlanById(planId);
});

final memberDietPlanProvider = Provider<MockMeal?>((ref) {
  final trainerId = ref.watch(memberTrainerIdProvider);
  final trainer = ref.watch(trainerProvider);
  final dietId = trainer.memberDietByMemberId[trainerId];
  if (dietId == null) return null;
  return trainer.dietById(dietId);
});

final memberProgressProvider = Provider<MockMemberProgress?>((ref) {
  final trainerId = ref.watch(memberTrainerIdProvider);
  return ref.watch(trainerProvider).progressByMemberId[trainerId];
});

final memberAssignedMemberProvider = Provider<MockAssignedMember?>((ref) {
  final trainerId = ref.watch(memberTrainerIdProvider);
  return ref.watch(trainerProvider).memberById(trainerId);
});

final memberMembershipProvider = Provider<MemberMembershipInfo>((ref) {
  final user = ref.watch(authServiceProvider);
  final roster = ref.watch(memberAssignedMemberProvider);
  final deskId = ref.watch(memberReceptionIdProvider);
  final desk = ReceptionMemberDirectory.byMemberId(deskId);

  final now = DateTime.now();
  final expires = DateTime(now.year, now.month + 1, 0); // last day of current month
  final daysInMonth = expires.day;
  final daysRemaining = expires.difference(DateTime(now.year, now.month, now.day)).inDays + 1;

  final tier = desk?.plan ?? roster?.plan ?? 'Standard';

  return MemberMembershipInfo(
    planLabel: tier == 'Pro' ? 'Monthly Pro Plan' : '$tier Plan',
    tier: tier,
    status: 'Active',
    expiresAt: expires,
    daysRemaining: daysRemaining.clamp(0, daysInMonth),
    daysTotal: daysInMonth,
    trainerName: 'Riya Kapoor',
    gymName: user?.gymName ?? 'Apex Iron Gym',
    memberDeskId: deskId,
  );
});

/// Check-in / check-out log rows for the signed-in member (newest first).
final memberAttendanceLogProvider = Provider<List<ReceptionCheckInRecord>>((ref) {
  final deskId = ref.watch(memberReceptionIdProvider);
  return ref
      .watch(receptionAttendanceProvider)
      .log
      .where((e) => e.memberId == deskId)
      .toList();
});

class MemberMonthAttendanceSummary {
  const MemberMonthAttendanceSummary({
    required this.present,
    required this.absent,
    required this.total,
    required this.restDays,
  });

  final int present;
  final int absent;
  final int total;
  final int restDays;
}

class MemberDayAttendance {
  const MemberDayAttendance({
    required this.date,
    required this.kind,
  });

  final DateTime date;

  /// present | absent | today | future | rest
  final String kind;
}

class MemberAttendanceDayLog {
  const MemberAttendanceDayLog({
    required this.title,
    required this.subtitle,
    required this.methodLabel,
    required this.completed,
  });

  final String title;
  final String subtitle;
  final String methodLabel;
  final bool completed;
}

final memberMonthAttendanceSummaryProvider =
    Provider.family<MemberMonthAttendanceSummary, DateTime>((ref, visibleMonth) {
  final deskId = ref.watch(memberReceptionIdProvider);
  final log = ref.watch(receptionAttendanceProvider).log.where((e) => e.memberId == deskId);

  final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  var present = 0;
  var absent = 0;
  var rest = 0;

  for (var d = 1; d <= daysInMonth; d++) {
    final dt = DateTime(visibleMonth.year, visibleMonth.month, d);
    final wd = dt.weekday;
    if (wd == DateTime.saturday || wd == DateTime.sunday) {
      rest++;
      continue;
    }
    if (dt.isAfter(today)) continue;

    final hasCheckIn = log.any(
      (e) =>
          e.action == AttendanceAction.checkIn &&
          _sameDate(e.recordedAt, dt),
    );
    if (hasCheckIn) {
      present++;
    } else {
      absent++;
    }
  }

  return MemberMonthAttendanceSummary(
    present: present,
    absent: absent,
    total: present + absent,
    restDays: rest,
  );
});

final memberCalendarDaysProvider =
    Provider.family<List<MemberDayAttendance>, DateTime>((ref, visibleMonth) {
  final deskId = ref.watch(memberReceptionIdProvider);
  final log = ref.watch(receptionAttendanceProvider).log.where((e) => e.memberId == deskId);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final daysInMonth = DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
  final out = <MemberDayAttendance>[];

  for (var d = 1; d <= daysInMonth; d++) {
    final dt = DateTime(visibleMonth.year, visibleMonth.month, d);
    final wd = dt.weekday;
    String kind;

    if (wd == DateTime.saturday || wd == DateTime.sunday) {
      kind = 'rest';
    } else if (_sameDate(dt, today)) {
      final hasIn = log.any(
        (e) => e.action == AttendanceAction.checkIn && _sameDate(e.recordedAt, dt),
      );
      kind = hasIn ? 'present' : 'today';
    } else if (dt.isAfter(today)) {
      kind = 'future';
    } else {
      final hasIn = log.any(
        (e) => e.action == AttendanceAction.checkIn && _sameDate(e.recordedAt, dt),
      );
      kind = hasIn ? 'present' : 'absent';
    }
    out.add(MemberDayAttendance(date: dt, kind: kind));
  }
  return out;
});

final memberFormattedAttendanceLogProvider = Provider<List<MemberAttendanceDayLog>>((ref) {
  final log = ref.watch(memberAttendanceLogProvider);
  if (log.isEmpty) return const [];

  final out = <MemberAttendanceDayLog>[];
  const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  for (final e in log) {
    final dt = e.recordedAt;
    final dayName = weekdays[dt.weekday - 1];
    final title = '${months[dt.month - 1]} ${dt.day}, ${dt.year} — $dayName';
    final action = e.action == AttendanceAction.checkIn ? 'Check-in' : 'Check-out';
    final method = e.method == CheckInMethod.qr ? 'QR Scan' : 'Phone';
    out.add(
      MemberAttendanceDayLog(
        title: title,
        subtitle: '$action: ${e.timeLabel}${e.checkInTimeLabel != null ? ' · In at ${e.checkInTimeLabel}' : ''}',
        methodLabel: method,
        completed: e.action == AttendanceAction.checkOut,
      ),
    );
  }
  return out;
});

/// Recent desk check-ins for home (paired in/out when possible).
final memberRecentCheckInsProvider = Provider<List<MemberAttendanceDayLog>>((ref) {
  final all = ref.watch(memberFormattedAttendanceLogProvider);
  return all.take(5).toList();
});

bool _sameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime mondayOfWeek(DateTime date) =>
    date.subtract(Duration(days: date.weekday - DateTime.monday));

String memberGreetingName(String? fullName) {
  if (fullName == null || fullName.isEmpty) return 'Member';
  return fullName.split(' ').first;
}

String memberInitials(String? fullName) {
  if (fullName == null || fullName.isEmpty) return '?';
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String timeGreeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good Morning';
  if (h < 17) return 'Good Afternoon';
  return 'Good Evening';
}

/// Computed member analytics for dashboard (read-only aggregate).
class MemberWeeklyAnalytics {
  const MemberWeeklyAnalytics({
    required this.attendancePercent,
    required this.monthCheckIns,
    required this.workoutsCompleted,
    required this.workoutsAssigned,
    required this.weeklyCompletion,
  });

  final int attendancePercent;
  final int monthCheckIns;
  final int workoutsCompleted;
  final int workoutsAssigned;
  final List<double> weeklyCompletion;
}

/// Tap-to-log water glasses on diet tab (prototype).
final memberWaterGlassesProvider = StateProvider<int>((ref) => 6);

final memberWeeklyAnalyticsProvider = Provider<MemberWeeklyAnalytics>((ref) {
  final progress = ref.watch(memberProgressProvider);
  final summary = ref.watch(memberMonthAttendanceSummaryProvider(DateTime.now()));
  return MemberWeeklyAnalytics(
    attendancePercent: progress?.attendancePercent ?? 0,
    monthCheckIns: summary.present,
    workoutsCompleted: progress?.workoutsCompleted ?? 0,
    workoutsAssigned: progress?.workoutsAssigned ?? 0,
    weeklyCompletion: progress?.weeklyCompletion ?? const [],
  );
});
