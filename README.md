# Nextlane — Staff AI Engineer Case Study

A small Dealer Management System (DMS) slice, plus the **AI-engineering rails**
that let an AI agent keep extending and operating it after day one.

> Read `docs/case-study-brief.md` first. The app is a **pass/fail gate** (it
> must run, deploy, and log in) and is *not* scored directly. The score is
> weighted toward the rails: the four artifacts below (45 %) and day-2
> extensibility proven live (25 %). This repository is organized around that
> reality — see `docs/project-plan.md`.

## The slice

Service & Workshop Scheduling: customers, their vehicles, and workshop
appointments with status transitions and scheduling validation. Deliberately
small. See `docs/project-plan.md` for the domain model and scope boundaries.

## The four graded artifacts

| # | Artifact | Where |
|---|----------|-------|
| 1 | **Agent config & rules** | [`AGENTS.md`](AGENTS.md), [`CLAUDE.md`](CLAUDE.md), [`.cursorrules`](.cursorrules), [`docs/definition-of-done.md`](docs/definition-of-done.md) |
| 2 | **Reusable skills & subagents** | [`skills/scaffold-new-module/`](skills/scaffold-new-module/SKILL.md), [`skills/domain-review/`](skills/domain-review/SKILL.md), [`skills/grillme-with-docs/`](skills/grillme-with-docs/SKILL.md) |
| 3 | **Day-2 agents** | [`agents/day-2/`](agents/day-2/) — `build-feature`, `triage-bug`, `generate-migration`, `dependency-upgrade`, `on-call-diagnostics` |
| 4 | **Eval & verification loop** | `npm run verify` gate + CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) + the [agent-eval harness](eval/README.md) + the `domain-review` / GrillMe review gates |

## Running the app

> Status: the application slice is the build target described in
> `docs/project-plan.md`. The commands below are the canonical interface the
> rails and CI rely on.

```bash
npm install
npm run dev        # local dev server
npm run verify     # lint && typecheck && test && build  (the deterministic gate)
npm run test:e2e   # Playwright end-to-end
```

Basic auth is enforced via middleware and configured with environment
variables (`BASIC_AUTH_USERNAME`, `BASIC_AUTH_PASSWORD`); see
`docs/ai-rails-strategy.md`.

## How to run the day-2 agents

The day-2 agents are workflow definitions an AI coding agent (Claude Code,
Cursor, etc.) executes. Each one reads the project rules, applies a complete
vertical slice, and runs the verification gate before proposing a commit.

### `build-feature` — implement a feature end to end

Point your agent at [`agents/day-2/build-feature.md`](agents/day-2/build-feature.md)
and provide:

```md
Feature request: <what to add>
Context: <relevant area / constraints>
Acceptance criteria: <observable behavior>
Known constraints: <anything off-limits>
```

The agent applies the change across domain model, migration, validation, UI,
tests, and docs, runs verification, then runs the GrillMe review and returns an
implementation summary. A prepared demo task ("add `cancellationReason` to
cancelled appointments") is included in the file.

### `triage-bug` — investigate a reported issue

Point your agent at [`agents/day-2/triage-bug.md`](agents/day-2/triage-bug.md)
and provide the bug report, observed vs expected behavior, reproduction steps,
and any logs. The agent reproduces, finds the smallest fix, adds a regression
test, and runs verification.

## How to run the skills

[`skills/scaffold-new-module`](skills/scaffold-new-module/SKILL.md) — the
highest-leverage rail. Give it a short module spec (entity, fields, statuses,
validation rules) and it generates a complete vertical slice (Prisma model +
migration, validation + tests, route + UI, seed, docs) that already passes the
gate. Use it when adding a new entity/module; use `build-feature` for changes to
an existing entity.

[`skills/domain-review`](skills/domain-review/SKILL.md) — the **automated**
review gate the day-2 agents run before proposing a commit. A mechanical,
DMS-aware checklist (vocabulary, invalid-state coverage, status-graph
completeness, migration rollback, fail-closed auth) returning `Pass` / `Fail`.

[`skills/grillme-with-docs`](skills/grillme-with-docs/SKILL.md) — the **manual,
staff-level** pressure-test against the brief on a 1–5 rubric, emitting `Pass` /
`Pass with fixes` / `Needs work`. Run both: `domain-review` is the repeatable
gate that does not depend on a human; GrillMe is the judgment layer on top. In
Claude Code each is invoked as `/<skill-name>`; with any other agent, follow the
`SKILL.md` workflow directly.

## How to run the eval

[`eval/`](eval/README.md) tests the **rails themselves**, not just the app:
golden feature specs that the agents must implement completely (every layer of
[`definition-of-done.md`](docs/definition-of-done.md)) and seeded bad changes
the review gate must reject. `npm run verify` is the deterministic, CI-enforced
gate; the agent-eval is run on demand because it needs an AI agent to drive each
spec. See [`eval/README.md`](eval/README.md).

## The day-2 loop

```txt
Ship → Observe & triage → AI proposes change → Verify & gate → Ship
                  (powered by: rules · skills · day-2 agents · evals)
```

## Repository map

```txt
docs/        brief, project plan, build spec, definition of done, strategy, options
AGENTS.md    canonical rules for all AI agents
CLAUDE.md    Claude-specific working protocol
.cursorrules Cursor conventions
skills/      reusable skills (scaffold-new-module, domain-review, grillme-with-docs)
agents/day-2 day-2 agents (build-feature, triage-bug, generate-migration,
             dependency-upgrade, on-call-diagnostics)
eval/        agent-eval harness (golden specs, regression fixtures, assertions)
.github/     CI workflow (the enforced npm run verify gate)
```
