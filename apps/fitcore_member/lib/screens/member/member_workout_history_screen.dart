import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../providers/member_provider.dart';
import '../../widgets/role_guard.dart';

/// Full workout completion history for the signed-in member.
class MemberWorkoutHistoryScreen extends ConsumerWidget {
  const MemberWorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(memberProgressProvider)?.workoutHistory ?? const [];
    final plan = ref.watch(memberWeeklyWorkoutPlanProvider);

    return RoleGuard(
      allowedRoles: const ['MEMBER'],
      child: Scaffold(
        backgroundColor: AppColors.primaryBg,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBg,
          title: Text(
            'Workout history',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (plan != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current plan',
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.name,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Back to today\'s workout'),
                    ),
                  ],
                ),
              ),
            if (history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Text(
                    'No completed sessions logged yet.',
                    style: GoogleFonts.inter(color: AppColors.secondaryText),
                  ),
                ),
              )
            else
              ...history.map(
                (h) => Card(
                  color: const Color(0xFF222222),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      h.planName,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primaryText),
                    ),
                    subtitle: Text(h.dateLabel, style: GoogleFonts.inter(color: AppColors.secondaryText)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (h.completed ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        h.completed ? 'Done' : 'Missed',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: h.completed ? AppColors.success : AppColors.error,
                        ),
                      ),
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
