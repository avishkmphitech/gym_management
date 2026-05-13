import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../core/widgets/phase_chips.dart';
import '../../providers/mock_ui_phase_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/role_shell.dart';

/// Receptionist area — bottom nav provided by [RoleShell] in router.
class ReceptionistShell extends StatelessWidget {
  const ReceptionistShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return RoleShell(navigationShell: navigationShell);
  }
}

class ReceptionCheckInScreen extends ConsumerWidget {
  const ReceptionCheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scan member QR or search by phone (mock).', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            PhaseChips(phase: phase, onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p)),
            const SizedBox(height: 16),
            Expanded(
              child: switch (phase) {
                MockUiPhase.loading => const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent)),
                MockUiPhase.empty => Center(
                    child: Text('No check-ins in the last hour.', style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  ),
                MockUiPhase.error => Center(
                    child: Text('Scanner service unavailable.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error)),
                  ),
                MockUiPhase.filled => ListView(
                    children: const [
                      FitCoreCard(
                        child: ListTile(
                          leading: Icon(Icons.verified_rounded, color: AppColors.success),
                          title: Text('M-20481 · Aarav Khanna'),
                          subtitle: Text('Checked in · 6:42 AM'),
                        ),
                      ),
                      SizedBox(height: 12),
                      FitCoreCard(
                        child: ListTile(
                          leading: Icon(Icons.verified_rounded, color: AppColors.success),
                          title: Text('M-20102 · Priya Shah'),
                          subtitle: Text('Checked in · 6:38 AM'),
                        ),
                      ),
                    ],
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReceptionMembersLookupScreen extends ConsumerWidget {
  const ReceptionMembersLookupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Members')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhaseChips(phase: phase, onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p)),
            const SizedBox(height: 16),
            Expanded(
              child: switch (phase) {
                MockUiPhase.loading => const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent)),
                MockUiPhase.empty => Center(child: Text('No members match.', style: Theme.of(context).textTheme.bodyMedium)),
                MockUiPhase.error => Center(child: Text('Lookup failed.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error))),
                MockUiPhase.filled => ListView(
                    children: [
                      FitCoreCard(
                        child: ListTile(
                          title: Text('Aarav Khanna', style: Theme.of(context).textTheme.titleMedium),
                          subtitle: const Text('Plan: Pro · Status: Active'),
                          trailing: Icon(Icons.chevron_right, color: AppColors.secondaryText.withValues(alpha: 0.8)),
                        ),
                      ),
                    ],
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReceptionAttendanceLogScreen extends ConsumerWidget {
  const ReceptionAttendanceLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance log')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhaseChips(phase: phase, onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p)),
            const SizedBox(height: 16),
            Expanded(
              child: switch (phase) {
                MockUiPhase.loading => const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent)),
                MockUiPhase.empty => Center(child: Text('No log entries today.', style: Theme.of(context).textTheme.bodyMedium)),
                MockUiPhase.error => Center(child: Text('Log sync error.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error))),
                MockUiPhase.filled => ListView(
                    children: const [
                      FitCoreCard(child: ListTile(title: Text('06:30 · Front desk'), subtitle: Text('12 check-ins'))),
                      SizedBox(height: 12),
                      FitCoreCard(child: ListTile(title: Text('Yesterday'), subtitle: Text('186 check-ins'))),
                    ],
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReceptionProfileScreen extends ConsumerWidget {
  const ReceptionProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Reception · Apex Iron Gym', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
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
