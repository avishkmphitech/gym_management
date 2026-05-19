import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/diet_meal_types.dart';
import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../data/mock/trainer_mock_data.dart';
import '../../providers/trainer_provider.dart';

/// Pick a diet plan and assign to a member.
class TrainerAssignDietScreen extends ConsumerStatefulWidget {
  const TrainerAssignDietScreen({
    super.key,
    this.dietId,
    this.memberId,
  });

  final String? dietId;
  final String? memberId;

  @override
  ConsumerState<TrainerAssignDietScreen> createState() => _TrainerAssignDietScreenState();
}

class _TrainerAssignDietScreenState extends ConsumerState<TrainerAssignDietScreen> {
  String? _selectedDietId;
  String? _selectedMemberId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedDietId = widget.dietId;
    _selectedMemberId = widget.memberId;
  }

  Future<void> _submit() async {
    final dietId = _selectedDietId;
    final memberId = _selectedMemberId;
    if (dietId == null || memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a member and diet plan.')),
      );
      return;
    }

    final trainer = ref.read(trainerProvider);
    final member = trainer.memberById(memberId);
    final diet = trainer.dietById(dietId);
    final existing = trainer.dietLabelForMember(memberId);
    final isSwitch = existing != null;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSwitch ? 'Switch meal plan?' : 'Assign meal plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSwitch
                    ? 'Switch ${member?.name} to "${diet?.title}"?'
                    : 'Assign "${diet?.title}" to ${member?.name}?',
              ),
              const SizedBox(height: 8),
              Text(
                '${diet?.computedCalories ?? 0} kcal/day · member sees all meals below',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              if (isSwitch && existing != diet?.title) ...[
                const SizedBox(height: 12),
                Text(
                  'Replaces current meal plan: $existing',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                ),
              ],
              if (diet != null && diet.mealSlots.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                ...diet.mealSlots.map(
                  (slot) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${DietMealTypes.emoji(slot.type)} ${slot.timeLabel} · ${slot.title} (${slot.totalCalories} kcal)',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isSwitch ? 'Switch plan' : 'Assign',
              style: const TextStyle(color: AppColors.primaryAccent),
            ),
          ),
        ],
      ),
    );
    if (proceed != true || !mounted) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    ref.read(trainerProvider.notifier).assignDiet(memberId: memberId, dietId: dietId);
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSwitch
              ? 'Meal plan switched for ${member?.name ?? 'member'}'
              : 'Assigned "${diet?.title}" to ${member?.name ?? 'member'}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final trainer = ref.watch(trainerProvider);
    final presetMember = widget.memberId != null ? trainer.memberById(widget.memberId!) : null;
    final existingMeal = widget.memberId != null ? trainer.dietLabelForMember(widget.memberId!) : null;
    final isSwitchFlow = existingMeal != null;

    return Scaffold(
      appBar: AppBar(title: Text(isSwitchFlow ? 'Change meal plan' : 'Assign meal plan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (presetMember != null) ...[
            FitCoreCard(
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: AppColors.primaryAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSwitchFlow ? 'Switching plan for' : 'Assigning plan to',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(presetMember.name, style: Theme.of(context).textTheme.titleMedium),
                        if (existingMeal != null)
                          Text(
                            'Current: $existingMeal',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text('Member', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          ...assignedMembers.map((m) {
            final selected = _selectedMemberId == m.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SelectableCard(
                onTap: () => setState(() => _selectedMemberId = m.id),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: selected ? AppColors.primaryAccent : AppColors.secondaryText,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: Theme.of(context).textTheme.titleMedium),
                          Text(m.plan, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          Text('Diet plan', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          ...trainer.dietPlans.map((d) {
            final selected = _selectedDietId == d.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SelectableCard(
                onTap: () => setState(() => _selectedDietId = d.id),
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: selected ? AppColors.primaryAccent : AppColors.secondaryText,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.title, style: Theme.of(context).textTheme.titleMedium),
                          Text('${d.calories} kcal · ${d.timeLabel}', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          FitCoreButton(
            label: _saving
                ? 'Saving…'
                : (isSwitchFlow ? 'Confirm plan switch' : 'Confirm assignment'),
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  const _SelectableCard({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: FitCoreCard(child: child),
      ),
    );
  }
}
