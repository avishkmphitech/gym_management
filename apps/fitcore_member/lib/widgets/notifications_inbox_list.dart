import 'package:flutter/material.dart';

import '../core/tokens/app_colors.dart';
import '../core/widgets/fitcore_card.dart';
import '../models/app_notification.dart';

/// Shared notification list UI for trainer and receptionist inboxes.
class NotificationsInboxList extends StatelessWidget {
  const NotificationsInboxList({
    super.key,
    required this.notifications,
    required this.onTap,
    this.emptyMessage = 'No notifications yet.',
  });

  final List<AppNotification> notifications;
  final void Function(AppNotification item) onTap;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: notifications.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final n = notifications[i];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onTap(n),
            borderRadius: BorderRadius.circular(18),
            child: FitCoreCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryIcon(category: n.category, severity: n.severity),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                n.title,
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: n.read
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                    ),
                              ),
                            ),
                            if (!n.read)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          n.body,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          n.timeLabel,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category, required this.severity});

  final AppNotificationCategory category;
  final AppNotificationSeverity severity;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (category) {
      case AppNotificationCategory.planAssigned:
      case AppNotificationCategory.planUpdated:
        icon = Icons.assignment_outlined;
        color = AppColors.primaryAccent;
      case AppNotificationCategory.sessionReminder:
        icon = Icons.event_outlined;
        color = AppColors.secondaryAccent;
      case AppNotificationCategory.memberCheckIn:
        icon = Icons.login_outlined;
        color = AppColors.success;
      case AppNotificationCategory.overstayCheckout:
        icon = Icons.warning_amber_rounded;
        color = AppColors.error;
      case AppNotificationCategory.system:
        icon = Icons.info_outline;
        color = AppColors.secondaryText;
    }
    if (severity == AppNotificationSeverity.critical) {
      color = AppColors.error;
    } else if (severity == AppNotificationSeverity.warning) {
      color = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
