import 'mock_models.dart';

final assignedMembers = [
  const MockAssignedMember(
    id: 'm1',
    name: 'Aarav Khanna',
    plan: 'Pro',
    goal: 'Hypertrophy + mobility',
    lastCheckIn: 'Today · 06:10',
  ),
  const MockAssignedMember(
    id: 'm2',
    name: 'Meera Shah',
    plan: 'Yoga + strength',
    goal: 'Fat loss',
    lastCheckIn: 'Yesterday · 18:22',
  ),
  const MockAssignedMember(
    id: 'm3',
    name: 'Dev Malhotra',
    plan: 'Athletic',
    goal: '5K + power',
    lastCheckIn: 'May 9 · 07:05',
  ),
];

final trainerWorkoutTemplates = [
  const MockWorkout(
    id: 'tw1',
    name: 'Upper A (horizontal push/pull)',
    durationMin: 65,
    focus: 'Bench · Rows · Accessories',
    exercises: [
      MockPlanExercise(name: 'Bench Press', sets: 4, reps: 10),
      MockPlanExercise(name: 'Barbell Row', sets: 4, reps: 10),
      MockPlanExercise(name: 'Incline DB Press', sets: 3, reps: 12),
      MockPlanExercise(name: 'Cable Fly', sets: 3, reps: 15, notes: 'Controlled tempo'),
    ],
  ),
  const MockWorkout(
    id: 'tw2',
    name: 'Lower B (hinge + knee)',
    durationMin: 70,
    focus: 'RDL · Squat · Single-leg',
    exercises: [
      MockPlanExercise(name: 'Romanian Deadlift', sets: 4, reps: 8),
      MockPlanExercise(name: 'Back Squat', sets: 4, reps: 6),
      MockPlanExercise(name: 'Bulgarian Split Squat', sets: 3, reps: 10, notes: 'Each leg'),
      MockPlanExercise(name: 'Leg Curl', sets: 3, reps: 12),
    ],
  ),
];

final trainerDietOutlines = [
  MockMeal(
    id: 'd1',
    title: 'High-protein baseline',
    calories: 2150,
    timeLabel: 'Daily plan',
    proteinG: 165,
    carbsG: 210,
    fatsG: 62,
    description: 'Full day with pre/post workout fueling',
    mealSlots: [
      MockDietMealSlot(
        id: 'd1_b',
        type: 'pre_workout',
        title: 'Pre-workout',
        timeLabel: '06:00',
        foods: [
          MockDietFoodItem(name: 'Banana', quantity: '1 medium', calories: 105),
          MockDietFoodItem(name: 'Black coffee', quantity: '1 cup', calories: 5),
        ],
      ),
      MockDietMealSlot(
        id: 'd1_bf',
        type: 'breakfast',
        title: 'Breakfast',
        timeLabel: '07:30',
        foods: [
          MockDietFoodItem(name: 'Oats with banana', quantity: '1 bowl', calories: 380),
          MockDietFoodItem(name: 'Boiled eggs', quantity: '2 pcs', calories: 140),
          MockDietFoodItem(name: 'Protein shake', quantity: '1 scoop', calories: 160),
        ],
      ),
      MockDietMealSlot(
        id: 'd1_l',
        type: 'lunch',
        title: 'Lunch',
        timeLabel: '13:00',
        foods: [
          MockDietFoodItem(name: 'Grilled chicken breast', quantity: '200g', calories: 330),
          MockDietFoodItem(name: 'Brown rice', quantity: '150g', calories: 210),
          MockDietFoodItem(name: 'Salad bowl', quantity: '1 plate', calories: 80),
        ],
      ),
      MockDietMealSlot(
        id: 'd1_s',
        type: 'snack',
        title: 'Evening snack',
        timeLabel: '16:30',
        foods: [
          MockDietFoodItem(name: 'Greek yogurt', quantity: '150g', calories: 130),
          MockDietFoodItem(name: 'Almonds', quantity: '20g', calories: 120),
        ],
      ),
      MockDietMealSlot(
        id: 'd1_pw',
        type: 'post_workout',
        title: 'Post-workout',
        timeLabel: '18:45',
        foods: [
          MockDietFoodItem(name: 'Whey protein shake', quantity: '1 scoop', calories: 120),
        ],
      ),
      MockDietMealSlot(
        id: 'd1_d',
        type: 'dinner',
        title: 'Dinner',
        timeLabel: '20:30',
        foods: [
          MockDietFoodItem(name: 'Paneer bhurji', quantity: '150g', calories: 280),
          MockDietFoodItem(name: 'Dal + 2 roti', quantity: '—', calories: 320),
        ],
      ),
    ],
  ),
  MockMeal(
    id: 'd2',
    title: 'Vegetarian cut phase',
    calories: 1650,
    timeLabel: 'Daily plan',
    proteinG: 120,
    carbsG: 155,
    fatsG: 48,
    description: 'Plant-forward deficit plan',
    mealSlots: [
      const MockDietMealSlot(
        id: 'd2_bf',
        type: 'breakfast',
        title: 'Breakfast',
        timeLabel: '08:00',
        foods: [
          MockDietFoodItem(name: 'Poha with peanuts', quantity: '1 plate', calories: 320),
          MockDietFoodItem(name: 'Green tea', quantity: '1 cup', calories: 0),
        ],
      ),
      const MockDietMealSlot(
        id: 'd2_l',
        type: 'lunch',
        title: 'Lunch',
        timeLabel: '13:30',
        foods: [
          MockDietFoodItem(name: 'Dal khichdi', quantity: '1 bowl', calories: 420),
          MockDietFoodItem(name: 'Cucumber salad', quantity: '1 bowl', calories: 40),
        ],
      ),
      const MockDietMealSlot(
        id: 'd2_s',
        type: 'snack',
        title: 'Mid-afternoon',
        timeLabel: '16:00',
        foods: [
          MockDietFoodItem(name: 'Fruit bowl', quantity: '1 cup', calories: 90),
        ],
      ),
      const MockDietMealSlot(
        id: 'd2_d',
        type: 'dinner',
        title: 'Dinner',
        timeLabel: '19:30',
        foods: [
          MockDietFoodItem(name: 'Tofu stir-fry', quantity: '200g', calories: 280),
          MockDietFoodItem(name: 'Quinoa', quantity: '100g', calories: 180),
        ],
      ),
    ],
  ),
];

