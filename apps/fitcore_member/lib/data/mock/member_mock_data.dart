import 'mock_models.dart';

final memberWorkouts = [
  const MockWorkout(
    id: 'w1',
    name: 'Push + Core',
    durationMin: 55,
    focus: 'Chest · Triceps · Abs',
  ),
  const MockWorkout(
    id: 'w2',
    name: 'Lower Strength',
    durationMin: 60,
    focus: 'Quads · Hamstrings · Glutes',
  ),
  const MockWorkout(
    id: 'w3',
    name: 'Conditioning',
    durationMin: 35,
    focus: 'Intervals · Mobility',
  ),
];

final memberMeals = [
  const MockMeal(
    id: 'm1',
    title: 'Greek yogurt, berries, granola',
    calories: 420,
    timeLabel: 'Breakfast',
  ),
  const MockMeal(
    id: 'm2',
    title: 'Grilled chicken bowl + greens',
    calories: 640,
    timeLabel: 'Lunch',
  ),
  const MockMeal(
    id: 'm3',
    title: 'Salmon, rice, roasted veg',
    calories: 710,
    timeLabel: 'Dinner',
  ),
];

final memberAttendance = [
  const MockAttendance(
    dateLabel: 'Mon, May 12',
    checkedIn: true,
    window: '06:10 – 06:42',
  ),
  const MockAttendance(
    dateLabel: 'Sun, May 11',
    checkedIn: true,
    window: '10:02 – 11:15',
  ),
  const MockAttendance(
    dateLabel: 'Fri, May 9',
    checkedIn: false,
    window: '—',
  ),
];

final memberPayments = [
  const MockPayment(
    id: 'p1',
    label: 'Pro Membership',
    amount: '₹2,499',
    status: 'Paid',
    dueLabel: 'Renews Jun 12',
  ),
  const MockPayment(
    id: 'p2',
    label: 'Personal Training Pack',
    amount: '₹8,999',
    status: 'Due',
    dueLabel: 'Due May 18',
  ),
];
