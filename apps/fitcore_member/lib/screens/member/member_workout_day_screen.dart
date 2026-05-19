import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../data/mock/mock_models.dart';
import '../../providers/member_provider.dart';
import '../../widgets/role_guard.dart';

/// Detail view for one day in the member's assigned week plan.
class MemberWorkoutDayScreen extends ConsumerWidget {
  const MemberWorkoutDayScreen({super.key, required this.dayIndex});

  final int dayIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(memberWeeklyWorkoutPlanProvider);
    final index = dayIndex.clamp(0, 6);
    final MockWeeklyDayPlan? day = plan != null && plan.days.length > index ? plan.days[index] : null;

    return RoleGuard(
      allowedRoles: const ['MEMBER'],
      child: Scaffold(
        backgroundColor: AppColors.primaryBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBg,
          title: Text(
            day?.title ?? day?.dayLabel ?? 'Workout day',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
        ),
        body: day == null
            ? Center(
                child: Text(
                  'No plan assigned.',
                  style: GoogleFonts.inter(color: AppColors.secondaryText),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    '${day.dayLabel} · ${plan?.name ?? ''}',
                    style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText),
                  ),
                  if (day.focus != null) ...[
                    const SizedBox(height: 8),
                    Text(day.focus!, style: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryText)),
                  ],
                  const SizedBox(height: 20),
                  if (day.isRestDay)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Rest day — no exercises scheduled.',
                        style: GoogleFonts.inter(color: AppColors.secondaryText),
                      ),
                    )
                  else
                    ...day.exercises.map(
                      (e) => Card(
                        color: const Color(0xFF2B2B2B),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          title: Text(
                            e.name,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryText),
                          ),
                          subtitle: Text(
                            '${e.sets} sets × ${e.reps} reps${e.notes != null ? ' · ${e.notes}' : ''}',
                            style: GoogleFonts.inter(color: AppColors.secondaryText),
                          ),
                          leading: const Icon(Icons.fitness_center, color: AppColors.primaryAccent),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