MockWeeklyDayPlan _day(
  int index,
  String label, {
  bool rest = false,
  String? title,
  String? focus,
  int duration = 0,
  List<MockPlanExercise> exercises = const [],
}) {
  return MockWeeklyDayPlan(
    dayIndex: index,
    dayLabel: label,
    isRestDay: rest,
    title: title,
    focus: focus,
    durationMin: duration,
    exercises: exercises,
  );
}

final trainerWeeklyPlans = [
  MockWeeklyWorkoutPlan(
    id: 'ww1',
    name: 'Hypertrophy · 4-day split',
    goalFocus: 'Build muscle · 4 training days',
    days: [
      _day(0, 'Mon', title: 'Upper A', focus: 'Push emphasis', duration: 65, exercises: trainerWorkoutTemplates[0].exercises),
      _day(1, 'Tue', rest: true),
      _day(2, 'Wed', title: 'Lower B', focus: 'Legs + hinge', duration: 70, exercises: trainerWorkoutTemplates[1].exercises),
      _day(3, 'Thu', rest: true),
      _day(4, 'Fri', title: 'Upper B', focus: 'Pull + arms', duration: 60, exercises: const [
        MockPlanExercise(name: 'Pull-ups', sets: 4, reps: 8),
        MockPlanExercise(name: 'Lat Pulldown', sets: 3, reps: 12),
        MockPlanExercise(name: 'Face pulls', sets: 3, reps: 15),
      ]),
      _day(5, 'Sat', title: 'Active recovery', focus: 'Mobility · 30 min', duration: 30, exercises: const [
        MockPlanExercise(name: 'Foam roll + stretch', sets: 1, reps: 1, notes: 'Full body'),
      ]),
      _day(6, 'Sun', rest: true),
    ],
  ),
  MockWeeklyWorkoutPlan(
    id: 'ww2',
    name: 'Athletic · 3-day',
    goalFocus: 'Strength + conditioning',
    days: [
      _day(0, 'Mon', title: 'Strength', focus: 'Compound lifts', duration: 55, exercises: const [
        MockPlanExercise(name: 'Trap bar deadlift', sets: 5, reps: 5),
        MockPlanExercise(name: 'Push press', sets: 4, reps: 6),
      ]),
      _day(1, 'Tue', rest: true),
      _day(2, 'Wed', title: 'Conditioning', focus: 'Intervals', duration: 40, exercises: const [
        MockPlanExercise(name: 'Row erg intervals', sets: 6, reps: 2, notes: '2 min on / 1 off'),
      ]),
      _day(3, 'Thu', rest: true),
      _day(4, 'Fri', title: 'Full body', focus: 'Mixed', duration: 50, exercises: const [
        MockPlanExercise(name: 'Goblet squat', sets: 4, reps: 10),
        MockPlanExercise(name: 'DB bench', sets: 4, reps: 10),
      ]),
      _day(5, 'Sat', rest: true),
      _day(6, 'Sun', rest: true),
    ],
  ),
];

DateTime _daysFromNow(int days, {int hour = 9, int minute = 0}) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + days, hour, minute);
}

final trainerSchedule = [
  MockTrainerSession(
    id: 's1',
    title: 'PT · Aarav — Leg day',
    whenLabel: 'Tomorrow · 06:30',
    location: 'Floor A · Rack 2',
    scheduledAt: _daysFromNow(1, hour: 6, minute: 30),
    durationMin: 60,
  ),
  MockTrainerSession(
    id: 's2',
    title: 'Small group · Mobility',
    whenLabel: 'Thu · 19:00',
    location: 'Studio 1',
    scheduledAt: _daysFromNow(3, hour: 19, minute: 0),
    durationMin: 45,
  ),
];

