import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../providers/chat_provider.dart';
import '../../providers/member_provider.dart';
import '../../services/auth_service.dart';
import '../../providers/member_notifications_provider.dart';
import '../../features/member/member_weekly_progress_card.dart';
import '../../widgets/member_phase_viewport.dart';
import '../../widgets/notification_bell_button.dart';
import '../../widgets/role_guard.dart';

/// Member home dashboard — MEMBER role only ([RoleGuard]).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RoleGuard(
      allowedRoles: const ['MEMBER'],
      fallback: const _AccessDenied(),
      child: Scaffold(
        backgroundColor: AppColors.primaryBg,
        body: SafeArea(
          child: MemberPhaseViewport(
            expandChild: true,
            emptyMessage: 'Your dashboard has no content for this preview state.',
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                const _TopBar(),
                const SizedBox(height: 20),
                const _QuickStatsRow(),
                const SizedBox(height: 20),
                const _MembershipCard(),
                const SizedBox(height: 16),
                const _TodaysWorkoutCard(),
                const SizedBox(height: 16),
                const _NutritionCard(),
                const SizedBox(height: 20),
                _WeeklyProgressSection(),
                const SizedBox(height: 20),
                const _RecentAttendanceSection(),
              ],
            ),
          ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 48, color: AppColors.secondaryText.withValues(alpha: 0.8)),
              const SizedBox(height: 12),
              Text(
                'This home is for members only.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider);
    final first = memberGreetingName(user?.name);
    final initials = memberInitials(user?.name);
    final unread = ref.watch(memberUnreadNotificationsCountProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '${timeGreeting()}, $first 👋',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: const Color(0xFFF5F5F2),
            ),
          ),
        ),
        NotificationBellButton(
          unreadCount: unread,
          onTap: () => context.push('/member/notifications'),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => context.go('/member/profile'),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF3E7C59),
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeeklyProgressSection extends ConsumerWidget {
  const _WeeklyProgressSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(memberWeeklyAnalyticsProvider);
    return MemberWeeklyProgressCard(analytics: analytics);
  }
}

class _QuickStatsRow extends ConsumerWidget {
  const _QuickStatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(memberMembershipProvider);
    final progress = ref.watch(memberProgressProvider);
    final month = DateTime.now();
    final summary = ref.watch(memberMonthAttendanceSummaryProvider(month));
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final expiryLabel = '${months[membership.expiresAt.month - 1]} ${membership.expiresAt.day}';

    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _StatCard(
            icon: '🔥',
            label: 'Attendance',
            value: '${progress?.attendancePercent ?? summary.present}%',
            valueColor: AppColors.primaryAccent,
          ),
          const SizedBox(width: 12),
          _StatCard(
            icon: '📅',
            label: 'This Month',
            value: '${summary.present} check-ins',
            valueColor: AppColors.primaryText,
          ),
          const SizedBox(width: 12),
          _StatCard(icon: '⭐', label: 'My Plan', value: membership.tier, valueColor: AppColors.secondaryAccent),
          const SizedBox(width: 12),
          _StatCard(icon: '⏰', label: 'Expires', value: expiryLabel, valueColor: AppColors.warning),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText, height: 1.2),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: valueColor, height: 1.1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends ConsumerWidget {
  const _MembershipCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membership = ref.watch(memberMembershipProvider);
    final canMessageTrainer = ref.watch(memberCanUseChatProvider);
    final progress = membership.progressFraction;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  membership.planLabel,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                ),
                child: Text(
                  membership.status,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${membership.gymName} · ID ${membership.memberDeskId}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF444444),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3E7C59)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${membership.daysRemaining} of ${membership.daysTotal} days remaining',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 12),
          Text(
            'Trainer: ${membership.trainerName}',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.primaryText),
          ),
          if (canMessageTrainer) ...[
            const SizedBox(height: 12),
            FitCoreButton(
              label: 'Message trainer',
              variant: FitCoreButtonVariant.secondary,
              icon: Icons.chat_bubble_outline,
              onPressed: () => context.push('/member/messages'),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Renewals are updated by reception at the desk — not in this app.',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _TodaysWorkoutCard extends ConsumerWidget {
  const _TodaysWorkoutCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(memberWeeklyWorkoutPlanProvider);
    final todayIndex = DateTime.now().weekday - 1;
    final day = plan?.days[todayIndex.clamp(0, 6)];
    final title = day?.isRestDay == true
        ? (day?.title ?? 'Rest day')
        : (day?.title ?? plan?.name ?? 'No workout assigned');
    final subtitle = day?.isRestDay == true
        ? (day?.focus ?? 'Recovery')
        : '${day?.durationMin ?? 0} mins · ${day?.exercises.length ?? 0} exercises';
    final isRest = day?.isRestDay ?? true;
    final chips = isRest
        ? <String>['Rest', 'Recovery']
        : (day?.exercises.take(3).map((e) => e.name).toList() ?? <String>[]);
    final extraCount = (!isRest && day != null && day.exercises.length > 3) ? day.exercises.length - 3 : 0;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's Workout 💪",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/member/workouts'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3E7C59),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in chips) _workoutChip(c),
              if (extraCount > 0) _workoutChip('+$extraCount more'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (plan == null || isRest) ? null : () => context.go('/member/workouts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3E7C59),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Start Workout', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _workoutChip(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.primaryText)),
  );
}

class _NutritionCard extends ConsumerWidget {
  const _NutritionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diet = ref.watch(memberDietPlanProvider);
    final goal = diet?.computedCalories ?? 2200;
    final protein = diet?.proteinG ?? 160;
    final consumedEst = (goal * 0.84).round();

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
          Row(
            children: [
              Expanded(
                child: Text(
                  "Today's Nutrition 🥗",
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                ),
              ),
              TextButton(
                onPressed: () => context.go('/member/diet'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3E7C59),
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View Plan',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          if (diet != null) ...[
            const SizedBox(height: 6),
            Text(
              diet.title,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.secondaryText),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MacroMini(
                  label: 'Calories',
                  value: '$consumedEst/$goal kcal',
                  color: AppColors.secondaryAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroMini(
                  label: 'Protein',
                  value: '${(protein * 0.75).round()}/$protein g',
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MacroMini(
                  label: 'Water',
                  value: '6/8 glasses',
                  color: const Color(0xFF7A8B99),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroMini extends StatelessWidget {
  const _MacroMini({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryText)),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color, height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _RecentAttendanceSection extends ConsumerWidget {
  const _RecentAttendanceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(memberRecentCheckInsProvider);
    final gym = ref.watch(memberMembershipProvider).gymName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Check-ins',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/member/attendance'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF3E7C59),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No check-ins yet. Generate QR on the Attendance tab.',
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.secondaryText),
                  ),
                )
              else
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: _AttendanceRow(
                    date: entries[i].title,
                    gym: gym,
                    time: entries[i].subtitle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.date,
    required this.gym,
    required this.time,
  });

  final String date;
  final String gym;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
              const SizedBox(height: 2),
              Text(gym, style: GoogleFonts.inter(fontSize: 12, color: AppColors.secondaryText)),
            ],
          ),
        ),
        Text(time, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondaryText)),
      ],
    );
  }
}
