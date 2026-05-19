class MockPlanExercise {
  const MockPlanExercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.notes,
  });

  final String name;
  final int sets;
  final int reps;
  final String? notes;
}

class MockWorkout {
  const MockWorkout({
    required this.id,
    required this.name,
    required this.durationMin,
    required this.focus,
    this.exercises = const [],
  });
  final String id;
  final String name;
  final int durationMin;
  final String focus;
  final List<MockPlanExercise> exercises;
}

/// Food item inside a timed meal slot (breakfast, lunch, etc.).
class MockDietFoodItem {
  const MockDietFoodItem({
    required this.name,
    required this.quantity,
    required this.calories,
    this.notes,
  });

  final String name;
  final String quantity;
  final int calories;
  final String? notes;
}

/// A timed eating occasion in a daily diet plan.
class MockDietMealSlot {
  const MockDietMealSlot({
    required this.id,
    required this.type,
    required this.title,
    required this.timeLabel,
    required this.foods,
  });

  /// breakfast | lunch | dinner | snack | pre_workout | post_workout
  final String id;
  final String type;
  final String title;
  final String timeLabel;
  final List<MockDietFoodItem> foods;

  int get totalCalories => foods.fold(0, (sum, f) => sum + f.calories);
}

class MockMeal {
  const MockMeal({
    required this.id,
    required this.title,
    required this.calories,
    required this.timeLabel,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatsG = 0,
    this.description = '',
    this.mealSlots = const [],
  });
  final String id;
  final String title;
  final int calories;
  final String timeLabel;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final String description;

  /// Full day schedule: breakfast, lunch, dinner, snacks, pre/post workout.
  final List<MockDietMealSlot> mealSlots;

  int get computedCalories =>
      mealSlots.isEmpty ? calories : mealSlots.fold(0, (s, m) => s + m.totalCalories);
}

/// One day in a 7-day workout program.
class MockWeeklyDayPlan {
  const MockWeeklyDayPlan({
    required this.dayIndex,
    required this.dayLabel,
    this.isRestDay = false,
    this.title,
    this.focus,
    this.durationMin = 0,
    this.exercises = const [],
  });

  /// 0 = Monday … 6 = Sunday
  final int dayIndex;
  final String dayLabel;
  final bool isRestDay;
  final String? title;
  final String? focus;
  final int durationMin;
  final List<MockPlanExercise> exercises;
}

/// 7-day workout plan assignable to a member.
class MockWeeklyWorkoutPlan {
  const MockWeeklyWorkoutPlan({
    required this.id,
    required this.name,
    required this.goalFocus,
    required this.days,
  });

  final String id;
  final String name;
  final String goalFocus;
  final List<MockWeeklyDayPlan> days;

  int get trainingDays => days.where((d) => !d.isRestDay).length;
}

class MockAttendance {
  const MockAttendance({
    required this.dateLabel,
    required this.checkedIn,
    required this.window,
  });
  final String dateLabel;
  final bool checkedIn;
  final String window;
}

class MockPayment {
  const MockPayment({
    required this.id,
    required this.label,
    required this.amount,
    required this.status,
    required this.dueLabel,
  });
  final String id;
  final String label;
  final String amount;
  final String status;
  final String dueLabel;
}

class MockAssignedMember {
  const MockAssignedMember({
    required this.id,
    required this.name,
    required this.plan,
    required this.goal,
    required this.lastCheckIn,
  });
  final String id;
  final String name;
  final String plan;
  final String goal;
  final String lastCheckIn;
}

class MockTrainerSession {
  const MockTrainerSession({
    required this.id,
    required this.title,
    required this.whenLabel,
    required this.location,
    this.scheduledAt,
    this.durationMin = 60,
  });
  final String id;
  final String title;
  final String whenLabel;
  final String location;
  final DateTime? scheduledAt;
  final int durationMin;
}

/// Record of a plan assigned to a member by the trainer.
class MockPlanAssignment {
  const MockPlanAssignment({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.planId,
    required this.planName,
    required this.type,
    required this.assignedAtLabel,
  });

  final String id;
  final String memberId;
  final String memberName;
  final String planId;
  final String planName;

  /// `workout` or `diet`
  final String type;
  final String assignedAtLabel;
}

class MockAttendanceEntry {
  const MockAttendanceEntry({
    required this.dateLabel,
    required this.checkedIn,
    required this.window,
  });

  final String dateLabel;
  final bool checkedIn;
  final String window;
}

class MockWorkoutCompletion {
  const MockWorkoutCompletion({
    required this.dateLabel,
    required this.planName,
    required this.completed,
  });

  final String dateLabel;
  final String planName;
  final bool completed;
}

class MockBodyMetrics {
  const MockBodyMetrics({
    required this.weightKg,
    required this.bodyFatPercent,
    required this.muscleMassKg,
    required this.updatedLabel,
  });

  final double weightKg;
  final double bodyFatPercent;
  final double muscleMassKg;
  final String updatedLabel;
}

/// Trainer view of assigned member progress (mock).
class MockMemberProgress {
  const MockMemberProgress({
    required this.workoutsCompleted,
    required this.workoutsAssigned,
    required this.attendancePercent,
    required this.lastWorkoutLabel,
    required this.weightTrend,
    this.notes = const [],
    this.weeklyCompletion = const [],
    this.attendanceHistory = const [],
    this.workoutHistory = const [],
    this.bodyMetrics,
  });

  final int workoutsCompleted;
  final int workoutsAssigned;
  final int attendancePercent;
  final String lastWorkoutLabel;
  final String weightTrend;
  final List<String> notes;
  final List<double> weeklyCompletion;
  final List<MockAttendanceEntry> attendanceHistory;
  final List<MockWorkoutCompletion> workoutHistory;
  final MockBodyMetrics? bodyMetrics;
}
