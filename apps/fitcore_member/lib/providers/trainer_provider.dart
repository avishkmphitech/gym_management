import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock/mock_models.dart';
import '../data/mock/trainer_mock_data.dart';

class TrainerNotificationPrefs {
  const TrainerNotificationPrefs({
    this.workoutReminders = true,
    this.sessionReminders = true,
    this.memberCheckInAlerts = false,
  });

  final bool workoutReminders;
  final bool sessionReminders;
  final bool memberCheckInAlerts;

  TrainerNotificationPrefs copyWith({
    bool? workoutReminders,
    bool? sessionReminders,
    bool? memberCheckInAlerts,
  }) {
    return TrainerNotificationPrefs(
      workoutReminders: workoutReminders ?? this.workoutReminders,
      sessionReminders: sessionReminders ?? this.sessionReminders,
      memberCheckInAlerts: memberCheckInAlerts ?? this.memberCheckInAlerts,
    );
  }
}

class TrainerState {
  const TrainerState({
    required this.sessions,
    required this.weeklyWorkoutPlans,
    required this.dietPlans,
    required this.memberWeeklyWorkoutByMemberId,
    required this.memberDietByMemberId,
    required this.progressByMemberId,
    required this.notificationPrefs,
    required this.assignmentHistory,
  });

  final List<MockTrainerSession> sessions;
  final List<MockWeeklyWorkoutPlan> weeklyWorkoutPlans;
  final List<MockMeal> dietPlans;
  final Map<String, String> memberWeeklyWorkoutByMemberId;
  final Map<String, String> memberDietByMemberId;
  final Map<String, MockMemberProgress> progressByMemberId;
  final TrainerNotificationPrefs notificationPrefs;
  final List<MockPlanAssignment> assignmentHistory;

  factory TrainerState.initial() {
    return TrainerState(
      sessions: List<MockTrainerSession>.from(trainerSchedule),
      weeklyWorkoutPlans: List<MockWeeklyWorkoutPlan>.from(trainerWeeklyPlans),
      dietPlans: List<MockMeal>.from(trainerDietOutlines),
      memberWeeklyWorkoutByMemberId: const {'m1': 'ww1', 'm2': 'ww2'},
      memberDietByMemberId: const {'m1': 'd1', 'm2': 'd2'},
      progressByMemberId: Map<String, MockMemberProgress>.from(memberProgressById),
      notificationPrefs: const TrainerNotificationPrefs(),
      assignmentHistory: List<MockPlanAssignment>.from(initialWorkoutAssignments),
    );
  }

  MockAssignedMember? memberById(String id) {
    for (final m in assignedMembers) {
      if (m.id == id) return m;
    }
    return null;
  }

  MockWeeklyWorkoutPlan? weeklyPlanById(String id) {
    for (final p in weeklyWorkoutPlans) {
      if (p.id == id) return p;
    }
    return null;
  }

  MockMeal? dietById(String id) {
    for (final d in dietPlans) {
      if (d.id == id) return d;
    }
    return null;
  }

