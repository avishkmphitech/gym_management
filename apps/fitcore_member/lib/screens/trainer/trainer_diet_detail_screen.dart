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

/// View full daily diet schedule and assign to member.
class TrainerDietDetailScreen extends ConsumerWidget {
  const TrainerDietDetailScreen({super.key, required this.dietId});

  final String dietId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diet = ref.watch(trainerProvider).dietById(dietId);

    if (diet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diet plan')),
        body: const Center(child: Text('Plan not found.')),
      );
    }

    final slots = [...diet.mealSlots]..sort((a, b) => a.timeLabel.compareTo(b.timeLabel));
    final totalCal = diet.computedCalories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet plan'),
        actions: [
          TrainerPermissionGate(
            permission: 'diet:write',
            child: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push('/trainer/plans/diet/$dietId/edit'),
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
                Text(diet.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text('$totalCal kcal / day · ${slots.length} eating occasions', style: Theme.of(context).textTheme.bodyMedium),
                if (diet.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(diet.description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Daily schedule', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          if (slots.isEmpty)
            FitCoreCard(
              child: Text(
                'No meals defined. Edit plan to add breakfast, lunch, dinner, snacks, and pre/post workout.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...slots.map((slot) => _MealTimelineCard(slot: slot)),
          const SizedBox(height: 24),
          TrainerPermissionGate(
            permission: 'diet:write',
            child: FitCoreButton(
              label: 'Assign meal plan to member',
              icon: Icons.person_add_outlined,
              onPressed: () => context.push('/trainer/plans/assign-diet?dietId=$dietId'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTimelineCard extends StatelessWidget {
  const _MealTimelineCard({required this.slot});

  final MockDietMealSlot slot;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FitCoreCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(DietMealTypes.emoji(slot.type), style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slot.title, style: Theme.of(context).textTheme.titleSmall),
                      Text('${slot.timeLabel} · ${slot.totalCalories} kcal', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...slot.foods.map(
              (food) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.secondaryAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(food.name, style: Theme.of(context).textTheme.bodyLarge),
                          Text('${food.quantity} · ${food.calories} kcal', style: Theme.of(context).textTheme.bodySmall),
                          if (food.notes != null)
                            Text(food.notes!, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
