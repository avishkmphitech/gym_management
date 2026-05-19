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

class _FoodDraft {
  _FoodDraft({MockDietFoodItem? from}) {
    nameController = TextEditingController(text: from?.name ?? '');
    qtyController = TextEditingController(text: from?.quantity ?? '');
    calController = TextEditingController(text: '${from?.calories ?? 0}');
    notesController = TextEditingController(text: from?.notes ?? '');
  }

  late final TextEditingController nameController;
  late final TextEditingController qtyController;
  late final TextEditingController calController;
  late final TextEditingController notesController;

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
    calController.dispose();
    notesController.dispose();
  }

  MockDietFoodItem? toFood() {
    final name = nameController.text.trim();
    final qty = qtyController.text.trim();
    final cal = int.tryParse(calController.text.trim());
    if (name.isEmpty || qty.isEmpty || cal == null) return null;
    final notes = notesController.text.trim();
    return MockDietFoodItem(
      name: name,
      quantity: qty,
      calories: cal,
      notes: notes.isEmpty ? null : notes,
    );
  }
}

class _MealSlotDraft {
  _MealSlotDraft({MockDietMealSlot? from})
      : type = from?.type ?? DietMealTypes.breakfast,
        timeController = TextEditingController(text: from?.timeLabel ?? DietMealTypes.defaultTime(DietMealTypes.breakfast)),
        foods = [for (final f in from?.foods ?? <MockDietFoodItem>[]) _FoodDraft(from: f)];

  String type;
  final TextEditingController timeController;
  final List<_FoodDraft> foods;

  void dispose() {
    timeController.dispose();
    for (final f in foods) {
      f.dispose();
    }
  }

  MockDietMealSlot? toSlot(String idPrefix, int index) {
    final foods = <MockDietFoodItem>[];
    for (final f in this.foods) {
      final parsed = f.toFood();
      if (parsed != null) foods.add(parsed);
    }
    if (foods.isEmpty) return null;
    return MockDietMealSlot(
      id: '${idPrefix}_$index',
      type: type,
      title: DietMealTypes.label(type),
      timeLabel: timeController.text.trim(),
      foods: foods,
    );
  }
}

/// Create or edit a full-day diet plan with timed meals.
class TrainerEditDietScreen extends ConsumerStatefulWidget {
  const TrainerEditDietScreen({super.key, this.dietId});

  final String? dietId;

  @override
  ConsumerState<TrainerEditDietScreen> createState() => _TrainerEditDietScreenState();
}

