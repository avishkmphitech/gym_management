import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/diet_meal_types.dart';
import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../providers/trainer_provider.dart';
import '../../widgets/trainer_member_progress_panel.dart';

/// Assigned member profile with full progress tracking and plan actions.
class TrainerMemberDetailScreen extends ConsumerWidget {
  const TrainerMemberDetailScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trainer = ref.watch(trainerProvider);
    final member = trainer.memberById(memberId);

    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Member')),
        body: const Center(child: Text('Member not found.')),
      );
    }

    final progress = trainer.progressByMemberId[memberId];
    final weekPlanId = trainer.memberWeeklyWorkoutByMemberId[memberId];
    final weekPlan = weekPlanId != null ? trainer.weeklyPlanById(weekPlanId) : null;
    final weekPlanLabel = trainer.weeklyWorkoutLabelForMember(memberId);
    final hasWeekPlan = weekPlanId != null;

    final dietPlanId = trainer.memberDietByMemberId[memberId];
    final dietPlan = dietPlanId != null ? trainer.dietById(dietPlanId) : null;
    final dietLabel = trainer.dietLabelForMember(memberId);
    final hasMealPlan = dietPlanId != null;

    final assignments = trainer.assignmentsForMember(memberId);

    return Scaffold(
      appBar: AppBar(title: Text(member.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          FitCoreCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(_initials(member.name)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: Theme.of(context).textTheme.titleLarge),
                      Text(
                        '${member.plan} · ${member.goal}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(member.lastCheckIn, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 20),
            TrainerMemberProgressPanel(progress: progress),
          ],
          const SizedBox(height: 16),
          Text('Assigned plans', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          Text(
            'Assign a new plan or switch to a different program anytime.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          FitCoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AssignedPlanBlock(
                  icon: Icons.calendar_view_week_outlined,
                  label: 'Week workout',
                  value: weekPlanLabel ?? 'Not assigned',
                  detail: weekPlan != null
                      ? '${weekPlan.trainingDays} training days this week'
                      : 'No week plan assigned yet.',
                  isAssigned: hasWeekPlan,
                  assignLabel: hasWeekPlan ? 'Change week plan' : 'Assign week plan',
                  onAssign: () {
                    final path = hasWeekPlan
                        ? '/trainer/plans/week/assign?memberId=$memberId&weekPlanId=$weekPlanId'
                        : '/trainer/plans/week/assign?memberId=$memberId';
                    context.push(path);
                  },
                ),
                const Divider(height: 28),
                _AssignedPlanBlock(
                  icon: Icons.restaurant_outlined,
                  label: 'Meal plan',
                  value: dietLabel ?? 'Not assigned',
                  detail: dietPlan != null && dietPlan.mealSlots.isNotEmpty
                      ? '${dietPlan.mealSlots.length} meals · ${dietPlan.computedCalories} kcal'
                      : 'No meal plan assigned yet.',
                  isAssigned: hasMealPlan,
                  assignLabel: hasMealPlan ? 'Change meal plan' : 'Assign meal plan',
                  onAssign: () {
                    final path = hasMealPlan
                        ? '/trainer/plans/diet/assign?memberId=$memberId&dietId=$dietPlanId'
                        : '/trainer/plans/diet/assign?memberId=$memberId';
                    context.push(path);
                  },
                ),
              ],
            ),
          ),
          if (weekPlan != null) ...[
            const SizedBox(height: 16),
            Text('This week\'s workouts', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            FitCoreCard(
              child: Column(
                children: weekPlan.days.map((day) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(day.dayLabel, style: Theme.of(context).textTheme.bodySmall),
                        ),
                        Expanded(
                          child: Text(
                            day.isRestDay ? 'Rest' : (day.title ?? 'Workout'),
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!day.isRestDay)
                          Text('${day.durationMin}m', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (dietPlan != null && dietPlan.mealSlots.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Daily meal schedule', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            FitCoreCard(
              child: Column(
                children: dietPlan.mealSlots.map((slot) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DietMealTypes.emoji(slot.type)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${slot.timeLabel} · ${slot.title}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                slot.foods.map((f) => f.name).join(', '),
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text('${slot.totalCalories}', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (assignments.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Assignment log', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            FitCoreCard(
              child: Column(
                children: [
                  for (var i = 0; i < assignments.take(5).length; i++) ...[
                    if (i > 0) const Divider(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        assignments[i].type == 'week_workout'
                            ? Icons.fitness_center_outlined
                            : Icons.restaurant_outlined,
                      ),
                      title: Text(assignments[i].planName),
                      subtitle: Text(assignments[i].assignedAtLabel),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String name) =>
      name.split(' ').where((p) => p.isNotEmpty).map((e) => e[0]).take(2).join();
}

/// One assigned plan row with assign or change/switch action.
class _AssignedPlanBlock extends StatelessWidget {
  const _AssignedPlanBlock({
    required this.icon,
    required this.label,
    required this.value,
    required this.isAssigned,
    required this.assignLabel,
    required this.onAssign,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;
  final bool isAssigned;
  final String assignLabel;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: AppColors.primaryText),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label, style: Theme.of(context).textTheme.bodySmall),
                      if (isAssigned) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Active',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontSize: 11,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (detail != null) ...[
          const SizedBox(height: 6),
          Text(
            detail!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isAssigned ? AppColors.primaryAccent : AppColors.secondaryText,
                ),
          ),
        ],
        const SizedBox(height: 12),
        FitCoreButton(
          label: assignLabel,
          variant: isAssigned ? FitCoreButtonVariant.secondary : FitCoreButtonVariant.primary,
          icon: isAssigned ? Icons.swap_horiz : Icons.add,
          onPressed: onAssign,
        ),
      ],
    );
  }
}
