import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// Shows [child] when the signed-in trainer has [permission] (or [fallback]).
class TrainerPermissionGate extends ConsumerWidget {
  const TrainerPermissionGate({
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
    if (auth?.role != 'TRAINER') {
      return fallback ?? const SizedBox.shrink();
    }
    if (ref.read(authServiceProvider.notifier).hasPermission(permission)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
