import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

const Color _kActive = Color(0xFF3E7C59);
const Color _kInactive = Color(0xFFB8B6B0);
const Color _kBarBg = Color(0xFF1B1B1B);
const Color _kBarBorder = Color(0xFF444444);

class _TabItem {
  const _TabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

List<_TabItem> _tabsForRole(String role) {
  switch (role) {
    case 'TRAINER':
      return const [
        _TabItem(icon: Icons.dashboard_outlined, label: 'Dashboard'),
        _TabItem(icon: Icons.groups_outlined, label: 'Members'),
        _TabItem(icon: Icons.assignment_outlined, label: 'Plans'),
        _TabItem(icon: Icons.calendar_month_outlined, label: 'Schedule'),
        _TabItem(icon: Icons.person_outline, label: 'Profile'),
      ];
    case 'RECEPTIONIST':
      return const [
        _TabItem(icon: Icons.qr_code_scanner_outlined, label: 'Check-in'),
        _TabItem(icon: Icons.people_outline, label: 'Members'),
        _TabItem(icon: Icons.fact_check_outlined, label: 'Log'),
        _TabItem(icon: Icons.person_outline, label: 'Profile'),
      ];
    case 'MEMBER':
    default:
      return const [
        _TabItem(icon: Icons.home_outlined, label: 'Home'),
        _TabItem(icon: Icons.fitness_center_outlined, label: 'Workouts'),
        _TabItem(icon: Icons.restaurant_outlined, label: 'Diet'),
        _TabItem(icon: Icons.event_available_outlined, label: 'Attendance'),
        _TabItem(icon: Icons.person_outline, label: 'Profile'),
      ];
  }
}

/// Shell with adaptive bottom navigation driven by [AuthService] role.
class RoleShell extends ConsumerWidget {
  const RoleShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authServiceProvider)?.role ?? 'MEMBER';
    final items = _tabsForRole(role);
    final n = items.length;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Material(
        color: _kBarBg,
        child: SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _kBarBorder, width: 1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              children: List.generate(n, (index) {
                final selected = navigationShell.currentIndex == index;
                final item = items[index];
                final color = selected ? _kActive : _kInactive;
                return Expanded(
                  child: InkWell(
                    onTap: () => navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item.icon, color: color, size: 24),
                          const SizedBox(height: 4),
                          if (selected)
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: _kActive,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(height: 4),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
