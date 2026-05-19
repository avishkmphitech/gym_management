# FitCore — Gym Management SaaS (prototype)

Multi-tenant gym platform with **one mobile app** and **one web dashboard**. Everything is controlled by **role-based permissions** (RBMS/RBAC: Super Admin, Gym Owner, Trainer, Member, Receptionist). All data is mocked; navigation and UI states (loading / empty / filled / error) are wired for demos.

## Repository layout

| App | Path | Stack |
|-----|------|--------|
| Unified mobile app | `apps/fitcore_member` | Flutter, Riverpod, go_router |
| Unified web dashboard | `apps/fitcore_gym_owner` | Next.js 15, Tailwind v4 |

Former duplicate projects (`apps/fitcore_trainer`, `apps/fitcore_super_admin`) were removed after merging their behavior into the two apps above.

Design tokens match the FitCore spec (dark theme, `#3E7C59` accent, Poppins headings, Inter body).

## Run locally

**Flutter (single mobile app):**

```bash
cd apps/fitcore_member && flutter run
```

**Next.js (single dashboard with role-managed nav):**

```bash
cd apps/fitcore_gym_owner && npm run dev
```

## Quality checks

```bash
cd apps/fitcore_member && flutter analyze && flutter test
cd apps/fitcore_gym_owner && npm run build
```

See `README_FLOW.md` for broader product and auth flow notes.






Here’s an audit of the **Trainer** role in `apps/fitcore_member` against the FitCore spec (`fitcore-master-context.mdc`, `README_FLOW.md`, and prototype rules).

---

## What is fulfilled

These are in place and working at a **prototype / shell** level.

| Area | Status | Notes |
|------|--------|--------|
| **Auth & routing** | Done | `trainer@fitcore.com` / `123456`, splash → `/trainer/dashboard`, RBAC redirects in `app_router.dart` |
| **Bottom navigation (5 tabs)** | Done | Dashboard · Members · Plans · Schedule · Profile — matches spec |
| **Trainer shell** | Done | `TrainerShell` + `RoleShell` with TRAINER tabs |
| **Dashboard** | Partial | Today’s schedule list, mock greeting, `PhaseChips` (loading / empty / filled / error) |
| **My Members** | Partial | Assigned members list with mock data + UI states |
| **Plans** | Partial | Workout template list + UI states |
| **Schedule** | Partial | Session list + UI states |
| **Profile** | Partial | Avatar, sign out; mock notification line |
| **Mock data** | Done | `assignedMembers`, `trainerWorkoutTemplates`, `trainerSchedule` in `trainer_mock_data.dart` |
| **Permissions (JWT mock)** | Done | `members:read`, `plans:write`, `schedule:read/write`, `profile:read` in `auth_service.dart` |
| **Dev role switcher** | Done | Switch to Trainer in debug builds |

---

## What is pending

Grouped by product requirement vs current implementation.

### 1. Core trainer features (from `README_FLOW.md`)

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| **Assign workouts** | Done | 3-step flow (`/trainer/plans/assign`), confirm dialog, assignment history, updates member progress |
| **Create diet plans** | Done | Diet tab on Plans, create/edit (`/trainer/plans/diet/create`, `…/edit`), detail with macros, assign with confirm |
| **Track member progress** | Done | Member detail: completion bars, weekly chart, body metrics, attendance & workout history |
| **Manage sessions / class scheduling** | Done | Add/edit/delete sessions, week calendar view, date/time picker, conflict detection & warning |

### 2. Navigation & screens (from master context)

| Spec item | Status | Implementation |
|-----------|--------|----------------|
| **Create Plans** | Done | `/trainer/plans/create` & `/:planId/edit` with exercise/sets/reps editor; detail at `/:planId`; save updates provider |
| **My Members → detail** | Done | `/trainer/members/:memberId` — tap card or dashboard quick list; progress, plans, assign actions |
| **Nested trainer routes** | Done | Sub-routes under each tab: members, plans (create/assign/diet/plan detail/edit), schedule, profile |

**Trainer nested routes (reference):**

| Tab | Routes |
|-----|--------|
| Members | `/trainer/members/:memberId` |
| Plans | `/trainer/plans/create`, `/:planId`, `/:planId/edit`, `/assign`, `/assign-diet`, `/diet/create`, `/diet/:dietId`, `/diet/:dietId/edit` |
| Schedule | `/trainer/schedule/create`, `/:sessionId/edit` |
| Profile | `/trainer/profile/notifications` |

### 3. UI / prototype quality (vs Member & Receptionist)

| Item | Status | Notes |
|------|--------|--------|
| **Rich UI (trainer dashboard)** | Done | `TrainerQuickActions` on dashboard (week/meal create, assign workout/meal, add session); dedicated trainer screens under `lib/screens/trainer/` |
| **Profile UI states** | Done | `PhaseChips` on profile + notification prefs (loading / empty / filled / error) |
| **Profile from auth** | Done | `TrainerProfileCard` uses `authServiceProvider` (name, email, gym, role, permission chips) |
| **Notification prefs** | Done | `/trainer/profile/notifications` — toggles persist in `trainerProvider`; save snackbar (mock) |
| **Permission checks in UI** | Done | `TrainerPermissionGate` on plans FABs, assign buttons, schedule FAB, dashboard quick actions |
| **Shared-screen pattern** | Intentional (trainer-only) | Member/receptionist screens **unchanged**; trainer uses separate routes/widgets — see `apps/fitcore_member/lib/screens/trainer/TRAINER_UI.md` |

### 4. Permissions & RBAC

| Item | Status |
|------|--------|
| **Diet permission** | Done | `diet:read`, `diet:write` on trainer mock user; legacy sessions patched in `loadFromStorage` |
| **`plans:write` / `schedule:write`** | Done | Gated write actions on plans and schedule |

### 5. Product flows (broader platform — not trainer-mobile-specific but relevant)

| Flow | Status |
|------|--------|
| Invitation / first-login password setup | Not implemented (shared gap for all roles) |
| Real API / backend integration | Mock only (expected for prototype) |
| Push notifications (Firebase) | Mentioned in profile copy only — no settings screen |

---

## Summary

**Trainer mobile prototype (Flutter)** covers shell navigation, week/meal plans, member detail with assign/switch, session CRUD, profile/auth, notification prefs, and permission-gated actions. **Member and receptionist flows were not modified** — trainer code is isolated under `lib/screens/trainer/` and `lib/features/trainer/`.

Remaining platform-wide gaps (all roles): real API, invitations, Firebase push delivery.