# Project Plan

> Recadrage : ce plan suit le barème du `case-study-brief.md`. L'app DMS est un
> **gate pass/fail (non noté)** ; la note vient des **rails IA** (45 %) et de
> **l'extensibilité day-2 prouvée en live** (25 %). On garde donc l'app
> délibérément petite et on met l'énergie de Staff dans la machinerie qui
> *construit et opère* l'app.

## Goal

Build a deliberately small Dealer Management System slice that runs, deploys on
a free-tier host, and is protected by basic auth — and, around it, the
AI-engineering rails that let an AI agent keep extending and operating it after
day one.

The product is the gate. The rails are the deliverable.

## Scoring reality (drives every decision below)

| Dimension | Weight | Where the effort goes |
|---|---|---|
| AI leverage & artifact quality (the four artifacts) | 45 % | **Most of our time** |
| Day-2 extensibility, proven live | 25 % | Day-2 agents + a clean, extendable slice |
| Engineering judgment & delivery (incl. the app) | 20 % | Scoping, tests, auth, CI, deploy |
| Communication & technical leadership | 10 % | README + clear narration |
| App correctness | pass/fail, not scored | Must run, deploy, log in |

Two consequences we commit to:

1. **The app stays small and conventional.** No in-product multi-agent system,
   no customer chat, no RAG as the core. Those would consume the whole time
   budget building the *unscored* part, and would make the live extension task
   (25 %) riskier, not easier.
2. **The slice is built to be extended.** The live session hands us a fresh
   task to implement with our own scaffolding. A thin, clean slice with a
   `build-feature` agent on top makes that "the easy part" — which is the point.

## The slice: Service & Workshop Scheduling

Chosen because it is a real DMS workflow, has meaningful schema/validation
(scheduling constraints, status transitions), and offers credible, varied
live-extension tasks.

### Domain model (intentionally minimal)

```ts
type Customer = {
  id: string;
  name: string;
  email: string;
  phone?: string;
};

type Vehicle = {
  id: string;
  customerId: string;
  vin: string;
  make: string;
  model: string;
  registrationNumber: string;
};

type WorkshopAppointmentStatus =
  | "requested"
  | "confirmed"
  | "in_progress"
  | "done"
  | "cancelled";

type WorkshopAppointment = {
  id: string;
  customerId: string;
  vehicleId: string;
  startsAt: string;
  endsAt: string;
  status: WorkshopAppointmentStatus;
  reason: string;
  notes?: string;
};
```

### Screens

- Login (basic auth).
- Appointment dashboard / list.
- Appointment create & edit form.
- Appointment detail view.
- Minimal customer + vehicle management to support appointments.

### Domain rules worth validating (these make tests meaningful)

- No appointment in the past.
- `endsAt` after `startsAt`.
- No double-booking of the same service bay / slot.
- Status transitions follow the allowed graph (e.g. `done` cannot go back to
  `requested`).

### Optional single AI touch (only if rails are done first)

At most **one** small, grounded in-product AI feature — and only if it falls
naturally out of the `build-feature` agent, so it doubles as a rails demo.
Candidate: "suggest next available slot" from existing appointments. Everything
else stays out of the product. This is a nice-to-have, never a priority.

## The four artifacts (the real deliverable — 45 %)

### 1. Agent config & rules

- `AGENTS.md` — canonical rules for all agents (already drafted).
- `CLAUDE.md` — Claude working protocol (already drafted).
- `.cursorrules` — Cursor conventions (already drafted).

They encode: product scope (and the "keep it small" guardrail), DMS
vocabulary, TypeScript conventions, DB/migration rules, test requirements,
security guardrails, commit discipline. **Keep them tight and consistent** —
contradictions between docs read as a scoping failure.

### 2. Reusable skills & subagents

- `grillme-with-docs` — critiques a change against the brief and forces docs +
  tests to move with code (already drafted).
- `scaffold-new-module` — generates a new vertical slice (schema → validation →
  UI → tests → docs) from a short spec. This is the highest-leverage artifact;
  it is what makes day-2 fast.
- A domain-aware code reviewer skill (DMS vocabulary, invalid-state checks,
  rollback path for schema changes).

