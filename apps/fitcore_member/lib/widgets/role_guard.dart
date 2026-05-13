import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

/// Shows [child] only when the signed-in user's role is in [allowedRoles].
class RoleGuard extends ConsumerWidget {
  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authServiceProvider)?.role ?? '';
    if (allowedRoles.contains(role)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
