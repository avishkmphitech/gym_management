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
  ),
  const MockWorkout(
    id: 'tw2',
    name: 'Lower B (hinge + knee)',
    durationMin: 70,
    focus: 'RDL · Squat · Single-leg',
  ),
];

final trainerDietOutlines = [
  const MockMeal(
    id: 'd1',
    title: 'High-protein baseline (member: Aarav)',
    calories: 2150,
    timeLabel: 'Plan',
  ),
  const MockMeal(
    id: 'd2',
    title: 'Vegetarian cut phase (member: Meera)',
    calories: 1650,
    timeLabel: 'Plan',
  ),
];

final trainerSchedule = [
  const MockTrainerSession(
    title: 'PT · Aarav — Leg day',
    whenLabel: 'Tomorrow · 06:30',
    location: 'Floor A · Rack 2',
  ),
  const MockTrainerSession(
    title: 'Small group · Mobility',
    whenLabel: 'Thu · 19:00',
    location: 'Studio 1',
  ),
];

