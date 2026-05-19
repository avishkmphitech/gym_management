import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../data/mock/trainer_mock_data.dart';
import '../../providers/trainer_provider.dart';

/// Assign a 7-day workout program to a member.
class TrainerAssignWeekWorkoutScreen extends ConsumerStatefulWidget {
  const TrainerAssignWeekWorkoutScreen({
    super.key,
    this.weekPlanId,
    this.memberId,
  });

  final String? weekPlanId;
  final String? memberId;

  @override
  ConsumerState<TrainerAssignWeekWorkoutScreen> createState() => _TrainerAssignWeekWorkoutScreenState();
}

class _TrainerAssignWeekWorkoutScreenState extends ConsumerState<TrainerAssignWeekWorkoutScreen> {
  String? _selectedPlanId;
  String? _selectedMemberId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedPlanId = widget.weekPlanId;
    _selectedMemberId = widget.memberId;
  }

  Future<void> _submit() async {
    final planId = _selectedPlanId;
    final memberId = _selectedMemberId;
    if (planId == null || memberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a member and week plan.')),
      );
      return;
    }

    final trainer = ref.read(trainerProvider);
    final member = trainer.memberById(memberId);
    final plan = trainer.weeklyPlanById(planId);
    final existing = trainer.weeklyWorkoutLabelForMember(memberId);
    final isSwitch = existing != null;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isSwitch ? 'Switch week plan?' : 'Assign week plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSwitch
                  ? 'Switch ${member?.name} to "${plan?.name}"?'
                  : 'Assign "${plan?.name}" to ${member?.name}?',
            ),
            const SizedBox(height: 8),
            Text(
              '${plan?.trainingDays ?? 0} training days per week will appear in their app.',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            if (isSwitch && existing != plan?.name) ...[
              const SizedBox(height: 12),
              Text(
                'Replaces current plan: $existing',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(color: AppColors.warning),
              ),
            ],
          ],
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
    await Future<void>.delayed(const Duration(milliseconds: 500));
    ref.read(trainerProvider.notifier).assignWeeklyWorkout(memberId: memberId, weekPlanId: planId);
    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSwitch ? 'Week plan switched for ${member?.name}' : 'Week plan assigned to ${member?.name}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final trainer = ref.watch(trainerProvider);
    final plans = trainer.weeklyWorkoutPlans;
    final presetMember = widget.memberId != null ? trainer.memberById(widget.memberId!) : null;
    final existingWeek = widget.memberId != null
        ? trainer.weeklyWorkoutLabelForMember(widget.memberId!)
        : null;
    final isSwitchFlow = existingWeek != null;

    return Scaffold(
      appBar: AppBar(title: Text(isSwitchFlow ? 'Change week plan' : 'Assign week plan')),
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
                        if (existingWeek != null)
                          Text(
                            'Current: $existingWeek',
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
            return _selectTile(
              context,
              selected: selected,
              title: m.name,
              subtitle: m.plan,
              onTap: () => setState(() => _selectedMemberId = m.id),
            );
          }),
          const SizedBox(height: 20),
          Text('Week program', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          ...plans.map((p) {
            final selected = _selectedPlanId == p.id;
            return _selectTile(
              context,
              selected: selected,
              title: p.name,
              subtitle: '${p.trainingDays} days · ${p.goalFocus}',
              onTap: () => setState(() => _selectedPlanId = p.id),
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

  Widget _selectTile(
    BuildContext context, {
    required bool selected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: FitCoreCard(
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
                      Text(title, style: Theme.of(context).textTheme.titleMedium),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
