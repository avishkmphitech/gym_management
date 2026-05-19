import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/tokens/app_colors.dart';
import '../data/mock/mock_models.dart';
import '../providers/trainer_provider.dart';

/// Week calendar strip with session dots (Task 4).
class TrainerScheduleCalendar extends ConsumerStatefulWidget {
  const TrainerScheduleCalendar({super.key});

  @override
  ConsumerState<TrainerScheduleCalendar> createState() => _TrainerScheduleCalendarState();
}

class _TrainerScheduleCalendarState extends ConsumerState<TrainerScheduleCalendar> {
  late DateTime _weekStart;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _shiftWeek(int delta) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * delta));
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainer = ref.watch(trainerProvider);
    final days = List.generate(7, (i) => _weekStart.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(onPressed: () => _shiftWeek(-1), icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Text(
                _monthLabel(_weekStart),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            IconButton(onPressed: () => _shiftWeek(1), icon: const Icon(Icons.chevron_right)),
          ],
        ),
        Row(
          children: days.map((day) {
            final sessions = trainer.sessionsOnDay(day);
            final selected = _sameDay(day, _selectedDay);
            final isToday = _sameDay(day, DateTime.now());
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryAccent.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isToday ? Border.all(color: AppColors.primaryAccent, width: 1) : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _weekdayLabel(day.weekday),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: selected ? AppColors.primaryAccent : AppColors.secondaryText,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.primaryText : AppColors.secondaryText,
                            ),
                      ),
                      const SizedBox(height: 6),
                      if (sessions.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            sessions.length.clamp(0, 3),
                            (_) => Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: const BoxDecoration(
                                color: AppColors.secondaryAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text(
          'Sessions on ${_fullDayLabel(_selectedDay)}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...trainer.sessionsOnDay(_selectedDay).map((s) => _SessionTile(session: s)),
        if (trainer.sessionsOnDay(_selectedDay).isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'No sessions this day.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekdayLabel(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }

  String _monthLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _fullDayLabel(DateTime d) => '${_weekdayLabel(d.weekday)}, ${d.day} ${_monthLabel(d).split(' ').first}';
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final MockTrainerSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryBg,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event, color: AppColors.secondaryAccent),
        title: Text(session.title, style: Theme.of(context).textTheme.titleSmall),
        subtitle: Text('${session.whenLabel} · ${session.location}'),
        trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryText),
        onTap: () => context.push('/trainer/schedule/${session.id}/edit'),
      ),
    );
  }
}
