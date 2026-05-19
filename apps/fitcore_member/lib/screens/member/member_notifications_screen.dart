import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../models/app_notification.dart';
import '../../core/widgets/phase_chips.dart';
import '../../providers/member_notifications_provider.dart';
import '../../providers/mock_ui_phase_provider.dart';
import '../../widgets/notifications_inbox_list.dart';

/// Member notification inbox — plans, check-ins, renewal reminders.
class MemberNotificationsScreen extends ConsumerWidget {
  const MemberNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = ref.watch(mockUiPhaseProvider);
    final inbox = ref.watch(memberNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBg,
        title: const Text('Notifications'),
        actions: [
          if (inbox.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(memberNotificationsProvider.notifier).markAllRead(),
              child: const Text('Mark all read'),
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
                    ref.read(memberNotificationsProvider.notifier).markRead(n.id);
                    switch (n.category) {
                      case AppNotificationCategory.planAssigned:
                      case AppNotificationCategory.planUpdated:
                        context.push('/member/workouts');
                        break;
                      case AppNotificationCategory.memberCheckIn:
                        context.push('/member/attendance');
                        break;
                      case AppNotificationCategory.system:
                        if (n.id == 'mn_renew') {
                          context.push('/member/profile');
                        }
                        break;
                      default:
                        break;
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
