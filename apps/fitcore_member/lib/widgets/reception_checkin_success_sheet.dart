import 'package:flutter/material.dart';

import '../core/tokens/app_colors.dart';
import '../core/widgets/fitcore_button.dart';
import '../models/reception_checkin.dart';

void showReceptionAttendanceSuccessSheet(BuildContext context, AttendanceToggleResult result) {
  final isCheckIn = result.action == AttendanceAction.checkIn;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                color: isCheckIn ? AppColors.success : AppColors.secondaryAccent,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                isCheckIn ? 'Check-in successful' : 'Check-out successful',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${result.member.memberId} · ${result.member.memberName}',
                style: Theme.of(ctx).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              Text(
                isCheckIn
                    ? '${result.member.plan} plan · In at ${result.timeLabel}'
                    : 'Out at ${result.timeLabel} · In at ${result.checkInTimeLabel ?? '—'}',
                style: Theme.of(ctx).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FitCoreButton(
                label: 'Done',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
