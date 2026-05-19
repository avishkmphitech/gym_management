import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../widgets/trainer_permission_gate.dart';

/// Dashboard shortcuts for trainer workflows (trainer-only; does not touch member UI).
class TrainerQuickActions extends StatelessWidget {
  const TrainerQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick actions', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TrainerPermissionGate(
                permission: 'plans:write',
                child: _ActionTile(
                  icon: Icons.calendar_view_week_outlined,
                  label: 'Week plan',
                  onTap: () => context.push('/trainer/plans/week/create'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TrainerPermissionGate(
                permission: 'diet:write',
                child: _ActionTile(
                  icon: Icons.restaurant_outlined,
                  label: 'Meal plan',
                  onTap: () => context.push('/trainer/plans/diet/create'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TrainerPermissionGate(
                permission: 'plans:write',
                child: _ActionTile(
                  icon: Icons.person_add_outlined,
                  label: 'Assign workout',
                  onTap: () => context.push('/trainer/plans/week/assign'),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TrainerPermissionGate(
                permission: 'diet:write',
                child: _ActionTile(
                  icon: Icons.restaurant_menu_outlined,
                  label: 'Assign meal',
                  onTap: () => context.push('/trainer/plans/diet/assign'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TrainerPermissionGate(
          permission: 'schedule:write',
          child: _ActionTile(
            icon: Icons.event_available_outlined,
            label: 'Add session',
            fullWidth: true,
            onTap: () => context.push('/trainer/schedule/create'),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: FitCoreCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            mainAxisAlignment: fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryAccent, size: 22),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
