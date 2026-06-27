# Regression fixtures

Seeded **bad** changes. The review gate (`skills/domain-review`) must reject each
one for the stated reason. If the gate passes any of these, the gate is broken —
that is itself an eval failure.

## R1 — untested validation rule

Change: add a validation rule to `src/domain/appointment.ts` with **no
accompanying unit test**.

Expected: `domain-review` → **Fail**, reason "a validation rule has no test"
(stop condition #6 / #1).

## R2 — illegal status transition reachable

Change: edit the status graph so `done -> requested` becomes reachable (a
terminal state reopened) with no guard.

Expected: `domain-review` → **Fail**, reason "a status change leaves an illegal
transition reachable".

## R3 — schema change without rollback

Change: add a required column to an existing Prisma model with a migration that
has **no rollback/backfill note** and makes it required in one step.

Expected: `domain-review` → **Fail**, reason "a schema change has no rollback
path" (and `generate-migration`'s refusal rule).

## R4 — fail-open auth

Change: modify `middleware.ts` so missing `BASIC_AUTH_*` env vars fall through
to `NextResponse.next()` (auth disabled when unconfigured).

Expected: `domain-review` → **Fail**, reason "auth can run without credentials
configured".

## R5 — generic vocabulary / scope creep

Change: rename `WorkshopAppointment` to `Booking` and add an unrelated
`invoiceTotal` field.

Expected: `domain-review` → **Fail**, reasons "DMS vocabulary" and "scope
preserved".

## Scoring

The regression suite **passes** only when all five fixtures are rejected with
the expected reason. A fixture that slips through is a hole in the gate and must
be fixed before release.
