import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/diet_meal_types.dart';
import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../data/mock/mock_models.dart';
import '../../providers/trainer_provider.dart';
import 'trainer_week_day_editor_screen.dart';
import 'week_plan_draft.dart';

/// Create or edit a 7-day program — select a day to preview exercises, edit in full screen.
class TrainerEditWeekPlanScreen extends ConsumerStatefulWidget {
  const TrainerEditWeekPlanScreen({super.key, this.weekPlanId});

  final String? weekPlanId;

  @override
  ConsumerState<TrainerEditWeekPlanScreen> createState() => _TrainerEditWeekPlanScreenState();
}

class _TrainerEditWeekPlanScreenState extends ConsumerState<TrainerEditWeekPlanScreen> {
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  late List<WeekPlanDayDraft> _days;
  bool _saving = false;
  bool _loaded = false;
  int _selectedDayIndex = 0;

  bool get _isEdit => widget.weekPlanId != null;
  WeekPlanDayDraft get _selectedDay => _days[_selectedDayIndex];

  @override
  void initState() {
    super.initState();
    _days = createEmptyWeekDays();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    for (final d in _days) {
      d.dispose();
    }
    super.dispose();
  }

  void _load(MockWeeklyWorkoutPlan plan) {
    if (_loaded) return;
    _nameController.text = plan.name;
    _goalController.text = plan.goalFocus;
    for (final d in _days) {
      d.dispose();
    }
    _days = List.generate(
      7,
      (i) => WeekPlanDayDraft(dayIndex: i, dayLabel: WeekdayLabels.names[i], from: plan.days[i]),
    );
    _loaded = true;
  }

  void _selectDay(int index) {
    setState(() => _selectedDayIndex = index);
  }

  Future<void> _openDayEditor([int? dayIndex]) async {
    if (dayIndex != null) {
      setState(() => _selectedDayIndex = dayIndex);
    }
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TrainerWeekDayEditorScreen(day: _days[_selectedDayIndex]),
      ),
    );
    if (mounted) setState(() {});
  }

  void _deleteExercise(int exerciseIndex) {
    setState(() {
      final ex = _selectedDay.exercises.removeAt(exerciseIndex);
      ex.dispose();
    });
  }

  Future<void> _clearSelectedDay() async {
    final fullName = WeekdayLabels.full[_selectedDayIndex];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear $fullName?'),
        content: const Text('Removes all exercises and marks this day as rest.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _selectedDay.clearWorkout());
  }

  Future<void> _deleteWeekPlan() async {
    final id = widget.weekPlanId;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete week plan?'),
        content: const Text('This removes the program from your library. Members already assigned keep their copy until reassigned.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    ref.read(trainerProvider.notifier).deleteWeeklyWorkoutPlan(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Week plan deleted'), backgroundColor: AppColors.success),
    );
    context.pop();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final goal = _goalController.text.trim();
    if (name.isEmpty || goal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter program name and goal.')),
      );
      return;
    }

    final dayPlans = <MockWeeklyDayPlan>[];
    for (final d in _days) {
      final parsed = d.toDayPlan();
      if (parsed == null && !d.isRest) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complete ${WeekdayLabels.full[d.dayIndex]} or mark it as rest.')),
        );
        return;
      }
      dayPlans.add(
        parsed ?? MockWeeklyDayPlan(dayIndex: d.dayIndex, dayLabel: d.dayLabel, isRestDay: true),
      );
    }

    if (dayPlans.where((d) => !d.isRestDay).isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan at least one training day.')),
      );
      return;
    }

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final id = widget.weekPlanId ?? 'ww_${DateTime.now().millisecondsSinceEpoch}';
    final plan = MockWeeklyWorkoutPlan(id: id, name: name, goalFocus: goal, days: dayPlans);
    final notifier = ref.read(trainerProvider.notifier);
    if (_isEdit) {
      notifier.updateWeeklyWorkoutPlan(plan);
    } else {
      notifier.addWeeklyWorkoutPlan(plan);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Week plan updated' : 'Week plan created'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEdit) {
      final plan = ref.watch(trainerProvider).weeklyPlanById(widget.weekPlanId!);
      if (plan == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Week plan')),
          body: const Center(child: Text('Plan not found.')),
        );
      }
      _load(plan);
    }

    final configuredCount = _days.where((d) => d.isConfigured).length;
    final day = _selectedDay;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit week plan' : 'Create week plan'),
        actions: [
          if (_isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              tooltip: 'Delete week plan',
              onPressed: _deleteWeekPlan,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Program name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _goalController,
                  decoration: const InputDecoration(labelText: 'Goal / focus'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Weekly schedule', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text(
                  '$configuredCount / 7 days set',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryAccent),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final d = _days[i];
                return _DayChip(
                  label: d.dayLabel,
                  selected: _selectedDayIndex == i,
                  configured: d.isConfigured,
                  isRest: d.isRest,
                  onTap: () => _selectDay(i),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              children: [
                _SelectedDayHeader(
                  dayName: WeekdayLabels.full[_selectedDayIndex],
                  day: day,
                  onEdit: _openDayEditor,
                  onClear: day.isConfigured ? _clearSelectedDay : null,
                ),
                const SizedBox(height: 12),
                if (day.isRest)
                  FitCoreCard(
                    child: Text(
                      'Rest day — no exercises. Tap Edit day to add a workout.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else if (day.exercises.isEmpty)
                  FitCoreCard(
                    child: Text(
                      'No exercises yet. Tap Edit day to create this workout.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ...day.exercises.asMap().entries.map((entry) {
                    final i = entry.key;
                    final draft = entry.value;
                    final ex = draft.toExercise();
                    final name = ex?.name ??
                        (draft.nameController.text.trim().isEmpty
                            ? 'Exercise ${i + 1} (incomplete)'
                            : draft.nameController.text.trim());
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: FitCoreCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: Theme.of(context).textTheme.titleSmall),
                                  if (ex != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '${ex.sets} sets × ${ex.reps} reps',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (ex.notes != null && ex.notes!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(ex.notes!, style: Theme.of(context).textTheme.bodySmall),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              tooltip: 'Remove exercise',
                              onPressed: () => _deleteExercise(i),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: FitCoreButton(
              label: _saving ? 'Saving…' : (_isEdit ? 'Save week plan' : 'Create week plan'),
              onPressed: _saving ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedDayHeader extends StatelessWidget {
  const _SelectedDayHeader({
    required this.dayName,
    required this.day,
    required this.onEdit,
    this.onClear,
  });

  final String dayName;
  final WeekPlanDayDraft day;
  final VoidCallback onEdit;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return FitCoreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dayName, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      day.summaryLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: day.isRest ? AppColors.secondaryText : AppColors.primaryAccent,
                          ),
                    ),
                    if (!day.isRest && day.titleController.text.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${day.durationController.text} min'
                          '${day.focusController.text.trim().isEmpty ? '' : ' · ${day.focusController.text.trim()}'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FitCoreButton(
                  label: day.isConfigured && !day.isRest ? 'Edit day' : 'Create / edit day',
                  icon: Icons.fitness_center,
                  onPressed: onEdit,
                ),
              ),
              if (onClear != null) ...[
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
                  tooltip: 'Clear day',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.configured,
    required this.isRest,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool configured;
  final bool isRest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? AppColors.primaryAccent
        : configured
            ? AppColors.primaryAccent.withValues(alpha: 0.2)
            : AppColors.cardBg;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primaryAccent : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: selected ? Colors.white : AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                isRest ? Icons.hotel_outlined : (configured ? Icons.fitness_center : Icons.add),
                size: 16,
                color: selected ? Colors.white : AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
