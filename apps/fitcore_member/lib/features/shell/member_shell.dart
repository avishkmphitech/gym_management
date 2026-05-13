import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../core/widgets/phase_chips.dart';
import '../../data/mock/member_mock_data.dart';
import '../../providers/mock_ui_phase_provider.dart';
import '../../services/auth_service.dart';
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

class DietScreen extends ConsumerWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Diet plan')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhaseChips(phase: phase, onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p)),
            const SizedBox(height: 16),
            Expanded(child: _MealPhaseBody(phase: phase)),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.cardBg,
                child: Text('AK', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aarav Khanna', style: Theme.of(context).textTheme.titleLarge),
                    Text('Member · gym_id: apex-iron-01', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FitCoreButton(label: 'Edit profile', variant: FitCoreButtonVariant.secondary, onPressed: () {}),
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
    );
  }
}

class _MealPhaseBody extends StatelessWidget {
  const _MealPhaseBody({required this.phase});

  final MockUiPhase phase;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case MockUiPhase.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
      case MockUiPhase.empty:
        return Center(child: Text('No meals scheduled for today.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center));
      case MockUiPhase.error:
        return Center(child: Text('Diet sync error (mock).', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error)));
      case MockUiPhase.filled:
        return ListView.separated(
          itemCount: memberMeals.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final m = memberMeals[i];
            return FitCoreCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.tableBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(m.timeLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryText)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.primaryText)),
                        const SizedBox(height: 4),
                        Text('${m.calories} kcal', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
    }
  }
}
