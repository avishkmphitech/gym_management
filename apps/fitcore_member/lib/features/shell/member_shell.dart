import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/tokens/app_colors.dart';
import '../../core/widgets/fitcore_button.dart';
import '../../services/auth_service.dart';
import '../../widgets/role_shell.dart';

/// Member shell — bottom navigation from [RoleShell] (MEMBER tabs).
class MemberShell extends StatelessWidget {
  const MemberShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return RoleShell(navigationShell: navigationShell);
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.cardBg,
                child: Text(
                  'AK',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aarav Khanna',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryText),
                    ),
                    Text('Member · gym_id: apex-iron-01', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FitCoreButton(label: 'Edit profile', variant: FitCoreButtonVariant.secondary, onPressed: () {}),
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
