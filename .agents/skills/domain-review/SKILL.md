---
name: domain-review
description: Domain-aware review of the working-tree diff BEFORE a PR is opened. Runs the enabled review agents in parallel and checks the diff against CONTEXT.md, the ADRs, and the project invariants. A blocking self-check inside build-feature / triage-bug. Use as /domain-review.
metadata:
  version: '1.0.0'
  category: review
---

# Domain Review

Reviews the current change against the project's domain model and invariants
**before it ships**. Blocking: if any error-severity finding remains, the change
must not proceed to `ship-change` — fix and re-run.

## When it runs

The last step of `build-feature` / `triage-bug`, after the gate
(`npm run verify`) is green and before `ship-change`. It operates on the
**working-tree diff**, not a GitHub PR — the goal is to catch problems before
anything is public.

## Input

The cumulative diff of the change:

```bash
git diff main...HEAD   # committed work on the feature branch
git diff               # plus any uncommitted changes
```

If the combined diff is empty, report "nothing to review" and stop.

## Steps

1. Collect the diff (above).
2. Read `.claude/review-agents.json`, filter `enabled: true`.
3. Launch all agents in parallel, in a single message:
   - one `Agent()` per enabled generic skill (`security-review`, `code-review`),
   - plus one **domain agent** (prompt in [AGENTS.md](./AGENTS.md)).
4. The domain agent checks the diff against:
   - **Glossary** (`CONTEXT.md`) — flag terms that drift from the canonical
     language (e.g. `deal`/`order`/`proposal` where the term is `Quote`).
   - **Money invariant** — amounts are integer cents via the `Money` helper,
     never floats; `total = Σ(line items) − discount`.
   - **State machine** — forward-only; no edits to `sent`/`accepted`/`declined`/
     `expired` quotes; no illegal transitions.
   - **ADRs** (`docs/adr/`) — e.g. no speculative multi-tenancy (ADR-0003);
     stack and auth conventions (ADR-0001); verification-loop rules (ADR-0002).
5. Aggregate findings, dedupe, sort by file then line.
6. Print findings grouped by severity (`error` / `warn` / `info`).
7. **Gate:** if any `error` finding remains, print `BLOCKED` and the fix list,
   and stop the loop. Otherwise print `PASS`.

No GitHub interaction — this runs before the PR exists. `ship-change` opens the
PR afterwards.
