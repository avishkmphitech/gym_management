import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../data/mock/mock_models.dart';
import '../../providers/chat_provider.dart';
import '../../providers/member_provider.dart';
import '../../widgets/member_phase_viewport.dart';
import '../../widgets/role_guard.dart';

const _kOrange = Color(0xFFC56A3D);
const _kGreen = Color(0xFF3E7C59);
const _kBlueGrey = Color(0xFF6B8A9E);
const _kTrack = Color(0xFF444444);
const _kCard = Color(0xFF222222);
const _kBottomCard = Color(0xFF2B2B2B);

/// Member nutrition — MEMBER role only ([RoleGuard]).
class DietScreen extends ConsumerStatefulWidget {
  const DietScreen({super.key});

  @override
  ConsumerState<DietScreen> createState() => _DietScreenState();
}

enum _DotKind { carb, protein, veg, balanced }

enum _WorkoutBadgeKind { pre, post }

class _MealItemData {
  const _MealItemData({
    required this.name,
    required this.quantity,
    required this.kcal,
    required this.dot,
    this.chip,
    this.workoutBadge,
  });

  final String name;
  final String quantity;
  final int kcal;
  final _DotKind dot;
  final String? chip;
  final _WorkoutBadgeKind? workoutBadge;
}

class _MealBlockData {
  const _MealBlockData({
    required this.emoji,
    required this.title,
    required this.totalKcal,
    required this.items,
    this.initiallyExpanded = false,
  });

  final String emoji;
  final String title;
  final int totalKcal;
  final List<_MealItemData> items;
  final bool initiallyExpanded;
}

class _DietScreenState extends ConsumerState<DietScreen> {
  List<bool> _itemLogged = [];
  String? _loadedDietId;

