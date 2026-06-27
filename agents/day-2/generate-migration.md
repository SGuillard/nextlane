# Day-2 agent: generate-migration

Use this workflow to produce a **safe** Prisma schema migration with a rollback
and backfill plan. Invoked by `scaffold-new-module` and `build-feature` whenever
a change touches the schema, or directly for a standalone schema change.

## Read first

- `docs/definition-of-done.md`
- `docs/build-spec.md` (data layer + Postgres/SQLite note)
- `AGENTS.md` (database and migration rules)

## Input

```md
Schema change:        # what the model needs (new field, entity, relation, enum value)
Reason:               # the product behavior driving it
Data impact:          # is there existing data to migrate? nullable vs required?
```

## Process

1. Restate the smallest schema change that satisfies the requirement.
2. Update `prisma/schema.prisma`.
3. Generate the migration (`prisma migrate dev --name <change>` locally;
   `prisma migrate deploy` in CI/prod).
4. **Backfill plan** — if a new column is required on existing rows, add it as
   nullable first, backfill, then tighten; never make an existing column
   required without a backfill.
5. **Rollback note** — document the inverse step and any data risk.
6. Update affected validation + tests so the new shape is enforced.
7. Run verification.
8. Run `domain-review` (rollback safety is a stop condition there).

## Output

```md
## Migration summary

### Schema change
- ...

### Migration
- name: <name>
- forward: <what it does>
- rollback: <inverse step + data risk>

### Backfill
- <plan, or "none — additive">

### Validation / tests updated
- ...

### Verification
- npm run verify: <result>
```

## Refusal / escalation

- Escalate any destructive change (drop column/table, narrow a type, remove an
  enum value) to a human before applying — these need an explicit backfill and
  rollback sign-off.
- Refuse to make an existing column required in one step without a backfill.
