import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/shell/member_shell.dart';
import '../screens/member/attendance_screen.dart';
import '../screens/member/diet_screen.dart';
import '../screens/member/home_screen.dart';
import '../screens/member/workout_screen.dart';
import '../features/shell/receptionist_shell.dart';
import '../screens/receptionist/reception_attendance_log_screen.dart';
import '../screens/receptionist/reception_checkin_screen.dart';
import '../screens/receptionist/reception_member_detail_screen.dart';
import '../screens/receptionist/reception_members_screen.dart';
import '../screens/receptionist/reception_phone_checkin_screen.dart';
import '../screens/receptionist/reception_qr_checkin_screen.dart';
import '../features/shell/trainer_role_shell.dart';
import '../screens/trainer/trainer_assign_diet_screen.dart';
import '../screens/trainer/trainer_diet_detail_screen.dart';
import '../screens/trainer/trainer_edit_diet_screen.dart';
import '../screens/trainer/trainer_edit_week_plan_screen.dart';
import '../screens/trainer/trainer_week_plan_detail_screen.dart';
import '../screens/trainer/trainer_assign_week_workout_screen.dart';
import '../screens/trainer/trainer_edit_session_screen.dart';
import '../screens/trainer/trainer_member_detail_screen.dart';
import '../screens/trainer/trainer_notification_prefs_screen.dart';
import '../screens/trainer/trainer_notifications_screen.dart';
import '../screens/receptionist/reception_notifications_screen.dart';
import '../models/user_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/splash_screen.dart';
import '../services/auth_service.dart';

/// Root navigator for routes and overlays (e.g. dev role switcher in [MaterialApp.builder]).
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

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
    navigatorKey: rootNavigatorKey,
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
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const TrainerNotificationsScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const TrainerNotificationPrefsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'profile/notifications',
            redirect: (context, state) => '/trainer/notifications/settings',
          ),
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
                  GoRoute(
                    path: 'members',
                    builder: (context, state) => const TrainerMembersScreen(),
                    routes: [
                      GoRoute(
                        path: ':memberId',
                        builder: (context, state) => TrainerMemberDetailScreen(
                          memberId: state.pathParameters['memberId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'plans',
                    builder: (context, state) => const TrainerWorkoutsScreen(),
                    routes: [
                      GoRoute(
                        path: 'week/create',
                        builder: (context, state) => const TrainerEditWeekPlanScreen(),
                      ),
                      GoRoute(
                        path: 'week/assign',
                        builder: (context, state) => TrainerAssignWeekWorkoutScreen(
                          weekPlanId: state.uri.queryParameters['weekPlanId'],
                          memberId: state.uri.queryParameters['memberId'],
                        ),
                      ),
                      GoRoute(
                        path: 'week/:weekPlanId',
                        builder: (context, state) => TrainerWeekPlanDetailScreen(
                          weekPlanId: state.pathParameters['weekPlanId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            builder: (context, state) => TrainerEditWeekPlanScreen(
                              weekPlanId: state.pathParameters['weekPlanId'],
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'diet/assign',
                        builder: (context, state) => TrainerAssignDietScreen(
                          dietId: state.uri.queryParameters['dietId'],
                          memberId: state.uri.queryParameters['memberId'],
                        ),
                      ),
                      GoRoute(
                        path: 'assign-diet',
                        redirect: (context, state) {
                          final q = state.uri.query;
                          return q.isEmpty ? '/trainer/plans/diet/assign' : '/trainer/plans/diet/assign?$q';
                        },
                      ),
                      GoRoute(
                        path: 'diet/create',
                        builder: (context, state) => const TrainerEditDietScreen(),
                      ),
                      GoRoute(
                        path: 'diet/:dietId',
                        builder: (context, state) => TrainerDietDetailScreen(
                          dietId: state.pathParameters['dietId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            builder: (context, state) => TrainerEditDietScreen(
                              dietId: state.pathParameters['dietId'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'schedule',
                    builder: (context, state) => const TrainerScheduleScreen(),
                    routes: [
                      GoRoute(
                        path: 'create',
                        builder: (context, state) => const TrainerEditSessionScreen(),
                      ),
                      GoRoute(
                        path: ':sessionId/edit',
                        builder: (context, state) => TrainerEditSessionScreen(
                          sessionId: state.pathParameters['sessionId'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'profile',
                    builder: (context, state) => const TrainerProfileScreen(),
                  ),
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
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const ReceptionNotificationsScreen(),
          ),
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ReceptionistShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'checkin',
                    builder: (context, state) => const ReceptionCheckInScreen(),
                    routes: [
                      GoRoute(
                        path: 'qr',
                        builder: (context, state) => const ReceptionQrCheckInScreen(),
                      ),
                      GoRoute(
                        path: 'phone',
                        builder: (context, state) => const ReceptionPhoneCheckInScreen(),
                      ),
                    ],
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: 'members',
                    builder: (context, state) => const ReceptionMembersScreen(),
                    routes: [
                      GoRoute(
                        path: ':memberId',
                        builder: (context, state) => ReceptionMemberDetailScreen(
                          memberId: state.pathParameters['memberId']!,
                        ),
                      ),
                    ],
                  ),
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