class _TrainerEditDietScreenState extends ConsumerState<TrainerEditDietScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<_MealSlotDraft> _slots = [];
  bool _saving = false;
  bool _loaded = false;

  bool get _isEdit => widget.dietId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final s in _slots) {
      s.dispose();
    }
    super.dispose();
  }

  void _load(MockMeal diet) {
    if (_loaded) return;
    _titleController.text = diet.title;
    _descController.text = diet.description;
    _slots.clear();
    if (diet.mealSlots.isEmpty) {
      _addMealSlot(DietMealTypes.breakfast);
    } else {
      for (final slot in diet.mealSlots) {
        _slots.add(_MealSlotDraft(from: slot));
      }
    }
    _loaded = true;
  }

  void _addMealSlot(String type) {
    setState(() {
      final draft = _MealSlotDraft();
      draft.type = type;
      draft.timeController.text = DietMealTypes.defaultTime(type);
      draft.foods.add(_FoodDraft());
      _slots.add(draft);
    });
  }

  Future<void> _pickMealType() async {
    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: DietMealTypes.all.map((t) {
            return ListTile(
              leading: Text(DietMealTypes.emoji(t)),
              title: Text(DietMealTypes.label(t)),
              subtitle: Text('Default ${DietMealTypes.defaultTime(t)}'),
              onTap: () => Navigator.pop(ctx, t),
            );
          }).toList(),
        ),
      ),
    );
    if (type != null) _addMealSlot(type);
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter plan title.')));
      return;
    }
    if (_slots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one meal slot.')));
      return;
    }

    final idPrefix = widget.dietId ?? 'd_${DateTime.now().millisecondsSinceEpoch}';
    final mealSlots = <MockDietMealSlot>[];
    for (var i = 0; i < _slots.length; i++) {
      final slot = _slots[i].toSlot(idPrefix, i);
      if (slot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Complete all foods in ${DietMealTypes.label(_slots[i].type)}.')),
        );
        return;
      }
      mealSlots.add(slot);
    }

    final totalCal = mealSlots.fold(0, (s, m) => s + m.totalCalories);

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final plan = MockMeal(
      id: idPrefix,
      title: title,
      calories: totalCal,
      timeLabel: 'Daily plan',
      description: _descController.text.trim(),
      mealSlots: mealSlots,
    );

    final notifier = ref.read(trainerProvider.notifier);
    if (_isEdit) {
      notifier.updateDietPlan(plan);
    } else {
      notifier.addDietPlan(plan);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    final createdId = idPrefix;
    if (!_isEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Diet plan created'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'Assign',
            textColor: Colors.white,
            onPressed: () {
              context.push('/trainer/plans/assign-diet?dietId=$createdId');
            },
          ),
        ),
      );
      context.pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meal plan updated'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Assign',
          textColor: Colors.white,
          onPressed: () {
            context.push('/trainer/plans/assign-diet?dietId=$createdId');
          },
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEdit) {
      final diet = ref.watch(trainerProvider).dietById(widget.dietId!);
      if (diet == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit diet plan')),
          body: const Center(child: Text('Plan not found.')),
        );
      }
      _load(diet);
    } else if (_slots.isEmpty && !_loaded) {
      _addMealSlot(DietMealTypes.breakfast);
      _loaded = true;
    }

    final totalCal = _slots.fold<int>(0, (sum, slot) {
      return sum +
          slot.foods.fold<int>(0, (s, f) {
            final c = int.tryParse(f.calController.text.trim());
            return s + (c ?? 0);
          });
    });

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit diet plan' : 'Create diet plan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Plan title')),
          const SizedBox(height: 12),
          TextField(controller: _descController, maxLines: 2, decoration: const InputDecoration(labelText: 'Notes for member')),
          const SizedBox(height: 8),
          Text('Estimated daily total: $totalCal kcal', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryAccent)),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Daily meals', style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              TextButton.icon(
                onPressed: _pickMealType,
                icon: const Icon(Icons.add),
                label: const Text('Add meal'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._slots.asMap().entries.map((entry) {
            final i = entry.key;
            final slot = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: FitCoreCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(DietMealTypes.emoji(slot.type), style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(DietMealTypes.label(slot.type), style: Theme.of(context).textTheme.titleSmall),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => setState(() {
                            slot.dispose();
                            _slots.removeAt(i);
                          }),
                        ),
                      ],
                    ),
                    TextField(
                      controller: slot.timeController,
                      decoration: const InputDecoration(labelText: 'Time (e.g. 07:30)'),
                    ),
                    const SizedBox(height: 10),
                    ...slot.foods.asMap().entries.map((fe) {
                      final fi = fe.key;
                      final food = fe.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          children: [
                            TextField(controller: food.nameController, decoration: const InputDecoration(labelText: 'Food item')),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(child: TextField(controller: food.qtyController, decoration: const InputDecoration(labelText: 'Quantity'))),
                                const SizedBox(width: 8),
                                Expanded(child: TextField(controller: food.calController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kcal'))),
                              ],
                            ),
                            if (slot.foods.length > 1)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => setState(() {
                                    food.dispose();
                                    slot.foods.removeAt(fi);
                                  }),
                                  child: const Text('Remove item', style: TextStyle(color: AppColors.error)),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () => setState(() => slot.foods.add(_FoodDraft())),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add food to this meal'),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          if (_isEdit)
            TrainerPermissionGate(
              permission: 'diet:write',
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FitCoreButton(
                  label: 'Assign meal to member',
                  variant: FitCoreButtonVariant.secondary,
                  icon: Icons.person_add_outlined,
                  onPressed: () => context.push('/trainer/plans/assign-diet?dietId=${widget.dietId}'),
                ),
              ),
            ),
          FitCoreButton(
            label: _saving ? 'Saving…' : (_isEdit ? 'Save meal plan' : 'Create meal plan'),
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}
