# Member Role — Status Audit (FitCore Mobile)

Audit of the **MEMBER** role in `apps/fitcore_member` against `fitcore-master-context.mdc`, `README_FLOW.md`, and prototype rules.

**Demo login:** `member@fitcore.com` / `123456` → `UserModel` **Aarav Khanna** (`auth_service.dart`)

**Last reviewed:** May 2026

---

## Routes & files

| Tab | Route | Screen file |
|-----|--------|-------------|
| Home | `/member/home` | `home_screen.dart` |
| Workouts | `/member/workouts` | `workout_screen.dart` |
| Diet | `/member/diet` | `diet_screen.dart` |
| Attendance | `/member/attendance` | `attendance_screen.dart` |
| Profile | `/member/profile` | `member_shell.dart` → `ProfileScreen` |

**Nested / stack routes**

| Route | Screen |
|-------|--------|
| `/member/notifications` | `member_notifications_screen.dart` |
| `/member/workouts/history` | `member_workout_history_screen.dart` |
| `/member/workouts/day/:dayIndex` | `member_workout_day_screen.dart` |
| `/member/profile/edit` | `member_edit_profile_screen.dart` |

**Shared auth (all roles):** `/login`, `/forgot-password`, `/forgot-password/verify`, `/forgot-password/reset`, `/auth/invite`

**Shell:** `lib/features/shell/member_shell.dart` → `RoleShell` (5 tabs)

See also: `MEMBER_UI.md`

---

## Complete

| Area | Notes |
|------|--------|
| **Auth & routing** | Splash → onboarding → login; RBAC redirects; role blocked from other shells |
| **Bottom navigation** | Home · Workouts · Diet · Attendance · Profile |
| **RoleGuard** | All tab screens + access-denied fallback |
| **JWT mock permissions** | `workouts:read`, `diet:read`, `attendance:read`, `profile:read`, `profile:write` |
| **Dev role switcher** | Debug builds (`dev_role_switcher.dart`) |
| **Design system** | Dark theme, Poppins/Inter, FitCore tokens |
| **Trainer plan sync** | `memberWeeklyWorkoutPlanProvider` / `memberDietPlanProvider` ← `trainerProvider` (`m1` ↔ Aarav) |
| **Home dashboard** | Auth greeting, stats, membership, today workout/diet cards, weekly progress chart, recent check-ins |
| **Workouts** | Week strip (tap + long-press detail), exercises from assigned plan, finish workout + confetti |
| **Diet** | Trainer meal slots, logged meals update calories/macros, tap water glasses |
| **Attendance** | Live calendar/summary/log + QR check-in with reception |
| **Notifications** | Inbox + home bell with unread count |
| **Profile** | Auth user, membership/plans, edit profile, mock push toggle (no permission list shown) |
| **Navigation** | Deep links, nested routes (history, day detail, notifications, edit profile) |
| **Prototype quality** | `MemberPhaseViewport`, `member_provider` layer |
| **Membership renewal** | View-only; reception updates plan at desk — no self-renew in app |
| **Platform flows (mock)** | Forgot password OTP `123456`, invitation setup, push pref toggle, `api_client` stub |

---

## Not in scope (prototype)

| Item | Notes |
|------|--------|
| **Real API / PostgreSQL** | Mock Riverpod data only — `lib/services/api_client.dart` documents future hook-up |
| **Firebase FCM** | Push toggle is local mock only |
| **In-app membership renewal** | Receptionist updates plan manually — member sees status only |
| **Chat with trainer** | `/member/messages` — assigned trainer only; roster-gated send/read |

---

## Known limitations

| Item | Notes |
|------|--------|
| **Trainer state** | `trainerProvider` resets on cold start (in-memory mock) |
| **Macro estimates** | Logged-meal protein/carbs/fat estimated from food type dots, not USDA data |
| **Desk ID mapping** | Exact name match first; falls back to first-name heuristic |

---

## Summary

**Member mobile prototype is feature-complete** for the FitCore spec at mock/prototype level: five tabs, trainer-assigned plans, reception QR attendance, notifications, profile, auth recovery flows, and dev UI state chips. Production backend, FCM, and web billing remain future work.
