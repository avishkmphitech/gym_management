# Trainer UI (trainer-only)

Trainer flows live under `lib/screens/trainer/` and `lib/features/trainer/`. They are **not** merged into member workout/diet screens (`isTrainer` on shared screens) so member and receptionist behavior stays unchanged.

| Area | Location |
|------|----------|
| Tab shell | `lib/features/shell/trainer_role_shell.dart` |
| Dashboard quick actions | `lib/features/trainer/trainer_quick_actions.dart` |
| Profile card | `lib/features/trainer/trainer_profile_card.dart` |
| Permission gating | `lib/widgets/trainer_permission_gate.dart` |
| Plans / members / schedule | `lib/screens/trainer/*` |

Prototype UI states use `PhaseChips` + `mockUiPhaseProvider` on dashboard, members, plans, schedule, profile, notification inbox, and notification settings.

| Notifications | Route |
|---------------|--------|
| Trainer inbox | `/trainer/notifications` |
| Trainer settings | `/trainer/notifications/settings` |
| Reception inbox | `/receptionist/notifications` |
