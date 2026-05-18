import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/shell/member_shell.dart';
import '../screens/member/attendance_screen.dart';
import '../screens/member/diet_screen.dart';
import '../screens/member/home_screen.dart';
import '../screens/member/workout_screen.dart';
import '../features/shell/receptionist_shell.dart';
import '../features/shell/trainer_role_shell.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_service.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Notifies [GoRouter] when [authServiceProvider] changes so redirects re-run.
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref) {
    _ref.listen<UserModel?>(authServiceProvider, (UserModel? previous, UserModel? next) => notifyListeners());
  }

  final Ref _ref;
}

final _goRouterRefreshProvider = Provider<GoRouterRefreshNotifier>((ref) {
  final notifier = GoRouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

String _homeForRole(String role) {
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

String? _authRedirect(Ref ref, GoRouterState state) {
  final user = ref.read(authServiceProvider);
  final path = state.uri.path;

  if (user == null) {
    if (path.startsWith('/member') || path.startsWith('/trainer') || path.startsWith('/receptionist')) {
      return '/login';
    }
    return null;
  }

  if (path == '/login' || path == '/' || path == '/onboarding') {
    return _homeForRole(user.role);
  }

  if (path.startsWith('/member') && user.role != 'MEMBER') {
    return _homeForRole(user.role);
  }
  if (path.startsWith('/trainer') && user.role != 'TRAINER') {
    return _homeForRole(user.role);
  }
  if (path.startsWith('/receptionist') && user.role != 'RECEPTIONIST') {
    return _homeForRole(user.role);
  }

  if (path == '/member' && user.role == 'MEMBER') {
    return '/member/home';
  }
  if (path == '/trainer' && user.role == 'TRAINER') {
    return '/trainer/dashboard';
  }
  if (path == '/receptionist' && user.role == 'RECEPTIONIST') {
    return '/receptionist/checkin';
  }

  return null;
}

final memberRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(_goRouterRefreshProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) => _authRedirect(ref, state),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/member',
        redirect: (context, state) => null,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return MemberShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'home', builder: (context, state) => const HomeScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'workouts', builder: (context, state) => const WorkoutsScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'diet', builder: (context, state) => const DietScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'attendance', builder: (context, state) => const AttendanceScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'profile', builder: (context, state) => const ProfileScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/trainer',
        redirect: (context, state) => null,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return TrainerShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'dashboard', builder: (context, state) => const TrainerHomeScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'members', builder: (context, state) => const TrainerMembersScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'plans', builder: (context, state) => const TrainerWorkoutsScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'schedule', builder: (context, state) => const TrainerScheduleScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'profile', builder: (context, state) => const TrainerProfileScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/receptionist',
        redirect: (context, state) => null,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ReceptionistShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'checkin', builder: (context, state) => const ReceptionCheckInScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'members', builder: (context, state) => const ReceptionMembersLookupScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'log', builder: (context, state) => const ReceptionAttendanceLogScreen()),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(path: 'profile', builder: (context, state) => const ReceptionProfileScreen()),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
