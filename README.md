# Nextlane Staff AI Engineer Case Study

This repository is prepared for the Nextlane Staff / Principal AI Engineer case study.

The brief is not to build a full Dealer Management System. The app is a pass/fail gate: it must run, be deployed, and provide basic authentication. The main evaluation target is the AI engineering system around the app: rules, reusable skills, day-2 agents, and verification loops that let an AI agent extend the product safely after day one.

## Recommended implementation

Build a small **Service & Workshop Scheduling** DMS slice.

Why this slice:

- It is clearly DMS-relevant.
- It is small enough for a 1-2 day take-home.
- It creates realistic extension tasks for the live session: add technician capacity, add appointment statuses, add customer notifications, add vehicle history, add bay utilization, add parts reservation.
- It demonstrates product judgment without requiring a full ERP-style DMS.

Core MVP:

- Basic auth-protected app.
- Customers.
- Vehicles.
- Workshop appointments.
- Appointment statuses: `requested`, `confirmed`, `in_progress`, `done`, `cancelled`.
- Simple dashboard with today's appointments and next available slots.
- Minimal CRUD for appointments.
- Seed data for demo.

Suggested stack:

- Next.js App Router + TypeScript.
- Tailwind CSS.
- Prisma + SQLite for local development, or Prisma + Postgres if deployed with a free-tier database.
- Vercel for deployment.
- Playwright or Vitest for verification.
- GitHub Actions as the CI gate.

## Case study artifacts

The repo should expose the four required artifacts explicitly:

| Artifact | Proposed location | Purpose |
| --- | --- | --- |
| Agent config & rules | `AGENTS.md`, `CLAUDE.md`, `.cursorrules` | Encode project conventions, DMS domain context, guardrails, and workflows. |
| Reusable skills & subagents | `skills/grillme-with-docs/`, `.claude/commands/`, `agents/` | Give the model repeatable workflows instead of one-off prompts. |
| Day-2 agents | `agents/day-2/` | Implement new features, triage bugs, generate migrations, and diagnose failures. |
| Eval & verification loop | `tests/`, `evals/`, `.github/workflows/ci.yml` | Block unsafe AI-generated changes before they ship. |

## Documentation

- [Implementation options and recommendation](docs/case-study-implementation-options.md)
- [AI rails strategy](docs/ai-rails-strategy.md)
- [GrillMe with Docs skill](skills/grillme-with-docs/SKILL.md)

## Demo narrative

1. Show the running DMS slice behind basic auth.
2. Explain that the app is intentionally small and the scoring focus is the rails.
3. Walk through `AGENTS.md` / `CLAUDE.md` / `.cursorrules`.
4. Run the prepared day-2 task, for example: add appointment cancellation reason.
5. Show tests and eval gate catching regressions.
6. During the live unseen task, use the same rails rather than improvising.

## Prepared day-2 task

Recommended prepared task:

> Add a `cancellationReason` field to cancelled workshop appointments, expose it in the appointment form, validate that it is required only when status is `cancelled`, and display it in the appointment detail view.

This is small, domain-relevant, touches schema, UI, validation, tests, and demonstrates the full AI loop.
