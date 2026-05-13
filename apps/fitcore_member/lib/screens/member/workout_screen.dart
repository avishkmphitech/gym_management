import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../widgets/role_guard.dart';

const _kAccentGreen = Color(0xFF3E7C59);

/// Member workouts — MEMBER role only ([RoleGuard]).
class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

enum _DayDot { none, hasWorkout, missed }

class _WeekPill {
  const _WeekPill({
    required this.abbr,
    required this.day,
    required this.isToday,
    required this.dot,
  });

  final String abbr;
  final int day;
  final bool isToday;
  final _DayDot dot;
}

class _ExerciseData {
  const _ExerciseData({
    required this.name,
    required this.setsReps,
    required this.category,
    required this.icon,
    this.notes,
    this.initiallyChecked = false,
  });

  final String name;
  final String setsReps;
  final String category;
  final IconData icon;
  final String? notes;
  final bool initiallyChecked;
}

class _PastRow {
  const _PastRow({required this.date, required this.plan, required this.completed});

  final String date;
  final String plan;
  final bool completed;
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> with SingleTickerProviderStateMixin {
  late final List<bool> _checked;
  late final List<_ExerciseData> _exercises;

  late final List<_WeekPill> _weekPills;
  late final AnimationController _confettiController;
  late final DateTime _sessionStart;

  @override
  void initState() {
    super.initState();
    _sessionStart = DateTime.now();
    _exercises = const [
      _ExerciseData(
        name: 'Bench Press',
        setsReps: '4 sets × 12 reps',
        category: 'Chest',
        icon: Icons.fitness_center_rounded,
        notes: 'Full range of motion',
        initiallyChecked: true,
      ),
      _ExerciseData(
        name: 'Incline DB Press',
        setsReps: '3 sets × 10 reps',
        category: 'Chest',
        icon: Icons.fitness_center_rounded,
        initiallyChecked: true,
      ),
      _ExerciseData(
        name: 'Shoulder Press',
        setsReps: '3 sets × 12 reps',
        category: 'Shoulders',
        icon: Icons.sports_gymnastics_rounded,
        initiallyChecked: true,
      ),
      _ExerciseData(
        name: 'Lateral Raises',
        setsReps: '3 sets × 15 reps',
        category: 'Shoulders',
        icon: Icons.sports_gymnastics_rounded,
        notes: 'Controlled movement',
        initiallyChecked: false,
      ),
      _ExerciseData(
        name: 'Pull-ups',
        setsReps: '4 sets × 8 reps',
        category: 'Back',
        icon: Icons.arrow_upward_rounded,
        notes: 'Use assist band if needed',
        initiallyChecked: false,
      ),
      _ExerciseData(
        name: 'Bicep Curls',
        setsReps: '3 sets × 12 reps',
        category: 'Arms',
        icon: Icons.sports_martial_arts_rounded,
        initiallyChecked: false,
      ),
    ];
    _checked = _exercises.map((e) => e.initiallyChecked).toList();

    _weekPills = const [
      _WeekPill(abbr: 'M', day: 9, isToday: false, dot: _DayDot.hasWorkout),
      _WeekPill(abbr: 'T', day: 10, isToday: false, dot: _DayDot.hasWorkout),
      _WeekPill(abbr: 'W', day: 11, isToday: false, dot: _DayDot.missed),
      _WeekPill(abbr: 'T', day: 12, isToday: false, dot: _DayDot.hasWorkout),
      _WeekPill(abbr: 'F', day: 13, isToday: true, dot: _DayDot.hasWorkout),
      _WeekPill(abbr: 'S', day: 14, isToday: false, dot: _DayDot.none),
      _WeekPill(abbr: 'S', day: 15, isToday: false, dot: _DayDot.none),
    ];

    _confettiController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _confettiController.reset();
        }
      });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  bool get _allDone => _checked.every((c) => c);

  void _toggle(int i) {
    setState(() => _checked[i] = !_checked[i]);
  }

  void _showSuccessSheet(BuildContext context) {
    _confettiController.forward(from: 0);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final elapsed = DateTime.now().difference(_sessionStart);
        final mins = math.max(1, elapsed.inMinutes);
        final calEst = (mins * 7.5).round();
        return _WorkoutCompleteSheet(
          confettiAnimation: _confettiController,
          durationLabel: '$mins min',
          caloriesLabel: '$calEst kcal',
          onBackHome: () {
            Navigator.of(ctx).pop();
            if (context.mounted) context.go('/member/home');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      allowedRoles: const ['MEMBER'],
      fallback: const _AccessDenied(),
      child: Scaffold(
        backgroundColor: AppColors.primaryBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBg,
          elevation: 0,
          title: Text(
            'My Workouts',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list_rounded, color: AppColors.primaryText),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _WeekSelectorRow(pills: _weekPills),
                  const SizedBox(height: 20),
                  _TodaysPlanCard(
                    completed: _checked.where((c) => c).length,
                    total: _exercises.length,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_exercises.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ExerciseCard(
                        data: _exercises[i],
                        checked: _checked[i],
                        onToggle: () => _toggle(i),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  const _PastWorkoutsAccordion(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _allDone ? () => _showSuccessSheet(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _allDone ? _kAccentGreen : const Color(0xFF444444),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF444444),
                    disabledForegroundColor: const Color(0xFFB8B6B0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Finish Workout',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: Center(
        child: Text(
          'Workouts are available for members only.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.secondaryText),
        ),
      ),
    );
  }
}

class _WeekSelectorRow extends StatelessWidget {
  const _WeekSelectorRow({required this.pills});

  final List<_WeekPill> pills;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pills.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final p = pills[i];
          final active = p.isToday;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? _kAccentGreen : const Color(0xFF2B2B2B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      p.abbr,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.day}',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              if (p.dot == _DayDot.hasWorkout)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF3E7C59), shape: BoxShape.circle),
                )
              else if (p.dot == _DayDot.missed)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFFA94A4A), shape: BoxShape.circle),
                )
              else
                const SizedBox(height: 6),
            ],
          );
        },
      ),
    );
  }
}