  static String _emojiForSlot(String type) {
    switch (type) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '☀️';
      case 'dinner':
        return '🌙';
      case 'pre_workout':
      case 'post_workout':
        return '🏃';
      default:
        return '🍎';
    }
  }

  static _DotKind _dotForFood(String name) {
    final n = name.toLowerCase();
    if (n.contains('chicken') || n.contains('egg') || n.contains('protein') || n.contains('paneer') || n.contains('whey')) {
      return _DotKind.protein;
    }
    if (n.contains('rice') || n.contains('oats') || n.contains('banana') || n.contains('roti')) {
      return _DotKind.carb;
    }
    if (n.contains('salad') || n.contains('veg')) {
      return _DotKind.veg;
    }
    return _DotKind.balanced;
  }

  static String? _chipForDot(_DotKind dot) {
    switch (dot) {
      case _DotKind.protein:
        return 'Protein';
      case _DotKind.carb:
        return 'Carb-heavy';
      case _DotKind.veg:
        return 'Veg';
      case _DotKind.balanced:
        return null;
    }
  }

  static List<_MealBlockData> _blocksFromPlan(MockMeal diet) {
    return diet.mealSlots.map((slot) {
      final items = slot.foods.map((f) {
        final dot = _dotForFood(f.name);
        return _MealItemData(
          name: f.name,
          quantity: f.quantity,
          kcal: f.calories,
          dot: dot,
          chip: _chipForDot(dot),
          workoutBadge: slot.type == 'pre_workout'
                  ? _WorkoutBadgeKind.pre
                  : slot.type == 'post_workout'
                      ? _WorkoutBadgeKind.post
                      : null,
        );
      }).toList();
      return _MealBlockData(
        emoji: _emojiForSlot(slot.type),
        title: slot.title,
        totalKcal: slot.totalCalories,
        initiallyExpanded: slot.type == 'breakfast',
        items: items,
      );
    }).toList();
  }

  int _itemCount(List<_MealBlockData> blocks) {
    var n = 0;
    for (final m in blocks) {
      n += m.items.length;
    }
    return n;
  }

  List<bool> _loggedFor(String dietId, int count) {
    if (_loadedDietId != dietId || _itemLogged.length != count) {
      return List.filled(count, false);
    }
    return _itemLogged;
  }

  ({int kcal, double protein, double carbs, double fat}) _macrosFromLogged(
    List<_MealBlockData> blocks,
    List<bool> logged,
  ) {
    var flat = 0;
    var kcal = 0;
    var protein = 0.0;
    var carbs = 0.0;
    var fat = 0.0;
    for (final block in blocks) {
      for (final item in block.items) {
        if (flat < logged.length && logged[flat]) {
          kcal += item.kcal;
          switch (item.dot) {
            case _DotKind.protein:
              protein += item.kcal * 0.35 / 4;
              carbs += item.kcal * 0.15 / 4;
              fat += item.kcal * 0.25 / 9;
            case _DotKind.carb:
              protein += item.kcal * 0.1 / 4;
              carbs += item.kcal * 0.55 / 4;
              fat += item.kcal * 0.1 / 9;
            case _DotKind.veg:
              protein += item.kcal * 0.15 / 4;
              carbs += item.kcal * 0.5 / 4;
              fat += item.kcal * 0.1 / 9;
            case _DotKind.balanced:
              protein += item.kcal * 0.25 / 4;
              carbs += item.kcal * 0.45 / 4;
              fat += item.kcal * 0.2 / 9;
          }
        }
        flat++;
      }
    }
    return (kcal: kcal, protein: protein, carbs: carbs, fat: fat);
  }

  void _toggleLog(int flatIndex, String dietId, int count) {
    setState(() {
      if (_loadedDietId != dietId || _itemLogged.length != count) {
        _loadedDietId = dietId;
        _itemLogged = List.filled(count, false);
      }
      _itemLogged[flatIndex] = !_itemLogged[flatIndex];
    });
  }

  void _showMacroInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final pad = MediaQuery.paddingOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + pad),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryText.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Understanding macros',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primaryText),
              ),
              const SizedBox(height: 16),
              _macroBullet(
                'Protein',
                'Repairs muscle and keeps you full. Your target supports recovery from training.',
                _kGreen,
              ),
              const SizedBox(height: 12),
              _macroBullet(
                'Carbs',
                'Primary fuel for workouts and daily energy. Spread across meals for steady energy.',
                _kOrange,
              ),
              const SizedBox(height: 12),
              _macroBullet(
                'Fat',
                'Supports hormones and nutrient absorption. Keep portions aligned with your plan.',
                _kBlueGrey,
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _macroBullet(String title, String body, Color accent) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
              const SizedBox(height: 4),
              Text(body, style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: AppColors.secondaryText)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final diet = ref.watch(memberDietPlanProvider);
    final membership = ref.watch(memberMembershipProvider);

    if (diet == null) {
      return RoleGuard(
        allowedRoles: const ['MEMBER'],
        fallback: const _AccessDenied(),
        child: Scaffold(
          backgroundColor: AppColors.primaryBg,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBg,
            elevation: 0,
            title: Text(
              'My Nutrition',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No meal plan assigned yet.\nAsk your trainer to assign a diet plan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 15, color: AppColors.secondaryText, height: 1.4),
              ),
            ),
          ),
        ),
      );
    }

    final meals = _blocksFromPlan(diet);
    final itemCount = _itemCount(meals);
    final logged = _loggedFor(diet.id, itemCount);
    final macros = _macrosFromLogged(meals, logged);
    final consumed = macros.kcal;
    final goal = diet.computedCalories;
    final waterGlasses = ref.watch(memberWaterGlassesProvider);

    return RoleGuard(
      allowedRoles: const ['MEMBER'],
      fallback: const _AccessDenied(),
      child: Scaffold(
        backgroundColor: AppColors.primaryBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBg,
          elevation: 0,
          title: Text(
            'My Nutrition',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showMacroInfo(context),
              icon: const Icon(Icons.info_outline_rounded, color: AppColors.primaryText),
              tooltip: 'Macro guide',
            ),
          ],
        ),
        body: MemberPhaseViewport(
          expandChild: true,
          emptyMessage: 'No nutrition data in this preview state.',
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              _DailySummaryCard(
                consumed: consumed,
                goal: goal,
                proteinG: diet.proteinG,
                carbsG: diet.carbsG,
                fatsG: diet.fatsG,
                proteinCur: macros.protein,
                carbsCur: macros.carbs,
                fatCur: macros.fat,
                waterGlassesFilled: waterGlasses,
                onWaterGlassTap: (index) {
                  final current = ref.read(memberWaterGlassesProvider);
                  ref.read(memberWaterGlassesProvider.notifier).state =
                      index < current ? index : index + 1;
                },
              ),
              const SizedBox(height: 16),
              ..._buildMealTiles(meals, diet.id, logged),
              const SizedBox(height: 16),
              _PlanFooterCard(
                trainerName: membership.trainerName,
                planTitle: diet.title,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMealTiles(List<_MealBlockData> mealBlocks, String dietId, List<bool> logged) {
    var flat = 0;
    final out = <Widget>[];
    final count = _itemCount(mealBlocks);
    for (var mi = 0; mi < mealBlocks.length; mi++) {
      final m = mealBlocks[mi];
      out.add(
        _MealExpansionTile(
          data: m,
          flatBaseIndex: flat,
          logged: logged,
          onToggleLog: (i) => _toggleLog(i, dietId, count),
        ),
      );
      flat += m.items.length;
      if (mi < mealBlocks.length - 1) {
        out.add(const SizedBox(height: 12));
      }
    }
    return out;
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
          'Nutrition plans are available for members only.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.secondaryText),
        ),
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({
    required this.consumed,
    required this.goal,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.proteinCur,
    required this.carbsCur,
    required this.fatCur,
    required this.waterGlassesFilled,
    required this.onWaterGlassTap,
  });

  final int consumed;
  final int goal;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final double proteinCur;
  final double carbsCur;
  final double fatCur;
  final int waterGlassesFilled;
  final void Function(int index) onWaterGlassTap;

  @override
  Widget build(BuildContext context) {
    final frac = goal <= 0 ? 0.0 : consumed / goal;
    final pGoal = proteinG.toDouble();
    final cGoal = carbsG.toDouble();
    final fGoal = fatsG.toDouble();
    final pCur = proteinCur;
    final cCur = carbsCur;
    final fCur = fatCur;

    const glassesTotal = 8;
    final glassesFilled = waterGlassesFilled.clamp(0, glassesTotal);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(240, 240),
                  painter: _CalorieRingPainter(progress: frac.clamp(0.0, 1.0)),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$consumed',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      'kcal',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$goal kcal goal',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _macroBarRow(
            label: 'Protein',
            current: pCur,
            goal: pGoal,
            color: _kGreen,
            display: '${pCur.toInt()}g / ${pGoal.toInt()}g',
          ),
          const SizedBox(height: 12),
          _macroBarRow(
            label: 'Carbs',
            current: cCur,
            goal: cGoal,
            color: _kOrange,
            display: '${cCur.toInt()}g / ${cGoal.toInt()}g',
          ),
          const SizedBox(height: 12),
          _macroBarRow(
            label: 'Fat',
            current: fCur,
            goal: fGoal,
            color: _kBlueGrey,
            display: '${fCur.toInt()}g / ${fGoal.toInt()}g',
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(glassesTotal, (i) {
                  final filled = i < glassesFilled;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => onWaterGlassTap(i),
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        Icons.water_drop_rounded,
                        size: 28,
                        color: filled ? _kGreen : _kTrack,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$glassesFilled / $glassesTotal glasses today',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }

  static Widget _macroBarRow({
    required String label,
    required double current,
    required double goal,
    required Color color,
    required String display,
  }) {
    final v = goal <= 0 ? 0.0 : (current / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
            Text(display, style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: v,
            minHeight: 8,
            backgroundColor: _kTrack,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  _CalorieRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    const stroke = 14.0;
    final trackPaint = Paint()
      ..color = _kTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, r - stroke / 2, trackPaint);

    final sweep = 2 * math.pi * progress;
    final arcPaint = Paint()
      ..color = _kOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - stroke / 2),
      -math.pi / 2,
      sweep,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CalorieRingPainter oldDelegate) => oldDelegate.progress != progress;
}

class _MealExpansionTile extends StatelessWidget {
  const _MealExpansionTile({
    required this.data,
    required this.flatBaseIndex,
    required this.logged,
    required this.onToggleLog,
  });

  final _MealBlockData data;
  final int flatBaseIndex;
  final List<bool> logged;
  final void Function(int flatIndex) onToggleLog;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: data.initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          backgroundColor: _kCard,
          collapsedBackgroundColor: _kCard,
          iconColor: AppColors.secondaryText,
          collapsedIconColor: AppColors.secondaryText,
          title: Row(
            children: [
              Text(data.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.title,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              'Total: ${data.totalKcal} kcal',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
            ),
          ),
          children: [
            for (var i = 0; i < data.items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MealItemRow(
                  item: data.items[i],
                  logged: logged[flatBaseIndex + i],
                  onToggleLog: () => onToggleLog(flatBaseIndex + i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Color _dotColor(_DotKind k) {
  switch (k) {
    case _DotKind.carb:
      return _kOrange;
    case _DotKind.protein:
      return _kGreen;
    case _DotKind.veg:
      return const Color(0xFF5A8F58);
    case _DotKind.balanced:
      return _kBlueGrey;
  }
}

class _MealItemRow extends StatelessWidget {
  const _MealItemRow({
    required this.item,
    required this.logged,
    required this.onToggleLog,
  });

  final _MealItemData item;
  final bool logged;
  final VoidCallback onToggleLog;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _dotColor(item.dot), shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
              ),
              const SizedBox(height: 2),
              Text(
                item.quantity,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText),
              ),
              if (item.chip != null || item.workoutBadge != null) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (item.chip != null)
                      _smallChip(item.chip!, _kOrange.withValues(alpha: 0.25), _kOrange),
                    if (item.workoutBadge != null)
                      _smallChip(
                        item.workoutBadge == _WorkoutBadgeKind.pre ? 'Pre-workout' : 'Post-workout',
                        item.workoutBadge == _WorkoutBadgeKind.pre
                            ? _kOrange.withValues(alpha: 0.22)
                            : _kGreen.withValues(alpha: 0.2),
                        item.workoutBadge == _WorkoutBadgeKind.pre ? _kOrange : _kGreen,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${item.kcal} kcal',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: _kOrange),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggleLog,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _LogCheckbox(logged: logged),
            ),
          ),
        ),
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: logged ? 0.45 : 1,
      child: row,
    );
  }

  static Widget _smallChip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.45)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _LogCheckbox extends StatelessWidget {
  const _LogCheckbox({required this.logged});

  final bool logged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: logged ? _kTrack.withValues(alpha: 0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: logged ? _kTrack : AppColors.border, width: 2),
      ),
      alignment: Alignment.center,
      child: logged
          ? Icon(Icons.check, size: 16, color: AppColors.secondaryText.withValues(alpha: 0.8))
          : null,
    );
  }
}

class _PlanFooterCard extends ConsumerWidget {
  const _PlanFooterCard({required this.trainerName, required this.planTitle});

  final String trainerName;
  final String planTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canMessageTrainer = ref.watch(memberCanUseChatProvider);
    final now = DateTime.now();
    final end = DateTime(now.year, now.month + 1, 0);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final validLabel =
        '${months[now.month - 1]} ${now.day} – ${months[end.month - 1]} ${end.day}, ${end.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kBottomCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$planTitle · assigned by $trainerName',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryText, height: 1.35),
          ),
          const SizedBox(height: 8),
          Text(
            'Valid: $validLabel',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
          ),
          if (canMessageTrainer) ...[
            const SizedBox(height: 16),
            FitCoreButton(
              label: 'Message Trainer',
              variant: FitCoreButtonVariant.secondary,
              onPressed: () => context.push('/member/messages'),
            ),
          ],
        ],
      ),
    );
  }
}
