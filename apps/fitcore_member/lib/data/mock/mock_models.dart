class MockWorkout {
  const MockWorkout({
    required this.id,
    required this.name,
    required this.durationMin,
    required this.focus,
  });
  final String id;
  final String name;
  final int durationMin;
  final String focus;
}

class MockMeal {
  const MockMeal({
    required this.id,
    required this.title,
    required this.calories,
    required this.timeLabel,
  });
  final String id;
  final String title;
  final int calories;
  final String timeLabel;
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
    required this.title,
    required this.whenLabel,
    required this.location,
  });
  final String title;
  final String whenLabel;
  final String location;
}