final initialWorkoutAssignments = [
  const MockPlanAssignment(
    id: 'a1',
    memberId: 'm1',
    memberName: 'Aarav Khanna',
    planId: 'ww1',
    planName: 'Hypertrophy · 4-day split',
    type: 'week_workout',
    assignedAtLabel: 'May 12 · 10:20',
  ),
  const MockPlanAssignment(
    id: 'a2',
    memberId: 'm2',
    memberName: 'Meera Shah',
    planId: 'ww2',
    planName: 'Athletic · 3-day',
    type: 'week_workout',
    assignedAtLabel: 'May 10 · 14:05',
  ),
];

final memberProgressById = <String, MockMemberProgress>{
  'm1': MockMemberProgress(
    workoutsCompleted: 12,
    workoutsAssigned: 16,
    attendancePercent: 88,
    lastWorkoutLabel: 'Upper A · May 17',
    weightTrend: '+1.2 kg (lean mass)',
    notes: const ['Shoulder mobility improving', 'Increase bench volume next week'],
    weeklyCompletion: const [72, 80, 65, 90, 85, 88, 92],
    attendanceHistory: const [
      MockAttendanceEntry(dateLabel: 'May 18', checkedIn: true, window: '06:02 – 07:15'),
      MockAttendanceEntry(dateLabel: 'May 17', checkedIn: true, window: '06:10 – 07:20'),
      MockAttendanceEntry(dateLabel: 'May 16', checkedIn: false, window: 'Missed'),
      MockAttendanceEntry(dateLabel: 'May 15', checkedIn: true, window: '17:45 – 19:00'),
    ],
    workoutHistory: const [
      MockWorkoutCompletion(dateLabel: 'May 17', planName: 'Upper A', completed: true),
      MockWorkoutCompletion(dateLabel: 'May 15', planName: 'Lower B', completed: true),
      MockWorkoutCompletion(dateLabel: 'May 13', planName: 'Upper A', completed: false),
    ],
    bodyMetrics: const MockBodyMetrics(
      weightKg: 78.4,
      bodyFatPercent: 14.2,
      muscleMassKg: 34.8,
      updatedLabel: 'May 17',
    ),
  ),
  'm2': MockMemberProgress(
    workoutsCompleted: 9,
    workoutsAssigned: 14,
    attendancePercent: 76,
    lastWorkoutLabel: 'Yoga flow · May 16',
    weightTrend: '-0.8 kg',
    notes: const ['Stay on caloric deficit', 'Add one LISS session'],
    weeklyCompletion: const [60, 55, 70, 68, 72, 76, 74],
    attendanceHistory: const [
      MockAttendanceEntry(dateLabel: 'May 17', checkedIn: true, window: '18:22 – 19:30'),
      MockAttendanceEntry(dateLabel: 'May 16', checkedIn: true, window: '07:00 – 08:10'),
      MockAttendanceEntry(dateLabel: 'May 14', checkedIn: false, window: 'Missed'),
    ],
    workoutHistory: const [
      MockWorkoutCompletion(dateLabel: 'May 16', planName: 'Yoga flow', completed: true),
      MockWorkoutCompletion(dateLabel: 'May 14', planName: 'Lower B', completed: false),
    ],
    bodyMetrics: const MockBodyMetrics(
      weightKg: 62.1,
      bodyFatPercent: 22.5,
      muscleMassKg: 26.2,
      updatedLabel: 'May 16',
    ),
  ),
  'm3': MockMemberProgress(
    workoutsCompleted: 15,
    workoutsAssigned: 18,
    attendancePercent: 92,
    lastWorkoutLabel: 'Lower B · May 18',
    weightTrend: 'Stable',
    notes: const ['5K pace on track', 'Deload week in 2 sessions'],
    weeklyCompletion: const [88, 90, 85, 92, 94, 91, 95],
    attendanceHistory: const [
      MockAttendanceEntry(dateLabel: 'May 18', checkedIn: true, window: '06:55 – 08:05'),
      MockAttendanceEntry(dateLabel: 'May 17', checkedIn: true, window: '06:40 – 07:50'),
      MockAttendanceEntry(dateLabel: 'May 16', checkedIn: true, window: '18:10 – 19:25'),
    ],
    workoutHistory: const [
      MockWorkoutCompletion(dateLabel: 'May 18', planName: 'Lower B', completed: true),
      MockWorkoutCompletion(dateLabel: 'May 16', planName: 'Upper A', completed: true),
    ],
    bodyMetrics: const MockBodyMetrics(
      weightKg: 71.0,
      bodyFatPercent: 12.8,
      muscleMassKg: 32.1,
      updatedLabel: 'May 18',
    ),
  ),
};
