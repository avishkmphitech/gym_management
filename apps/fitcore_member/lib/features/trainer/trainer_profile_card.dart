import 'package:flutter/material.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../models/user_model.dart';

/// Trainer profile header wired to [UserModel] from auth (trainer-only widget).
class TrainerProfileCard extends StatelessWidget {
  const TrainerProfileCard({
    super.key,
    required this.user,
    required this.pushEnabled,
    required this.onOpenNotifications,
    required this.onNotificationPrefs,
    required this.onSignOut,
  });

  final UserModel? user;
  final bool pushEnabled;
  final VoidCallback onOpenNotifications;
  final VoidCallback onNotificationPrefs;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? 'Trainer';
    final email = user?.email ?? '';
    final gym = user?.gymName ?? 'Gym';
    final role = user?.role ?? 'TRAINER';
    final permissions = user?.permissions ?? const <String>[];
    final initials = name
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FitCoreCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.cardBg,
                child: Text(initials, style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
                    if (email.isNotEmpty)
                      Text(email, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text('$role · $gym', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Push notifications ${pushEnabled ? 'on' : 'off'} (mock)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: pushEnabled ? AppColors.primaryAccent : AppColors.secondaryText,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (permissions.isNotEmpty) ...[
          const SizedBox(height: 12),
          FitCoreCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Permissions', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: permissions.map((p) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                      ),
                      child: Text(p, style: Theme.of(context).textTheme.bodySmall),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        FitCoreButton(
          label: 'Notifications inbox',
          icon: Icons.notifications_outlined,
          onPressed: onOpenNotifications,
        ),
        const SizedBox(height: 12),
        FitCoreButton(
          label: 'Notification settings',
          variant: FitCoreButtonVariant.secondary,
          icon: Icons.tune_outlined,
          onPressed: onNotificationPrefs,
        ),
        const SizedBox(height: 12),
        FitCoreButton(
          label: 'Sign out',
          variant: FitCoreButtonVariant.danger,
          onPressed: () => onSignOut(),
        ),
      ],
    );
  }
}
