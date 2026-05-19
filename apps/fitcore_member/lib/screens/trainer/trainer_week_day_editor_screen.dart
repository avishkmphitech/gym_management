import 'package:flutter/material.dart';

import '../../core/constants/diet_meal_types.dart';
import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import 'week_plan_draft.dart';

/// Full-screen editor for a single day in a weekly workout program.
class TrainerWeekDayEditorScreen extends StatefulWidget {
  const TrainerWeekDayEditorScreen({super.key, required this.day});

  final WeekPlanDayDraft day;

  @override
  State<TrainerWeekDayEditorScreen> createState() => _TrainerWeekDayEditorScreenState();
}

class _TrainerWeekDayEditorScreenState extends State<TrainerWeekDayEditorScreen> {
  WeekPlanDayDraft get day => widget.day;

  @override
  Widget build(BuildContext context) {
    final fullName = WeekdayLabels.full[day.dayIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(fullName),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Done', style: TextStyle(color: AppColors.primaryAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FitCoreCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('$fullName — Rest day', style: Theme.of(context).textTheme.titleMedium),
              subtitle: const Text('No workout scheduled'),
              value: day.isRest,
              activeThumbColor: AppColors.primaryAccent,
              onChanged: (v) => setState(() {
                day.isRest = v;
                if (!v && day.exercises.isEmpty) {
                  day.exercises.add(WeekPlanExerciseDraft());
                }
              }),
            ),
          ),
          if (!day.isRest) ...[
            const SizedBox(height: 20),
            Text('Session', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            TextField(
              controller: day.titleController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Workout title',
                hintText: 'e.g. Upper body strength',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: day.focusController,
              decoration: const InputDecoration(
                labelText: 'Focus area',
                hintText: 'e.g. Chest · Back · Arms',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: day.durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('Exercises', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => setState(() => day.exercises.add(WeekPlanExerciseDraft())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add exercise'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (day.exercises.isEmpty)
              FitCoreCard(
                child: Text(
                  'No exercises yet. Tap Add exercise to build this day.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ...day.exercises.asMap().entries.map((entry) {
                final i = entry.key;
                final ex = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FitCoreCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Exercise ${i + 1}', style: Theme.of(context).textTheme.titleSmall),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              tooltip: 'Delete exercise',
                              onPressed: () => setState(() {
                                ex.dispose();
                                day.exercises.removeAt(i);
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: ex.nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(labelText: 'Exercise name'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: ex.setsController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Sets'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: ex.repsController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Reps'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: ex.notesController,
                          decoration: const InputDecoration(labelText: 'Notes (optional)'),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
          const SizedBox(height: 28),
          FitCoreButton(
            label: 'Save $fullName',
            onPressed: () {
              if (!day.isRest && day.titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a workout title or mark as rest day.')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }
}