### 3. Day-2 agents

The headline agent is `build-feature`: given a feature request, it applies a
complete vertical slice and reports a verification summary.

```md
1. Domain model change.
2. Database migration if needed.
3. Validation update.
4. UI update.
5. Tests.
6. Documentation update.
7. Verification summary.
```

Supporting agents:

- `triage-bug` — turn a bug report into a reproducible, scoped fix plan.
- `generate-migration` — safe Prisma migration with a rollback note.
- `on-call-diagnostics` — read logs/state, propose a remediation.
- `dependency-upgrade` — bump deps, run the gate, summarize the diff.

Each specifies: when to use, input format, expected outputs, verification
commands, refusal/escalation cases.

Prepared live-extension examples (so the demo task feels routine): add
cancellation reason, technician assignment, workshop bay capacity, no-show
status, customer search, next-available-slot.

### 4. Eval & verification loop

Deterministic gate (the canonical command):

```bash
npm run verify   # lint && typecheck && test && build
```

Scripts:

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "lint": "next lint",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "test:e2e": "playwright test",
    "verify": "npm run lint && npm run typecheck && npm test && npm run build"
  }
}
```

AI review gate (scripted or documented checklist) that runs after a generated
change and **blocks** on:

- scope preserved (still small)?
- DMS-specific, understandable names?
- invalid states impossible / validated?
- tests added or updated?
- docs updated if behavior changed?
- rollback path for schema changes?

A small eval set targets the agents themselves, not an in-product LLM: given a
feature spec, does `build-feature` touch all of schema/validation/UI/tests/docs
and pass the gate? Does the reviewer catch a seeded invalid-state regression?

## Technical architecture

- Next.js App Router + TypeScript.
- Prisma; SQLite locally, Postgres on the deployed host.
- Tailwind CSS.
- Vitest (unit) + Playwright (e2e).
- Basic auth via middleware (env-driven; see `ai-rails-strategy.md`).

Folder shape stays flat and conventional — domain logic, app routes, agents,
skills, tests. No speculative `agents/` fleet, no `vector-store/`, no
`ai/orchestrator` until a real feature needs it.

## CI

`.github/workflows/ci.yml` runs `npm ci && npm run verify` on PR and on push to
`main` (Node 22). Green gate is the merge condition.

## Deployment & auth

- Deploy to a free-tier host (Vercel + a hosted Postgres, or equivalent).
- Middleware basic auth, credentials from env vars, documented in the README.
- Seed an admin-visible dataset so the panel can log in and click around.

## Implementation sequence (fits 1–2 days)

1. App shell: Next.js + TypeScript + Tailwind.
2. Basic auth middleware.
3. Prisma schema + seed data for the slice.
4. Appointment CRUD + dashboard + scheduling validation.
5. Unit tests for scheduling rules; one e2e happy path.
6. Finalize the four config/rules files (already drafted).
7. Author `scaffold-new-module` skill + `build-feature` agent + reviewer.
8. Wire `npm run verify`, the AI review gate, and CI.
9. Deploy; confirm auth and login work on the live URL.
10. README pointing to each artifact + how to run the day-2 agents.
11. Prepare one day-2 task to demo (e.g. cancellation reason) end to end.
12. (Optional, only if time remains) the single grounded AI touch.

## What we are NOT building

- In-product customer chat or multi-agent orchestration.
- Vector knowledge base / RAG as a core feature.
- Sales leads, recommendations, inventory-for-sale surfaces.
- Invoicing, payments, financing, parts, OEM integrations, RBAC, real
  email/SMS.

These were in the previous draft; they belong (if anywhere) to a single,
optional rails-demo — not the MVP. The product stays small so the rails are the
star.

## Demo narrative (live session)

1. Show the deployed app and log in (proves the gate).
2. Walk through the four artifacts in the repo.
3. Run the prepared day-2 task with `build-feature` end to end; show the gate
   and the AI review block/pass.
4. Take the panel's fresh task and implement it live with the same scaffolding.
5. Show tests, CI, and the verification summary the agent produced.
6. Explain how the rails make unknown future features routine and safe.
