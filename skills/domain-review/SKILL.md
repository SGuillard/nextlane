---
name: domain-review
description: Code-level, DMS-aware review of a proposed change — checks domain vocabulary, invalid-state coverage, status-graph completeness, validation placement, and schema rollback safety. Use as an automatable gate the day-2 agents run before proposing a commit.
---

# Domain Review

The **automated** half of the review gate. Where `grillme-with-docs` is your
manual, staff-level pressure-test against the brief, `domain-review` is a
mechanical, repeatable checklist a day-2 agent (or CI helper) runs on every
change without you in the loop. Run both; they catch different things.

## Read first

- `docs/definition-of-done.md` (the contract this gate enforces)
- `AGENTS.md` (DMS vocabulary + TypeScript conventions)
- The changed files + the diff

## Checklist (each item PASS / FAIL with evidence)

1. **Scope preserved** — change stays within the small DMS slice; no creep
   toward a full DMS.
2. **DMS vocabulary** — names use dealership terms (customer, vehicle, VIN,
   registration number, workshop appointment, service bay, technician), not
   generic CRM terms.
3. **Invalid states impossible** — every new field/state is validated
   server-side, close to the write. No write path bypasses validation.
4. **Status graph complete** — if statuses changed, every illegal transition is
   rejected and tested; no terminal state can be left.
5. **Validation is pure & tested** — domain logic lives in a pure module with
   unit tests covering each rule and each illegal transition.
6. **Tests moved with code** — schema/validation/behavior change has added or
   updated tests (no untested behavior change).
7. **Migration safety** — any schema change has a migration and a documented
   rollback/backfill path.
8. **Docs aligned** — README/build-spec/registry updated if behavior changed;
   no doc now describes something that does not exist.
9. **No secrets / fail-open auth** — no secrets committed; auth stays
   fail-closed (missing env → deny, never allow).

## Output

```md
## Domain review

### Verdict
Pass | Fail

### Findings
- [PASS/FAIL] <item> — <evidence / file:line>

### Required fixes
- ...
```

## Stop conditions (force Fail)

- A validation rule has no test.
- A status change leaves an illegal transition reachable.
- A schema change has no rollback path.
- Auth can run without credentials configured.
- Docs describe behavior the code does not implement.

This checklist is intentionally mechanical so it can later be partially
scripted (lint rules, type checks, a test-coverage assertion) and folded into
`npm run verify` / CI.
