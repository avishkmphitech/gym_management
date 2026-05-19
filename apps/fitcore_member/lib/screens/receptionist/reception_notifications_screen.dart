import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../core/widgets/phase_chips.dart';
import '../../providers/mock_ui_phase_provider.dart';
import '../../providers/reception_notifications_provider.dart';
import '../../widgets/notifications_inbox_list.dart';

/// Receptionist alerts: member plans and overstay checkout (> 23h).
class ReceptionNotificationsScreen extends ConsumerWidget {
  const ReceptionNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    final inbox = ref.watch(receptionNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (inbox.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(receptionNotificationsProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: PhaseChips(
              phase: phase,
              onChanged: (p) => ref.read(mockUiPhaseProvider.notifier).setPhase(p),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FitCoreCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Alerts when a member\'s plan changes and when someone is checked in over $receptionOverstayHours hours without checkout.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
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
                  emptyMessage: 'No alerts right now.',
                  onTap: (n) {
                    ref.read(receptionNotificationsProvider.notifier).markRead(n.id);
                    if (n.memberId != null) {
                      context.push('/receptionist/members/${n.memberId}');
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
