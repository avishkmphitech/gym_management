import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../core/widgets/phase_chips.dart';
import '../../providers/mock_ui_phase_provider.dart';
import '../../providers/trainer_provider.dart';

/// Trainer push notification preferences (mock) with loading / empty / error / filled states.
class TrainerNotificationPrefsScreen extends ConsumerWidget {
  const TrainerNotificationPrefsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    final prefs = ref.watch(trainerProvider).notificationPrefs;

    return Scaffold(
      appBar: AppBar(title: const Text('Notification preferences')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PhaseChips(
            phase: phase,
            onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
          ),
          const SizedBox(height: 16),
          switch (phase) {
            MockUiPhase.loading => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: CircularProgressIndicator(color: AppColors.primaryAccent),
                ),
              ),
            MockUiPhase.empty => FitCoreCard(
                child: Text(
                  'No notification settings available.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            MockUiPhase.error => FitCoreCard(
                child: Text(
                  'Could not load notification preferences.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.error),
                ),
              ),
            MockUiPhase.filled => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FitCoreCard(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Workout reminders'),
                          subtitle: const Text('When members complete or miss assigned workouts'),
                          value: prefs.workoutReminders,
                          activeThumbColor: AppColors.primaryAccent,
                          onChanged: (v) {
                            ref.read(trainerProvider.notifier).updateNotificationPrefs(
                                  prefs.copyWith(workoutReminders: v),
                                );
                            _savedSnack(context);
                          },
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        SwitchListTile(
                          title: const Text('Session reminders'),
                          subtitle: const Text('15 min before PT and group classes'),
                          value: prefs.sessionReminders,
                          activeThumbColor: AppColors.primaryAccent,
                          onChanged: (v) {
                            ref.read(trainerProvider.notifier).updateNotificationPrefs(
                                  prefs.copyWith(sessionReminders: v),
                                );
                            _savedSnack(context);
                          },
                        ),
                        const Divider(height: 1, color: AppColors.border),
                        SwitchListTile(
                          title: const Text('Member check-in alerts'),
                          subtitle: const Text('When assigned members check in at the gym'),
                          value: prefs.memberCheckInAlerts,
                          activeThumbColor: AppColors.primaryAccent,
                          onChanged: (v) {
                            ref.read(trainerProvider.notifier).updateNotificationPrefs(
                                  prefs.copyWith(memberCheckInAlerts: v),
                                );
                            _savedSnack(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Firebase push is mocked for the prototype. Preferences are stored in app state only.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  FitCoreButton(
                    label: 'Done',
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
          },
        ],
      ),
    );
  }

  void _savedSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preference saved (mock)'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
