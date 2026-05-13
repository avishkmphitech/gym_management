import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

/// Debug-only floating control to swap mock role and navigate to the role home.
class DevRoleSwitcher extends ConsumerWidget {
  const DevRoleSwitcher({super.key});

  static String homeForRole(String role) {
    switch (role) {
      case 'TRAINER':
        return '/trainer/dashboard';
      case 'RECEPTIONIST':
        return '/receptionist/checkin';
      case 'MEMBER':
      default:
        return '/member/home';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }

    final user = ref.watch(authServiceProvider);
    final badge = user?.role ?? '—';

    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFF2B2B2B),
      child: InkWell(
        onTap: () => _openSheet(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bug_report_outlined, size: 18, color: Color(0xFF3E7C59)),
              const SizedBox(width: 6),
              Text(
                badge,
                style: const TextStyle(
                  color: Color(0xFFF5F5F2),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF222222),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Dev: switch role',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(color: const Color(0xFFF5F5F2)),
                ),
                const SizedBox(height: 12),
                _roleTile(ctx, ref, 'MEMBER', 'Member'),
                _roleTile(ctx, ref, 'TRAINER', 'Trainer'),
                _roleTile(ctx, ref, 'RECEPTIONIST', 'Receptionist'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _roleTile(BuildContext sheetContext, WidgetRef ref, String role, String label) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Color(0xFFF5F5F2))),
      subtitle: Text(role, style: const TextStyle(color: Color(0xFFB8B6B0), fontSize: 12)),
      onTap: () async {
        Navigator.of(sheetContext).pop();
        await ref.read(authServiceProvider.notifier).setMockUserForRole(role);
        if (sheetContext.mounted) {
          sheetContext.go(homeForRole(role));
        }
      },
    );
  }
}
