import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/fitcore_button.dart';
import '../../providers/reception_notifications_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/notification_bell_button.dart';
import '../../widgets/role_shell.dart';

/// Receptionist area — bottom nav provided by [RoleShell] in router.
class ReceptionistShell extends StatelessWidget {
  const ReceptionistShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return RoleShell(navigationShell: navigationShell);
  }
}

class ReceptionProfileScreen extends ConsumerWidget {
  const ReceptionProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(receptionNotificationsProvider).unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
          Text('Reception · Apex Iron Gym', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          FitCoreButton(
            label: 'Notifications',
            variant: FitCoreButtonVariant.secondary,
            icon: Icons.notifications_outlined,
            onPressed: () => context.push('/receptionist/notifications'),
          ),
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
