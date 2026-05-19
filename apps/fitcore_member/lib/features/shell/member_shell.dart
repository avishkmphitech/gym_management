import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../providers/chat_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/push_notification_prefs_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/member_phase_viewport.dart';
import '../../widgets/role_shell.dart';

/// Member shell — bottom navigation from [RoleShell] (MEMBER tabs).
class MemberShell extends StatelessWidget {
  const MemberShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return RoleShell(navigationShell: navigationShell);
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider);
    final membership = ref.watch(memberMembershipProvider);
    final weekPlan = ref.watch(memberWeeklyWorkoutPlanProvider);
    final dietPlan = ref.watch(memberDietPlanProvider);
    final canMessageTrainer = ref.watch(memberCanUseChatProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: MemberPhaseViewport(
        expandChild: true,
        emptyMessage: 'Profile hidden in this preview state.',
        child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.cardBg,
                child: Text(
                  memberInitials(user?.name),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'Member',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
                    ),
                    Text(
                      '${user?.email ?? ''} · ${membership.gymName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Desk ID ${membership.memberDeskId} · ${membership.planLabel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileInfoTile(
            icon: Icons.card_membership_outlined,
            title: 'Membership',
            subtitle:
                '${membership.status} · ${membership.daysRemaining} days left · renew at reception desk',
          ),
          _ProfileInfoTile(
            icon: Icons.fitness_center_outlined,
            title: 'Workout plan',
            subtitle: weekPlan?.name ?? 'Not assigned',
          ),
          _ProfileInfoTile(
            icon: Icons.restaurant_outlined,
            title: 'Meal plan',
            subtitle: dietPlan?.title ?? 'Not assigned',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            tileColor: AppColors.cardBg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: const Text('Push notifications', style: TextStyle(color: AppColors.primaryText)),
            subtitle: const Text('Mock — no Firebase in prototype', style: TextStyle(color: AppColors.secondaryText)),
            value: ref.watch(pushNotificationPrefsProvider),
            activeThumbColor: AppColors.primaryAccent,
            onChanged: (v) => ref.read(pushNotificationPrefsProvider.notifier).setEnabled(v),
          ),
          if (canMessageTrainer) ...[
            const SizedBox(height: 12),
            FitCoreButton(
              label: 'Message trainer',
              icon: Icons.chat_bubble_outline,
              onPressed: () => context.push('/member/messages'),
            ),
          ],
          const SizedBox(height: 12),
          FitCoreButton(
            label: 'Edit profile',
            variant: FitCoreButtonVariant.secondary,
            onPressed: () => context.push('/member/profile/edit'),
          ),
          const SizedBox(height: 12),
          FitCoreButton(
            label: 'Sign out',
            variant: FitCoreButtonVariant.danger,
            onPressed: () async {
              await ref.read(authServiceProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: AppColors.primaryAccent),
        title: Text(title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.secondaryText)),
      ),
    );
  }
}