class _TodaysPlanCard extends StatelessWidget {
  const _TodaysPlanCard({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final frac = total == 0 ? 0.0 : completed / total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Upper Body Blast',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryAccent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.secondaryAccent.withValues(alpha: 0.6)),
                      ),
                      child: Text(
                        'Medium',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Assigned by Arjun Sharma • 45 mins • 6 exercises',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText, height: 1.35),
                ),
                const SizedBox(height: 16),
                Text(
                  '$completed of $total completed',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: frac,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF444444),
                    valueColor: const AlwaysStoppedAnimation<Color>(_kAccentGreen),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: frac,
                        strokeWidth: 4,
                        backgroundColor: const Color(0xFF444444),
                        valueColor: const AlwaysStoppedAnimation<Color>(_kAccentGreen),
                      ),
                    ),
                    Text(
                      '${(frac * 100).round()}%',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.data,
    required this.checked,
    required this.onToggle,
  });

  final _ExerciseData data;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(14),
        border: checked ? const Border(left: BorderSide(color: Color(0xFF3E7C59), width: 3)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF222222),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(data.icon, color: AppColors.secondaryText, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Opacity(
                    opacity: checked ? 0.7 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.name,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.setsReps,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.category,
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText.withValues(alpha: 0.85)),
                        ),
                        if (data.notes != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            data.notes!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppColors.secondaryText,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: _CustomCheck(checked: checked),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomCheck extends StatelessWidget {
  const _CustomCheck({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: checked ? const Color(0xFF3E7C59) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF444444), width: checked ? 0 : 2),
      ),
      alignment: Alignment.center,
      child: checked
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
    );
  }
}

class _PastWorkoutsAccordion extends StatefulWidget {
  const _PastWorkoutsAccordion();

  @override
  State<_PastWorkoutsAccordion> createState() => _PastWorkoutsAccordionState();
}

class _PastWorkoutsAccordionState extends State<_PastWorkoutsAccordion> {
  bool _expanded = false;

  static const _rows = [
    _PastRow(date: 'Jun 8, 2026', plan: 'Leg Power', completed: true),
    _PastRow(date: 'Jun 7, 2026', plan: 'HIIT Circuit', completed: false),
    _PastRow(date: 'Jun 5, 2026', plan: 'Upper Body Blast', completed: true),
    _PastRow(date: 'Jun 4, 2026', plan: 'Mobility Flow', completed: true),
    _PastRow(date: 'Jun 3, 2026', plan: 'Core & Cardio', completed: false),
    _PastRow(date: 'Jun 2, 2026', plan: 'Pull Session', completed: true),
    _PastRow(date: 'Jun 1, 2026', plan: 'Push Session', completed: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (v) => setState(() => _expanded = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          title: Text(
            'Past 7 Days',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
          trailing: Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            color: AppColors.secondaryText,
          ),
          children: [
            ..._rows.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(r.date, style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText)),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        r.plan,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: r.completed
                            ? const Color(0xFF1F3B2D)
                            : const Color(0xFF3B1F1F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        r.completed ? 'Completed' : 'Missed',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: r.completed ? const Color(0xFF5A8F58) : const Color(0xFFA94A4A),
                        ),
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

class _WorkoutCompleteSheet extends StatelessWidget {
  const _WorkoutCompleteSheet({
    required this.confettiAnimation,
    required this.durationLabel,
    required this.caloriesLabel,
    required this.onBackHome,
  });

  final Animation<double> confettiAnimation;
  final String durationLabel;
  final String caloriesLabel;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.45,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF222222),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: confettiAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ConfettiPainter(progress: confettiAnimation.value),
                    );
                  },
                ),
              ),
              ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottom),
                children: [
                  Center(
                    child: Text(
                      'Workout Complete! 🎉',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _WorkoutCompleteSheet._statRow('Duration', durationLabel),
                  _WorkoutCompleteSheet._statRow('Calories (est.)', caloriesLabel),
                  _WorkoutCompleteSheet._statRow('Exercises', '6 / 6'),
                  const SizedBox(height: 20),
                  Text(
                    'Great job, Rahul!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.primaryAccent),
                  ),
                  const SizedBox(height: 28),
                  FitCoreButton(label: 'Back to Home', onPressed: onBackHome),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText)),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    const n = 36;
    for (var i = 0; i < n; i++) {
      final seed = i * 9973;
      final x0 = (seed % 1000 / 1000) * size.width;
      final delay = (i / n) * 0.35;
      final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final y = -20 + t * (size.height * 0.85);
      final x = x0 + math.sin(t * math.pi * 2 + i) * 24 * t;
      final colors = [
        const Color(0xFF3E7C59),
        const Color(0xFFC56A3D),
        const Color(0xFF5A8F58),
        const Color(0xFFF5F5F2),
        const Color(0xFFA94A4A),
      ];
      final paint = Paint()..color = colors[i % colors.length].withValues(alpha: 1 - t * 0.35);
      final w = 6 + (i % 3) * 2.0;
      final h = 8 + (i % 4) * 1.5;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((seed % 360) * math.pi / 180 * t);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h), const Radius.circular(2)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
