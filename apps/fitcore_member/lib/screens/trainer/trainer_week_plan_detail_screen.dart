import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/diet_meal_types.dart';
import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../data/mock/mock_models.dart';
import '../../providers/trainer_provider.dart';
import '../../widgets/trainer_permission_gate.dart';

/// View 7-day workout program and assign to member.
class TrainerWeekPlanDetailScreen extends ConsumerStatefulWidget {
  const TrainerWeekPlanDetailScreen({super.key, required this.weekPlanId});

  final String weekPlanId;

  @override
  ConsumerState<TrainerWeekPlanDetailScreen> createState() => _TrainerWeekPlanDetailScreenState();
}

class _TrainerWeekPlanDetailScreenState extends ConsumerState<TrainerWeekPlanDetailScreen> {
  int _selectedDayIndex = 0;

  Future<void> _deletePlan(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete week plan?'),
        content: const Text('This removes the program from your library.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    ref.read(trainerProvider.notifier).deleteWeeklyWorkoutPlan(widget.weekPlanId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Week plan deleted'), backgroundColor: AppColors.success),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(trainerProvider).weeklyPlanById(widget.weekPlanId);

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Week plan')),
        body: const Center(child: Text('Plan not found.')),
      );
    }

    final selectedDay = plan.days[_selectedDayIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Week plan'),
        actions: [
          TrainerPermissionGate(
            permission: 'plans:write',
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/trainer/plans/week/${widget.weekPlanId}/edit'),
            ),
          ),
          TrainerPermissionGate(
            permission: 'plans:write',
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deletePlan(context, ref),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FitCoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(plan.goalFocus, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  '${plan.trainingDays} training days / week',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Weekly schedule', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final day = plan.days[i];
                final selected = _selectedDayIndex == i;
                return _DetailDayChip(
                  label: day.dayLabel,
                  selected: selected,
                  isRest: day.isRestDay,
                  hasExercises: day.exercises.isNotEmpty,
                  onTap: () => setState(() => _selectedDayIndex = i),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          _DayExercisePanel(day: selectedDay),
          const SizedBox(height: 16),
          Text('All days', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...plan.days.map((day) {
            final selected = day.dayIndex == _selectedDayIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _selectedDayIndex = day.dayIndex),
                  borderRadius: BorderRadius.circular(12),
                  child: _DayListRow(day: day, selected: selected),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          TrainerPermissionGate(
            permission: 'plans:write',
            child: FitCoreButton(
              label: 'Assign week plan to member',
              icon: Icons.person_add_outlined,
              onPressed: () => context.push('/trainer/plans/week/assign?weekPlanId=${widget.weekPlanId}'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailDayChip extends StatelessWidget {
  const _DetailDayChip({
    required this.label,
    required this.selected,
    required this.isRest,
    required this.hasExercises,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isRest;
  final bool hasExercises;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primaryAccent
        : (!isRest && hasExercises)
            ? AppColors.primaryAccent.withValues(alpha: 0.2)
            : AppColors.cardBg;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primaryAccent : AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              isRest ? Icons.hotel_outlined : Icons.fitness_center,
              size: 16,
              color: selected ? Colors.white : AppColors.secondaryText,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayExercisePanel extends StatelessWidget {
  const _DayExercisePanel({required this.day});

  final MockWeeklyDayPlan day;

  @override
  Widget build(BuildContext context) {
    return FitCoreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(WeekdayLabels.full[day.dayIndex], style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          if (day.isRestDay)
            Text('Rest day', style: Theme.of(context).textTheme.bodyMedium)
          else ...[
            Text(day.title ?? 'Workout', style: Theme.of(context).textTheme.bodyLarge),
            if (day.focus != null) Text(day.focus!, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 10),
            if (day.exercises.isEmpty)
              Text('No exercises', style: Theme.of(context).textTheme.bodySmall)
            else
              ...day.exercises.map(
                (ex) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 16, color: AppColors.primaryAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${ex.name} — ${ex.sets}×${ex.reps}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DayListRow extends StatelessWidget {
  const _DayListRow({required this.day, required this.selected});

  final MockWeeklyDayPlan day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryAccent.withValues(alpha: 0.12) : AppColors.secondaryBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.primaryAccent : AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                WeekdayLabels.full[day.dayIndex],
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: selected ? AppColors.primaryAccent : null,
                    ),
              ),
              const Spacer(),
              Text(
                day.isRestDay ? 'Rest' : (day.title ?? 'Workout'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (!day.isRestDay && day.exercises.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...day.exercises.map(
              (ex) => Text(
                '• ${ex.name} — ${ex.sets}×${ex.reps}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
