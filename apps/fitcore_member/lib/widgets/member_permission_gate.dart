import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// Shows [child] when the signed-in member has [permission] (prototype RBAC).
class MemberPermissionGate extends ConsumerWidget {
  const MemberPermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  final String permission;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    if (auth?.role != 'MEMBER') {
      return fallback ?? const SizedBox.shrink();
    }
    if (ref.read(authServiceProvider.notifier).hasPermission(permission)) {
      return child;
    }
    return fallback ??
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Requires $permission',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
  }
}