  MockTrainerSession? sessionById(String id) {
    for (final s in sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  String? weeklyWorkoutLabelForMember(String memberId) {
    final planId = memberWeeklyWorkoutByMemberId[memberId];
    if (planId == null) return null;
    return weeklyPlanById(planId)?.name;
  }

  String? dietLabelForMember(String memberId) {
    final dietId = memberDietByMemberId[memberId];
    if (dietId == null) return null;
    return dietById(dietId)?.title;
  }

  List<MockPlanAssignment> assignmentsForMember(String memberId) =>
      assignmentHistory.where((a) => a.memberId == memberId).toList();

  List<MockTrainerSession> sessionsOnDay(DateTime day) {
    return sessions.where((s) {
      final at = s.scheduledAt;
      if (at == null) return false;
      return at.year == day.year && at.month == day.month && at.day == day.day;
    }).toList();
  }
}

class TrainerNotifier extends StateNotifier<TrainerState> {
  TrainerNotifier() : super(TrainerState.initial());

  TrainerState _copy({
    List<MockTrainerSession>? sessions,
    List<MockWeeklyWorkoutPlan>? weeklyWorkoutPlans,
    List<MockMeal>? dietPlans,
    Map<String, String>? memberWeeklyWorkoutByMemberId,
    Map<String, String>? memberDietByMemberId,
    Map<String, MockMemberProgress>? progressByMemberId,
    TrainerNotificationPrefs? notificationPrefs,
    List<MockPlanAssignment>? assignmentHistory,
  }) {
    return TrainerState(
      sessions: sessions ?? state.sessions,
      weeklyWorkoutPlans: weeklyWorkoutPlans ?? state.weeklyWorkoutPlans,
      dietPlans: dietPlans ?? state.dietPlans,
      memberWeeklyWorkoutByMemberId:
          memberWeeklyWorkoutByMemberId ?? state.memberWeeklyWorkoutByMemberId,
      memberDietByMemberId: memberDietByMemberId ?? state.memberDietByMemberId,
      progressByMemberId: progressByMemberId ?? state.progressByMemberId,
      notificationPrefs: notificationPrefs ?? state.notificationPrefs,
      assignmentHistory: assignmentHistory ?? state.assignmentHistory,
    );
  }

  String _nowLabel() {
    final n = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[n.month - 1]} ${n.day} · ${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
  }

  void addWeeklyWorkoutPlan(MockWeeklyWorkoutPlan plan) {
    state = _copy(weeklyWorkoutPlans: [...state.weeklyWorkoutPlans, plan]);
  }

  void updateWeeklyWorkoutPlan(MockWeeklyWorkoutPlan plan) {
    state = _copy(
      weeklyWorkoutPlans: [
        for (final p in state.weeklyWorkoutPlans)
          if (p.id == plan.id) plan else p,
      ],
    );
  }

  void deleteWeeklyWorkoutPlan(String weekPlanId) {
    state = _copy(
      weeklyWorkoutPlans: [
        for (final p in state.weeklyWorkoutPlans)
          if (p.id != weekPlanId) p,
      ],
      memberWeeklyWorkoutByMemberId: {
        for (final e in state.memberWeeklyWorkoutByMemberId.entries)
          if (e.value != weekPlanId) e.key: e.value,
      },
    );
  }

  void addDietPlan(MockMeal plan) {
    state = _copy(dietPlans: [...state.dietPlans, plan]);
  }

  void updateDietPlan(MockMeal meal) {
    state = _copy(
      dietPlans: [for (final d in state.dietPlans) if (d.id == meal.id) meal else d],
    );
  }

  void assignWeeklyWorkout({required String memberId, required String weekPlanId}) {
    final member = state.memberById(memberId);
    final plan = state.weeklyPlanById(weekPlanId);
    if (member == null || plan == null) return;

    final assignment = MockPlanAssignment(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      memberId: memberId,
      memberName: member.name,
      planId: weekPlanId,
      planName: plan.name,
      type: 'week_workout',
      assignedAtLabel: _nowLabel(),
    );

    final progress = state.progressByMemberId[memberId];
    final updatedProgress = progress != null
        ? MockMemberProgress(
            workoutsCompleted: progress.workoutsCompleted,
            workoutsAssigned: plan.trainingDays,
            attendancePercent: progress.attendancePercent,
            lastWorkoutLabel: '${plan.name} · week assigned',
            weightTrend: progress.weightTrend,
            notes: progress.notes,
            weeklyCompletion: progress.weeklyCompletion,
            attendanceHistory: progress.attendanceHistory,
            workoutHistory: progress.workoutHistory,
            bodyMetrics: progress.bodyMetrics,
          )
        : null;

    state = _copy(
      memberWeeklyWorkoutByMemberId: {...state.memberWeeklyWorkoutByMemberId, memberId: weekPlanId},
      assignmentHistory: [assignment, ...state.assignmentHistory],
      progressByMemberId: updatedProgress != null
          ? {...state.progressByMemberId, memberId: updatedProgress}
          : state.progressByMemberId,
    );
  }

  void assignDiet({required String memberId, required String dietId}) {
    final member = state.memberById(memberId);
    final diet = state.dietById(dietId);
    if (member == null || diet == null) return;

    final assignment = MockPlanAssignment(
      id: 'a_${DateTime.now().millisecondsSinceEpoch}',
      memberId: memberId,
      memberName: member.name,
      planId: dietId,
      planName: diet.title,
      type: 'diet',
      assignedAtLabel: _nowLabel(),
    );

    state = _copy(
      memberDietByMemberId: {...state.memberDietByMemberId, memberId: dietId},
      assignmentHistory: [assignment, ...state.assignmentHistory],
    );
  }

  bool hasScheduleConflict(DateTime start, int durationMin, {String? excludeSessionId}) {
    final end = start.add(Duration(minutes: durationMin));
    for (final s in state.sessions) {
      if (s.id == excludeSessionId || s.scheduledAt == null) continue;
      final sStart = s.scheduledAt!;
      final sEnd = sStart.add(Duration(minutes: s.durationMin));
      if (start.isBefore(sEnd) && end.isAfter(sStart)) return true;
    }
    return false;
  }

  MockTrainerSession? conflictingSession(DateTime start, int durationMin, {String? excludeSessionId}) {
    final end = start.add(Duration(minutes: durationMin));
    for (final s in state.sessions) {
      if (s.id == excludeSessionId || s.scheduledAt == null) continue;
      final sStart = s.scheduledAt!;
      final sEnd = sStart.add(Duration(minutes: s.durationMin));
      if (start.isBefore(sEnd) && end.isAfter(sStart)) return s;
    }
    return null;
  }

  void addSession({
    required String title,
    required String whenLabel,
    required String location,
    DateTime? scheduledAt,
    int durationMin = 60,
  }) {
    final id = 's_${DateTime.now().millisecondsSinceEpoch}';
    state = _copy(
      sessions: [
        ...state.sessions,
        MockTrainerSession(
          id: id,
          title: title,
          whenLabel: whenLabel,
          location: location,
          scheduledAt: scheduledAt,
          durationMin: durationMin,
        ),
      ],
    );
  }

  void updateSession(MockTrainerSession session) {
    state = _copy(
      sessions: [for (final s in state.sessions) if (s.id == session.id) session else s],
    );
  }

  void removeSession(String sessionId) {
    state = _copy(sessions: state.sessions.where((s) => s.id != sessionId).toList());
  }

  void updateNotificationPrefs(TrainerNotificationPrefs prefs) {
    state = _copy(notificationPrefs: prefs);
  }
}

final trainerProvider = StateNotifierProvider<TrainerNotifier, TrainerState>((ref) {
  return TrainerNotifier();
});

final trainerMemberByIdProvider = Provider.family<MockAssignedMember?, String>((ref, id) {
  return ref.watch(trainerProvider).memberById(id);
});
