# Agent eval harness

This is artifact #4 taken one step past "the app has tests": it tests the
**rails themselves**. The deterministic gate (`npm run verify`) proves the
*app* is correct. The eval here proves the *agents* are correct — that
`build-feature` / `scaffold-new-module` actually produce a complete vertical
slice, and that the review gate actually blocks a bad change.

## Two gates, different jobs

| Gate | Proves | Runs |
|---|---|---|
| `npm run verify` (lint+typecheck+test+build) | the app is correct | every change, **enforced in CI** |
| agent-eval (this dir) | the *agents* produce correct, complete changes | before a release / when rails change; semi-automated (needs an AI agent) |

Be honest about the boundary: `verify` is fully deterministic and CI-enforced.
agent-eval needs an AI agent in the loop to *run* the golden specs, so it is run
locally/on demand, and its *assertions* are deterministic and scriptable.

## What it checks

1. **Coverage** — for each golden spec in `eval/golden-specs.md`, run
   `build-feature`/`scaffold-new-module` and assert the change touched every
   required layer from `docs/definition-of-done.md`
   (model · migration · validation · UI · tests · docs) and that
   `npm run verify` passes.
2. **Regression catch** — apply the seeded bad change in
   `eval/regression-fixtures.md` and assert `domain-review` returns **Fail**
   for the stated reason. A gate that never blocks anything is not a gate.

## How to run

```md
1. For each golden spec: run agents/day-2/build-feature.md with that spec.
2. Score it against eval/assertions.md (coverage + verify green).
3. For each regression fixture: apply it, run skills/domain-review,
   assert verdict = Fail with the expected reason.
4. Record results; any failing assertion blocks the release.
```

When the app exists, the coverage and regression *assertions* (file-touch
checks, `verify` exit code, presence of the expected `domain-review` failure)
are wrapped behind `npm run eval` so the scoring is one command. The agent step
that generates each change stays human/AI-driven.

## Files

- `golden-specs.md` — feature specs the agents must implement completely.
- `regression-fixtures.md` — seeded bad changes the review must reject.
- `assertions.md` — the deterministic pass/fail criteria.
