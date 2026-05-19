# Member UI (member-only)

Member flows live under `lib/screens/member/` and `lib/features/member/`. Trainer/reception screens are unchanged.

| Area | Location |
|------|----------|
| Tab shell | `lib/features/shell/member_shell.dart` → `RoleShell` |
| Providers | `lib/providers/member_provider.dart`, `member_identity.dart`, `member_notifications_provider.dart` |
| Prototype wrappers | `lib/widgets/member_phase_viewport.dart` |
| Notifications | `/member/notifications` |

Prototype UI states use `PhaseChips` + `mockUiPhaseProvider` via `MemberPhaseViewport` (filled = normal app logic).

| Notifications | Route |
|---------------|--------|
| Member inbox | `/member/notifications` |
| Trainer chat | `/member/messages` |

| Workouts | Route |
|----------|--------|
| History | `/member/workouts/history` |
| Day detail | `/member/workouts/day/:dayIndex` |

| Profile | Route |
|---------|--------|
| Edit profile | `/member/profile/edit` |
