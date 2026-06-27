---
name: scaffold-new-module
description: Generate a complete, conventional vertical slice (Prisma model, validation, route, UI, tests, seed, docs) for a new DMS entity or capability from a short spec. Use when adding a new module or a substantial new entity to the Nextlane slice.
---

# Scaffold New Module

The highest-leverage rail. Turns a short spec into a full vertical slice that
already passes the verification gate, so day-2 features — including the live
unseen task — become routine.

Use this when a change introduces a **new entity or module**. For a field or
behavior added to an existing entity, use `agents/day-2/build-feature.md`
instead (it reuses the same conventions).

## Read first

- `docs/definition-of-done.md` (what "complete slice" means — the contract)
- `docs/build-spec.md` (folder shape, validation conventions, auth)
- `AGENTS.md` (TypeScript + DMS vocabulary rules)

## Input

```md
Module name:            # e.g. "Service Bay", "Parts Order"
Purpose:                # one sentence, dealership-grounded
Fields:                 # name: type, required?, notes (use DMS vocabulary)
Statuses:               # discriminated union values, if the entity has a lifecycle
Status transitions:     # allowed edges, if any
Relationships:          # FKs to existing entities (customer, vehicle, ...)
Validation rules:       # invariants enforced server-side, close to the write
Out of scope:           # what this slice deliberately does NOT do
```

## Process

Generate every layer below. A slice missing any layer is incomplete and must
not be proposed for commit.

1. **Domain types** — explicit TypeScript types; discriminated unions for
   statuses.
2. **Prisma model + migration** — mirror the types; generate a migration with a
   rollback note (delegate to `agents/day-2/generate-migration.md` for the
   migration step).
3. **Pure validation module** — `src/domain/<entity>.ts` returning
   `{ ok: true } | { ok: false; errors: string[] }`, including the
   status-transition guard. No DB access in this module.
4. **Unit tests** — `src/domain/<entity>.test.ts` covering every validation
   rule and every illegal status transition.
5. **Data access + route** — route handler or server action that validates
   before writing, consistent with the existing slice.
6. **UI** — list/dashboard, create/edit form, detail view, reusing existing
   components and dealership labels.
7. **Seed** — extend `prisma/seed.ts` so the new module has visible demo data.
8. **Docs** — update `README.md` (artifact map / repository map) and add a
   short note to `docs/build-spec.md`; register the module so future agents
   discover it.

## Output

```md
## Scaffold summary

### Module
- <name> — <purpose>

### Files created / changed
- ...

### Validation rules implemented
- ...

### Tests added
- ...

### Verification
- npm run verify: <result>
- grillme-with-docs verdict: <result>

### Follow-ups / trade-offs
- ...
```

## Verification (required before proposing a commit)

- `npm run verify` passes.
- New unit tests cover every validation rule and illegal transition.
- `skills/domain-review` (code-level) and `skills/grillme-with-docs`
  (brief alignment) both pass.

## Refusal / escalation

- Refuse if the module expands the app beyond the deliberately-small scope in
  `project-plan.md` (e.g. invoicing, RBAC, OEM integrations) — surface it and
  ask before building.
- Escalate if the spec implies a breaking change to an existing entity's data;
  that needs a migration + backfill plan reviewed by a human.
- Do not introduce a new dependency unless the existing stack cannot solve the
  problem clearly.
