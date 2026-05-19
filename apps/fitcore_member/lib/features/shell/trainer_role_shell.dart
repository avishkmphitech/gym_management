import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../core/widgets/phase_chips.dart';
import '../../data/mock/mock_models.dart';
import '../../models/user_model.dart';
import '../../data/mock/trainer_mock_data.dart';
import '../../providers/mock_ui_phase_provider.dart';
import '../../providers/trainer_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/role_shell.dart';
import '../trainer/trainer_quick_actions.dart';
import '../trainer/trainer_profile_card.dart';
import '../../providers/trainer_notifications_provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/notification_bell_button.dart';
import '../../widgets/trainer_assignment_history_section.dart';
import '../../widgets/trainer_permission_gate.dart';
import '../../widgets/trainer_schedule_calendar.dart';

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
    final user = ref.watch(authServiceProvider);
    final trainer = ref.watch(trainerProvider);
    final firstName = user?.name.split(' ').first ?? 'Coach';

    final unread = ref.watch(trainerNotificationsProvider).unreadCount;
    final chatUnread = ref.watch(trainerChatUnreadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
        actions: [
          _MessagesAppBarButton(unreadCount: chatUnread),
          NotificationBellButton(
            unreadCount: unread,
            onTap: () => context.push('/trainer/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Hi, $firstName', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            '${user?.gymName ?? 'Apex Iron Gym'} · ${user?.gymId ?? 'gym_apex_iron'}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          PhaseChips(
            phase: phase,
            onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
          ),
          const SizedBox(height: 16),
          if (phase == MockUiPhase.filled) ...[
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.go('/trainer/members'),
                    child: _StatChip(
                      label: 'Members',
                      value: '${assignedMembers.length}',
                      icon: Icons.groups_outlined,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatChip(
                    label: 'Sessions',
                    value: '${trainer.sessions.length}',
                    icon: Icons.event_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatChip(
                    label: 'Plans',
                    value: '${trainer.weeklyWorkoutPlans.length}',
                    icon: Icons.assignment_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TrainerQuickActions(),
            const SizedBox(height: 16),
          ],
          _TrainerHomeBody(phase: phase, sessions: trainer.sessions),
          if (phase == MockUiPhase.filled) ...[
            const SizedBox(height: 16),
            Text('Assigned members', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            FitCoreCard(
              child: Column(
                children: [
                  for (var i = 0; i < assignedMembers.length; i++) ...[
                    if (i > 0) const Divider(height: 16, color: AppColors.border),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.cardBg,
                        child: Text(
                          assignedMembers[i].name.split(' ').map((e) => e[0]).take(2).join(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      title: Text(assignedMembers[i].name),
                      subtitle: Text(assignedMembers[i].plan),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                      onTap: () => context.push('/trainer/members/${assignedMembers[i].id}'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FitCoreCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondaryAccent, size: 20),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TrainerHomeBody extends StatelessWidget {
  const _TrainerHomeBody({required this.phase, required this.sessions});

  final MockUiPhase phase;
  final List<MockTrainerSession> sessions;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case MockUiPhase.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          ),
        );
      case MockUiPhase.empty:
        return FitCoreCard(
          child: Text(
            'No sessions scheduled.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        );
      case MockUiPhase.error:
        return FitCoreCard(
          child: Text(
            'Could not sync trainer dashboard.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
          ),
        );
      case MockUiPhase.filled:
        return FitCoreCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Upcoming sessions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/trainer/schedule'),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...sessions.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.event, color: AppColors.secondaryAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.title,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.primaryText,
                                  ),
                            ),
                            Text(
                              '${s.whenLabel} · ${s.location}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
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
    final trainer = ref.watch(trainerProvider);

    final chatUnread = ref.watch(trainerChatUnreadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Members'),
        actions: [
          _MessagesAppBarButton(unreadCount: chatUnread),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhaseChips(
              phase: phase,
              onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
            ),
            const SizedBox(height: 16),
            Expanded(child: _MembersBody(phase: phase, trainer: trainer)),
          ],
        ),
      ),
    );
  }
}

class _MembersBody extends StatelessWidget {
  const _MembersBody({required this.phase, required this.trainer});

  final MockUiPhase phase;
  final TrainerState trainer;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case MockUiPhase.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
      case MockUiPhase.empty:
        return Center(
          child: Text('No members assigned.', style: Theme.of(context).textTheme.bodyMedium),
        );
      case MockUiPhase.error:
        return Center(
          child: Text(
            'Roster failed to load.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
          ),
        );
      case MockUiPhase.filled:
        return ListView.separated(
          itemCount: assignedMembers.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final m = assignedMembers[i];
            final workout = trainer.weeklyWorkoutLabelForMember(m.id);
            final diet = trainer.dietLabelForMember(m.id);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push('/trainer/members/${m.id}'),
                borderRadius: BorderRadius.circular(18),
                child: FitCoreCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.cardBg,
                        child: Text(
                          m.name.split(' ').map((e) => e[0]).take(2).join(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                            ),
                            Text('${m.plan} · ${m.goal}', style: Theme.of(context).textTheme.bodyMedium),
                            Text(m.lastCheckIn, style: Theme.of(context).textTheme.bodySmall),
                            if (workout != null || diet != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (workout != null) 'Week plan: $workout',
                                  if (diet != null) 'Meal: $diet',
                                ].join(' · '),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primaryAccent,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryAccent),
                        tooltip: 'Message member',
                        onPressed: () => context.push('/trainer/messages/${m.id}'),
                      ),
                      TrainerPermissionGate(
                        permission: 'diet:write',
                        child: IconButton(
                          icon: const Icon(Icons.restaurant_outlined, color: AppColors.secondaryAccent),
                          tooltip: 'Assign meal plan',
                          onPressed: () => context.push('/trainer/plans/diet/assign?memberId=${m.id}'),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                    ],
                  ),
                ),
              ),
            );
          },
        );
    }
  }
}

class TrainerWorkoutsScreen extends ConsumerStatefulWidget {
  const TrainerWorkoutsScreen({super.key});

  @override
  ConsumerState<TrainerWorkoutsScreen> createState() => _TrainerWorkoutsScreenState();
}

class _TrainerWorkoutsScreenState extends ConsumerState<TrainerWorkoutsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(mockUiPhaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plans'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryAccent,
          labelColor: AppColors.primaryText,
          unselectedLabelColor: AppColors.secondaryText,
          tabs: const [
            Tab(text: 'Week plans'),
            Tab(text: 'Diet'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhaseChips(
              phase: phase,
              onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _WeekPlansBody(phase: phase),
                  _DietPlansBody(phase: phase),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          final isWeek = _tabController.index == 0;
          return TrainerPermissionGate(
            permission: isWeek ? 'plans:write' : 'diet:write',
            child: FloatingActionButton.extended(
              onPressed: () {
                if (isWeek) {
                  context.push('/trainer/plans/week/create');
                } else {
                  context.push('/trainer/plans/diet/create');
                }
              },
              backgroundColor: AppColors.primaryAccent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                isWeek ? 'Create week plan' : 'Create diet plan',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeekPlansBody extends ConsumerWidget {
  const _WeekPlansBody({required this.phase});

  final MockUiPhase phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(trainerProvider).weeklyWorkoutPlans;

    switch (phase) {
      case MockUiPhase.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
      case MockUiPhase.empty:
        return Center(child: Text('No week plans yet.', style: Theme.of(context).textTheme.bodyMedium));
      case MockUiPhase.error:
        return Center(
          child: Text(
            'Library sync error.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
          ),
        );
      case MockUiPhase.filled:
        return ListView(
          children: [
            const TrainerAssignmentHistorySection(type: 'week_workout'),
            ...List.generate(plans.length, (i) {
              final w = plans[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/trainer/plans/week/${w.id}'),
                    borderRadius: BorderRadius.circular(18),
                    child: FitCoreCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  w.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${w.trainingDays} days · ${w.goalFocus}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          TrainerPermissionGate(
                            permission: 'plans:write',
                            child: FitCoreButton(
                              label: 'Assign week to member',
                              onPressed: () => context.push('/trainer/plans/week/assign?weekPlanId=${w.id}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
    }
  }
}

class _DietPlansActionHeader extends StatelessWidget {
  const _DietPlansActionHeader({required this.onCreate, required this.onAssign});

  final VoidCallback onCreate;
  final VoidCallback onAssign;

  @override
  Widget build(BuildContext context) {
    return FitCoreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diet plans', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Build full-day meal schedules and assign them to members.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          FitCoreButton(
            label: 'Create diet plan',
            icon: Icons.add,
            onPressed: onCreate,
          ),
          const SizedBox(height: 10),
          FitCoreButton(
            label: 'Assign meal to member',
            variant: FitCoreButtonVariant.secondary,
            icon: Icons.person_add_outlined,
            onPressed: onAssign,
          ),
        ],
      ),
    );
  }
}

class _DietPlansEmptyState extends StatelessWidget {
  const _DietPlansEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_outlined, size: 56, color: AppColors.secondaryText.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text('No diet plans yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Create breakfast, lunch, dinner, and snack slots — then assign the plan to a member.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TrainerPermissionGate(
              permission: 'diet:write',
              child: FitCoreButton(
                label: 'Create diet plan',
                icon: Icons.add,
                onPressed: onCreate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietPlansBody extends ConsumerWidget {
  const _DietPlansBody({required this.phase});

  final MockUiPhase phase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diets = ref.watch(trainerProvider).dietPlans;

    switch (phase) {
      case MockUiPhase.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
      case MockUiPhase.empty:
        return _DietPlansEmptyState(
          onCreate: () => context.push('/trainer/plans/diet/create'),
        );
      case MockUiPhase.error:
        return Center(
          child: Text(
            'Diet library sync error.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
          ),
        );
      case MockUiPhase.filled:
        return ListView(
          children: [
            _DietPlansActionHeader(
              onCreate: () => context.push('/trainer/plans/diet/create'),
              onAssign: () => context.push('/trainer/plans/diet/assign'),
            ),
            const SizedBox(height: 12),
            const TrainerAssignmentHistorySection(type: 'diet'),
            ...List.generate(diets.length, (i) {
              final d = diets[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/trainer/plans/diet/${d.id}'),
                    borderRadius: BorderRadius.circular(18),
                    child: FitCoreCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  d.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${d.computedCalories} kcal · ${d.mealSlots.length} meals (breakfast, lunch, dinner…)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          TrainerPermissionGate(
                            permission: 'diet:write',
                            child: FitCoreButton(
                              label: 'Assign meal to member',
                              icon: Icons.person_add_outlined,
                              onPressed: () => context.push('/trainer/plans/diet/assign?dietId=${d.id}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
    }
  }
}

class TrainerScheduleScreen extends ConsumerStatefulWidget {
  const TrainerScheduleScreen({super.key});

  @override
  ConsumerState<TrainerScheduleScreen> createState() => _TrainerScheduleScreenState();
}

class _TrainerScheduleScreenState extends ConsumerState<TrainerScheduleScreen> {
  bool _calendarView = true;

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(mockUiPhaseProvider);
    final sessions = ref.watch(trainerProvider).sessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: Icon(_calendarView ? Icons.view_list_outlined : Icons.calendar_month_outlined),
            tooltip: _calendarView ? 'List view' : 'Calendar view',
            onPressed: () => setState(() => _calendarView = !_calendarView),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhaseChips(
              phase: phase,
              onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _calendarView
                  ? ListView(
                      children: [
                        const TrainerScheduleCalendar(),
                        if (phase == MockUiPhase.filled && sessions.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text('All sessions', style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 10),
                          ...sessions.map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: FitCoreCard(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.event, color: AppColors.secondaryAccent),
                                  title: Text(s.title, style: Theme.of(context).textTheme.titleMedium),
                                  subtitle: Text('${s.whenLabel} · ${s.location} · ${s.durationMin} min'),
                                  trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                                  onTap: () => context.push('/trainer/schedule/${s.id}/edit'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    )
                  : _ScheduleBody(phase: phase, sessions: sessions),
            ),
          ],
        ),
      ),
      floatingActionButton: TrainerPermissionGate(
        permission: 'schedule:write',
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/trainer/schedule/create'),
          backgroundColor: AppColors.primaryAccent,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add session', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _ScheduleBody extends StatelessWidget {
  const _ScheduleBody({required this.phase, required this.sessions});

  final MockUiPhase phase;
  final List<MockTrainerSession> sessions;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case MockUiPhase.loading:
        return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
      case MockUiPhase.empty:
        return Center(
          child: Text('No upcoming sessions.', style: Theme.of(context).textTheme.bodyMedium),
        );
      case MockUiPhase.error:
        return Center(
          child: Text(
            'Calendar sync failed.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
          ),
        );
      case MockUiPhase.filled:
        return ListView.separated(
          itemCount: sessions.length,
          separatorBuilder: (context, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final s = sessions[i];
            return FitCoreCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event, color: AppColors.secondaryAccent),
                title: Text(s.title, style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(
                  '${s.whenLabel} · ${s.location}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.secondaryText),
                onTap: () => context.push('/trainer/schedule/${s.id}/edit'),
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
    final phase = ref.watch(mockUiPhaseProvider);
    final user = ref.watch(authServiceProvider);
    final prefs = ref.watch(trainerProvider).notificationPrefs;

    return Scaffold(
      appBar: AppBar(title: const Text('Trainer Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PhaseChips(
            phase: phase,
            onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
          ),
          const SizedBox(height: 16),
          _ProfileBody(
            phase: phase,
            user: user,
            pushEnabled: prefs.workoutReminders || prefs.sessionReminders,
            onSignOut: () async {
              await ref.read(authServiceProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.phase,
    required this.user,
    required this.pushEnabled,
    required this.onSignOut,
  });

  final MockUiPhase phase;
  final UserModel? user;
  final bool pushEnabled;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case MockUiPhase.loading:
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          ),
        );
      case MockUiPhase.empty:
        return FitCoreCard(
          child: Text('Profile unavailable.', style: Theme.of(context).textTheme.bodyMedium),
        );
      case MockUiPhase.error:
        return FitCoreCard(
          child: Text(
            'Could not load profile.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
          ),
        );
      case MockUiPhase.filled:
        return TrainerProfileCard(
          user: user,
          pushEnabled: pushEnabled,
          onOpenNotifications: () => context.push('/trainer/notifications'),
          onNotificationPrefs: () => context.push('/trainer/notifications/settings'),
          onSignOut: onSignOut,
        );
    }
  }
}

class _MessagesAppBarButton extends StatelessWidget {
  const _MessagesAppBarButton({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => context.push('/trainer/messages'),
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: 'Messages',
        ),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
