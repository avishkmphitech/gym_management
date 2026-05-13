import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../core/widgets/phase_chips.dart';
import '../../data/mock/trainer_mock_data.dart';
import '../../providers/mock_ui_phase_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/role_shell.dart';

class TrainerShell extends StatelessWidget {
  const TrainerShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return RoleShell(navigationShell: navigationShell);
  }
}

class TrainerHomeScreen extends ConsumerWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Hi, Coach Riya', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text('Apex Iron Gym · gym_id: apex-iron-01',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          PhaseChips(
              phase: phase,
              onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p)),
          const SizedBox(height: 16),
          _TrainerHomeBody(phase: phase),
        ],
      ),
    );
  }
}

class _TrainerHomeBody extends StatelessWidget {
  const _TrainerHomeBody({required this.phase});

  final MockUiPhase phase;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case MockUiPhase.loading:
        return const Center(
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: CircularProgressIndicator(color: AppColors.primaryAccent)));
      case MockUiPhase.empty:
        return FitCoreCard(
          child: Text('No sessions scheduled.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
        );
      case MockUiPhase.error:
        return FitCoreCard(
          child: Text('Could not sync trainer dashboard.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.error)),
        );
      case MockUiPhase.filled:
        return FitCoreCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today',
                  style:
                      Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
              const SizedBox(height: 10),
              ...trainerSchedule.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.event,
                          color: AppColors.secondaryAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppColors.primaryText)),
                            Text('${s.whenLabel} · ${s.location}',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

class TrainerMembersScreen extends ConsumerWidget {
  const TrainerMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Members')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhaseChips(
                phase: phase,
                onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p)),
            const SizedBox(height: 16),
            Expanded(child: _MembersBody(phase: phase)),
          ],
        ),
      ),
    );
  }
}

class _MembersBody extends StatelessWidget {
  const _MembersBody({required this.phase});
  final MockUiPhase phase;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case MockUiPhase.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
      case MockUiPhase.empty:
        return Center(child: Text('No members assigned.', style: Theme.of(context).textTheme.bodyMedium));
      case MockUiPhase.error:
        return Center(child: Text('Roster failed to load.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error)));
      case MockUiPhase.filled:
        return ListView.separated(
          itemCount: assignedMembers.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final m = assignedMembers[i];
            return FitCoreCard(
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: AppColors.cardBg, child: Text(m.name.split(' ').map((e) => e[0]).take(2).join(), style: Theme.of(context).textTheme.bodySmall)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                      Text('${m.plan} · ${m.goal}', style: Theme.of(context).textTheme.bodyMedium),
                      Text(m.lastCheckIn, style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                  FitCoreButton(label: 'Open', variant: FitCoreButtonVariant.small, expanded: false, onPressed: () {}),
                ],
              ),
            );
          },
        );
    }
  }
}

class TrainerWorkoutsScreen extends ConsumerWidget {
  const TrainerWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Workout plans')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PhaseChips(phase: phase, onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p)),
          const SizedBox(height: 16),
          Expanded(child: _WorkoutsBody(phase: phase)),
        ]),
      ),
    );
  }
}

class _WorkoutsBody extends StatelessWidget {
  const _WorkoutsBody({required this.phase});
  final MockUiPhase phase;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case MockUiPhase.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
      case MockUiPhase.empty:
        return Center(child: Text('No templates yet.', style: Theme.of(context).textTheme.bodyMedium));
      case MockUiPhase.error:
        return Center(child: Text('Library sync error.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error)));
      case MockUiPhase.filled:
        return ListView.separated(
          itemCount: trainerWorkoutTemplates.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final w = trainerWorkoutTemplates[i];
            return FitCoreCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(w.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                Text('${w.durationMin} min · ${w.focus}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                FitCoreButton(label: 'Assign to member', onPressed: () {}),
              ]),
            );
          },
        );
    }
  }
}

class TrainerScheduleScreen extends ConsumerWidget {
  const TrainerScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhaseChips(phase: phase, onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p)),
            const SizedBox(height: 16),
            Expanded(child: _ScheduleBody(phase: phase)),
          ],
        ),
      ),
    );
  }
}

class _ScheduleBody extends StatelessWidget {
  const _ScheduleBody({required this.phase});
  final MockUiPhase phase;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case MockUiPhase.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
      case MockUiPhase.empty:
        return Center(child: Text('No upcoming sessions.', style: Theme.of(context).textTheme.bodyMedium));
      case MockUiPhase.error:
        return Center(child: Text('Calendar sync failed.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error)));
      case MockUiPhase.filled:
        return ListView.separated(
          itemCount: trainerSchedule.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final s = trainerSchedule[i];
            return FitCoreCard(
              child: ListTile(
                leading: const Icon(Icons.event, color: AppColors.secondaryAccent),
                title: Text(s.title, style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text('${s.whenLabel} · ${s.location}', style: Theme.of(context).textTheme.bodyMedium),
              ),
            );
          },
        );
    }
  }
}

class TrainerProfileScreen extends ConsumerWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            const CircleAvatar(radius: 36, backgroundColor: AppColors.cardBg, child: Text('RK')),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Riya Kapoor', style: Theme.of(context).textTheme.titleLarge),
                Text('Trainer · Firebase push: enabled (mock)', style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
          ]),
          const SizedBox(height: 20),
          FitCoreButton(label: 'Notification prefs', variant: FitCoreButtonVariant.secondary, onPressed: () {}),
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

