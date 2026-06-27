# Eval assertions

The deterministic pass/fail criteria the harness applies after an agent runs a
golden spec or a regression fixture. These are mechanical so they can be
scripted behind `npm run eval` once the app exists.

## Coverage assertions (per golden spec)

For the change produced by the agent, assert each required layer was touched:

| Layer | Deterministic check |
|---|---|
| Domain model | a `src/domain/*.ts` type changed |
| Migration | a new file under `prisma/migrations/` (if schema changed) |
| Validation | the pure validation module changed |
| UI | a route/form/detail file under `src/app/` changed |
| Tests | a `*.test.ts` / `e2e/*.spec.ts` added or changed |
| Docs | `README.md` or `docs/*.md` changed |

Then assert `npm run verify` exits 0.

**Spec passes** = all required layers touched AND verify green.

## Regression assertions (per fixture)

- Run `skills/domain-review` on the seeded change.
- Assert verdict = **Fail**.
- Assert the failure reason matches the fixture's expected stop condition.

**Fixture passes** = the bad change was rejected for the right reason.

## Suite result

```md
## Agent eval result
- Golden specs: <n passed> / <n total>   (list any missed layer)
- Regression fixtures: <n rejected> / <n total>   (list any that slipped)
- Verdict: PASS only if both groups are 100%.
```

## Why 100%

A leaked layer means an agent ships incomplete slices; a slipped fixture means
the gate does not actually block. Either undermines the day-2 loop, so the
release bar is all-green, not best-effort.
