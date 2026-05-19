import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../providers/member_provider.dart';

/// Weekly completion bars from [memberWeeklyAnalyticsProvider] (additive home card).
class MemberWeeklyProgressCard extends StatelessWidget {
  const MemberWeeklyProgressCard({super.key, required this.analytics});

  final MemberWeeklyAnalytics analytics;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final values = analytics.weeklyCompletion;
    if (values.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly progress',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
          const SizedBox(height: 6),
          Text(
            '${analytics.workoutsCompleted} / ${analytics.workoutsAssigned} workouts · ${analytics.attendancePercent}% attendance',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(values.length.clamp(0, 7), (i) {
              final v = (values[i] / 100).clamp(0.0, 1.0);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: i == 0 ? 0 : 4, right: i == values.length - 1 ? 0 : 4),
                  child: Column(
                    children: [
                      Container(
                        height: 48 * v + 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        i < _labels.length ? _labels[i] : '',
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.secondaryText),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
