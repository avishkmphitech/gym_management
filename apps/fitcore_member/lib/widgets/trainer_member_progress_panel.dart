import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/tokens/app_colors.dart';
import '../core/widgets/fitcore_card.dart';
import '../data/mock/mock_models.dart';

/// Charts and history for trainer member progress (Task 3).
class TrainerMemberProgressPanel extends StatelessWidget {
  const TrainerMemberProgressPanel({super.key, required this.progress});

  final MockMemberProgress progress;

  @override
  Widget build(BuildContext context) {
    final completionRate = progress.workoutsAssigned > 0
        ? progress.workoutsCompleted / progress.workoutsAssigned
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Progress overview', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        FitCoreCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Workout completion', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: completionRate.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.border.withValues(alpha: 0.4),
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${progress.workoutsCompleted} of ${progress.workoutsAssigned} sessions (${(completionRate * 100).round()}%)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text('Attendance (30 days)', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.attendancePercent / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.border.withValues(alpha: 0.4),
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 6),
              Text('${progress.attendancePercent}% check-in rate', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (progress.weeklyCompletion.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Weekly completion', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          FitCoreCard(
            child: SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _WeeklyBarChartPainter(values: progress.weeklyCompletion),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
        if (progress.bodyMetrics != null) ...[
          const SizedBox(height: 16),
          Text('Body metrics', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Weight',
                  value: '${progress.bodyMetrics!.weightKg} kg',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Body fat',
                  value: '${progress.bodyMetrics!.bodyFatPercent}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricTile(
                  label: 'Muscle',
                  value: '${progress.bodyMetrics!.muscleMassKg} kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Updated ${progress.bodyMetrics!.updatedLabel} · ${progress.weightTrend}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (progress.attendanceHistory.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Attendance history', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          FitCoreCard(
            child: Column(
              children: [
                for (var i = 0; i < progress.attendanceHistory.length; i++) ...[
                  if (i > 0) const Divider(height: 16, color: AppColors.border),
                  _AttendanceRow(entry: progress.attendanceHistory[i]),
                ],
              ],
            ),
          ),
        ],
        if (progress.workoutHistory.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Workout history', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          FitCoreCard(
            child: Column(
              children: [
                for (var i = 0; i < progress.workoutHistory.length; i++) ...[
                  if (i > 0) const Divider(height: 16, color: AppColors.border),
                  _WorkoutHistoryRow(entry: progress.workoutHistory[i]),
                ],
              ],
            ),
          ),
        ],
        if (progress.notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Coach notes', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          FitCoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: progress.notes
                  .map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, size: 6, color: AppColors.secondaryAccent),
                          const SizedBox(width: 8),
                          Expanded(child: Text(n, style: Theme.of(context).textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _WeeklyBarChartPainter extends CustomPainter {
  _WeeklyBarChartPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values.reduce(math.max).clamp(1.0, 100.0);
    final barW = size.width / values.length * 0.55;
    final gap = size.width / values.length * 0.45;
    const labels = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'];

    for (var i = 0; i < values.length; i++) {
      final x = i * (barW + gap) + gap / 2;
      final h = (values[i] / maxVal) * (size.height - 24);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - 24 - h, barW, h),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = AppColors.primaryAccent.withValues(alpha: 0.85),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: i < labels.length ? labels[i] : '',
          style: const TextStyle(color: AppColors.secondaryText, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x + barW / 2 - tp.width / 2, size.height - 18));
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarChartPainter old) => old.values != values;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return FitCoreCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.titleSmall),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.entry});

  final MockAttendanceEntry entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          entry.checkedIn ? Icons.check_circle_outline : Icons.cancel_outlined,
          color: entry.checkedIn ? AppColors.success : AppColors.error,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.dateLabel, style: Theme.of(context).textTheme.bodyLarge),
              Text(entry.window, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkoutHistoryRow extends StatelessWidget {
  const _WorkoutHistoryRow({required this.entry});

  final MockWorkoutCompletion entry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          entry.completed ? Icons.done_all : Icons.pending_outlined,
          color: entry.completed ? AppColors.success : AppColors.warning,
          size: 22,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.planName, style: Theme.of(context).textTheme.bodyLarge),
              Text(
                '${entry.dateLabel} · ${entry.completed ? 'Completed' : 'Missed'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
