import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../data/mock/mock_models.dart';
import '../../providers/trainer_provider.dart';

/// Create or edit a scheduled session with date/time and conflict detection.
class TrainerEditSessionScreen extends ConsumerStatefulWidget {
  const TrainerEditSessionScreen({super.key, this.sessionId});

  final String? sessionId;

  @override
  ConsumerState<TrainerEditSessionScreen> createState() => _TrainerEditSessionScreenState();
}

class _TrainerEditSessionScreenState extends ConsumerState<TrainerEditSessionScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController(text: '60');

  DateTime? _scheduledAt;
  bool _saving = false;
  bool _initialized = false;
  String? _conflictMessage;

  bool get _isEdit => widget.sessionId != null;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _loadExisting(MockTrainerSession session) {
    if (_initialized) return;
    _titleController.text = session.title;
    _locationController.text = session.location;
    _durationController.text = '${session.durationMin}';
    _scheduledAt = session.scheduledAt ?? DateTime.now().add(const Duration(days: 1));
    _initialized = true;
    _checkConflict();
  }

  String _whenLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = day.difference(today).inDays;
    final dayPart = switch (diff) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => '${dt.day}/${dt.month}',
    };
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$dayPart · $h:$m';
  }

  void _checkConflict() {
    final start = _scheduledAt;
    final duration = int.tryParse(_durationController.text.trim()) ?? 60;
    if (start == null) {
      setState(() => _conflictMessage = null);
      return;
    }
    final conflict = ref.read(trainerProvider.notifier).conflictingSession(
          start,
          duration,
          excludeSessionId: widget.sessionId,
        );
    setState(() {
      _conflictMessage = conflict == null
          ? null
          : 'Conflicts with "${conflict.title}" (${conflict.whenLabel})';
    });
  }

  Future<void> _pickDateTime() async {
    final initial = _scheduledAt ?? DateTime.now().add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
    _checkConflict();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());
    final scheduledAt = _scheduledAt;

    if (title.isEmpty || location.isEmpty || duration == null || duration < 15 || scheduledAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill title, location, duration (≥15 min), and date/time.')),
      );
      return;
    }

    if (ref.read(trainerProvider.notifier).hasScheduleConflict(
          scheduledAt,
          duration,
          excludeSessionId: widget.sessionId,
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resolve the schedule conflict before saving.')),
      );
      return;
    }

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final whenLabel = _whenLabel(scheduledAt);
    final notifier = ref.read(trainerProvider.notifier);

    if (_isEdit) {
      notifier.updateSession(
        MockTrainerSession(
          id: widget.sessionId!,
          title: title,
          whenLabel: whenLabel,
          location: location,
          scheduledAt: scheduledAt,
          durationMin: duration,
        ),
      );
    } else {
      notifier.addSession(
        title: title,
        whenLabel: whenLabel,
        location: location,
        scheduledAt: scheduledAt,
        durationMin: duration,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEdit ? 'Session updated' : 'Session added'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }

  Future<void> _delete() async {
    final id = widget.sessionId;
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete session?'),
        content: const Text('This removes the session from your schedule.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    ref.read(trainerProvider.notifier).removeSession(id);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEdit) {
      final session = ref.watch(trainerProvider).sessionById(widget.sessionId!);
      if (session == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Edit session')),
          body: const Center(child: Text('Session not found.')),
        );
      }
      _loadExisting(session);
    } else {
      _scheduledAt ??= DateTime.now().add(const Duration(days: 1, hours: 1));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit session' : 'Add session')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Session title'),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date & time'),
            subtitle: Text(
              _scheduledAt != null ? _whenLabel(_scheduledAt!) : 'Not set',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: const Icon(Icons.calendar_month_outlined),
            onTap: _pickDateTime,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration (minutes)'),
            onChanged: (_) => _checkConflict(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'Location'),
          ),
          if (_conflictMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_conflictMessage!, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          FitCoreButton(
            label: _saving ? 'Saving…' : (_isEdit ? 'Save changes' : 'Add session'),
            onPressed: (_saving || _conflictMessage != null) ? null : _submit,
          ),
          if (_isEdit) ...[
            const SizedBox(height: 12),
            FitCoreButton(
              label: 'Delete session',
              variant: FitCoreButtonVariant.danger,
              onPressed: _saving ? null : _delete,
            ),
          ],
        ],
      ),
    );
  }
}
