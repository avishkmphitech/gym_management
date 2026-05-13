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
