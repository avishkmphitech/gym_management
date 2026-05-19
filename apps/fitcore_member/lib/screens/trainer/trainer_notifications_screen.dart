import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/phase_chips.dart';
import '../../providers/mock_ui_phase_provider.dart';
import '../../providers/trainer_notifications_provider.dart';
import '../../widgets/notifications_inbox_list.dart';

/// Trainer notification inbox (assignments, sessions, check-ins).
class TrainerNotificationsScreen extends ConsumerWidget {
  const TrainerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    final inbox = ref.watch(trainerNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (inbox.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(trainerNotificationsProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Notification settings',
            onPressed: () => context.push('/trainer/notifications/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: PhaseChips(
              phase: phase,
              onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
            ),
          ),
          Expanded(
            child: switch (phase) {
              MockUiPhase.loading => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryAccent),
                ),
              MockUiPhase.empty => const Center(child: Text('No notifications.')),
              MockUiPhase.error => const Center(child: Text('Could not load notifications.')),
              MockUiPhase.filled => NotificationsInboxList(
                  notifications: inbox.displayItems,
                  onTap: (n) {
                    ref.read(trainerNotificationsProvider.notifier).markRead(n.id);
                    if (n.memberName != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Related to ${n.memberName}')),
                      );
                    }
                  },
                ),
            },
          ),
        ],
      ),
    );
  }
}
