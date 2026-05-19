import 'package:flutter/material.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_card.dart';
import '../../models/user_model.dart';

/// Permission chips for member profile (display only).
class MemberProfilePermissionsCard extends StatelessWidget {
  const MemberProfilePermissionsCard({super.key, required this.user});

  final UserModel? user;

  @override
  Widget build(BuildContext context) {
    final permissions = user?.permissions ?? const <String>[];
    if (permissions.isEmpty) return const SizedBox.shrink();

    return FitCoreCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Permissions', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in permissions)
                Chip(
                  label: Text(p, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.cardBg,
                  side: const BorderSide(color: AppColors.border),
                  labelStyle: const TextStyle(color: AppColors.primaryText),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
