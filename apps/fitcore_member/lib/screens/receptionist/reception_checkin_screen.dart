import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../models/reception_checkin.dart';
import '../../providers/reception_checkin_provider.dart';
import '../../widgets/reception_attendance_log_tile.dart';
import '../../providers/reception_notifications_provider.dart';
import '../../widgets/notification_bell_button.dart';
import '../../widgets/reception_checkin_success_sheet.dart';

Future<void> _openQrAttendance(BuildContext context) async {
  final result = await context.push<AttendanceToggleResult>('/receptionist/checkin/qr');
  if (result != null && context.mounted) {
    showReceptionAttendanceSuccessSheet(context, result);
  }
}

Future<void> _openPhoneAttendance(BuildContext context) async {
  final result = await context.push<AttendanceToggleResult>('/receptionist/checkin/phone');
  if (result != null && context.mounted) {
    showReceptionAttendanceSuccessSheet(context, result);
  }
}

/// Receptionist hub: check-in/out options + today's attendance log.
class ReceptionCheckInScreen extends ConsumerWidget {
  const ReceptionCheckInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(receptionCheckInsProvider);
    final activeCount = ref.watch(receptionAttendanceProvider).activeSessions.length;
    final unread = ref.watch(receptionNotificationsProvider).unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        actions: [
          NotificationBellButton(
            unreadCount: unread,
            onTap: () => context.push('/receptionist/notifications'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Scan or look up member',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Same QR or phone toggles: not checked in → check in; already in gym → check out.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _CheckInOptionCard(
            icon: Icons.qr_code_scanner_rounded,
            title: 'QR scan',
            subtitle: 'Scan member attendance QR (check in or out)',
            accent: AppColors.primaryAccent,
            onTap: () => _openQrAttendance(context),
          ),
          const SizedBox(height: 12),
          _CheckInOptionCard(
            icon: Icons.phone_android_rounded,
            title: 'Mobile number',
            subtitle: 'Look up member by phone (check in or out)',
            accent: AppColors.secondaryAccent,
            onTap: () => _openPhoneAttendance(context),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text("Today's activity", style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              Text(
                '$activeCount in gym',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (log.isEmpty)
            FitCoreCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                child: Column(
                  children: [
                    Icon(Icons.history_rounded, size: 40, color: AppColors.secondaryText.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text(
                      'No activity yet',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Scan or look up a member to record check-in / check-out.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...log.take(8).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ReceptionAttendanceLogTile(record: r),
                )),
          if (log.length > 8) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                '+ ${log.length - 8} more in Log tab',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondaryText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckInOptionCard extends StatelessWidget {
  const _CheckInOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FitCoreCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ),
    );
  }
}
