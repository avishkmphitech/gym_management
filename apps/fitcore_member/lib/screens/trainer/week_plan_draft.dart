import 'package:flutter/material.dart';

import '../../core/constants/diet_meal_types.dart';
import '../../data/mock/mock_models.dart';

/// Draft exercise row for week-plan editors.
class WeekPlanExerciseDraft {
  WeekPlanExerciseDraft({MockPlanExercise? from}) {
    nameController = TextEditingController(text: from?.name ?? '');
    setsController = TextEditingController(text: '${from?.sets ?? 3}');
    repsController = TextEditingController(text: '${from?.reps ?? 10}');
    notesController = TextEditingController(text: from?.notes ?? '');
  }

  late final TextEditingController nameController;
  late final TextEditingController setsController;
  late final TextEditingController repsController;
  late final TextEditingController notesController;

  void dispose() {
    nameController.dispose();
    setsController.dispose();
    repsController.dispose();
    notesController.dispose();
  }

  MockPlanExercise? toExercise() {
    final name = nameController.text.trim();
    final sets = int.tryParse(setsController.text.trim());
    final reps = int.tryParse(repsController.text.trim());
    if (name.isEmpty || sets == null || reps == null) return null;
    final notes = notesController.text.trim();
    return MockPlanExercise(
      name: name,
      sets: sets,
      reps: reps,
      notes: notes.isEmpty ? null : notes,
    );
  }
}

/// Draft for one day in a weekly program.
class WeekPlanDayDraft {
  WeekPlanDayDraft({required this.dayIndex, required this.dayLabel, MockWeeklyDayPlan? from})
      : isRest = from?.isRestDay ?? true,
        titleController = TextEditingController(text: from?.title ?? ''),
        focusController = TextEditingController(text: from?.focus ?? ''),
        durationController = TextEditingController(text: '${from?.durationMin ?? 60}'),
        exercises = [for (final e in from?.exercises ?? <MockPlanExercise>[]) WeekPlanExerciseDraft(from: e)];

  final int dayIndex;
  final String dayLabel;
  bool isRest;
  final TextEditingController titleController;
  final TextEditingController focusController;
  final TextEditingController durationController;
  final List<WeekPlanExerciseDraft> exercises;

  void dispose() {
    titleController.dispose();
    focusController.dispose();
    durationController.dispose();
    for (final e in exercises) {
      e.dispose();
    }
  }

  String get summaryLabel {
    if (isRest) return 'Rest';
    if (titleController.text.trim().isNotEmpty) return titleController.text.trim();
    if (exercises.isNotEmpty) return '${exercises.length} exercises';
    return 'Tap to plan';
  }

  bool get isConfigured => isRest || titleController.text.trim().isNotEmpty;

  /// Exercises with valid name, sets, and reps for display in the day preview.
  List<MockPlanExercise> get validExercises {
    return [
      for (final d in exercises)
        if (d.toExercise() != null) d.toExercise()!,
    ];
  }

  void clearWorkout() {
    isRest = true;
    titleController.clear();
    focusController.clear();
    durationController.text = '60';
    for (final e in exercises) {
      e.dispose();
    }
    exercises.clear();
  }

  MockWeeklyDayPlan? toDayPlan() {
    if (isRest) {
      return MockWeeklyDayPlan(dayIndex: dayIndex, dayLabel: dayLabel, isRestDay: true);
    }
    final title = titleController.text.trim();
    final focus = focusController.text.trim();
    final duration = int.tryParse(durationController.text.trim()) ?? 60;
    final ex = <MockPlanExercise>[];
    for (final d in exercises) {
      final parsed = d.toExercise();
      if (parsed != null) ex.add(parsed);
    }
    if (title.isEmpty) return null;
    return MockWeeklyDayPlan(
      dayIndex: dayIndex,
      dayLabel: dayLabel,
      title: title,
      focus: focus.isEmpty ? null : focus,
      durationMin: duration,
      exercises: ex,
    );
  }
}

/// Builds default Mon–Sun drafts.
List<WeekPlanDayDraft> createEmptyWeekDays() {
  return List.generate(
    7,
    (i) => WeekPlanDayDraft(dayIndex: i, dayLabel: WeekdayLabels.names[i]),
  );
}
