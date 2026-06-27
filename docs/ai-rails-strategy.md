# AI rails strategy

The case study is weighted toward the system that lets AI extend and operate the product after the initial MVP. This document defines the rails to build and demo.

## Target loop

The repository should support this loop:

1. Read project rules and domain context.
2. Understand the requested feature or bug.
3. Propose a small implementation plan.
4. Apply the change across schema, domain logic, UI, tests, and docs.
5. Run deterministic verification.
6. Run an AI review gate.
7. Commit only if the gate passes.

## Artifact 1: agent config and rules

Create these files:

- `AGENTS.md`: canonical instructions for all AI agents.
- `CLAUDE.md`: Claude-specific working protocol.
- `.cursorrules`: Cursor-specific conventions.

They should cover:

- product scope,
- DMS domain vocabulary,
- TypeScript conventions,
- database and migration rules,
- test requirements,
- accessibility basics,
- security guardrails,
- commit discipline.

Recommended rule excerpt:

```md
Before modifying code, identify the smallest DMS workflow affected by the change. Keep changes vertical and complete: schema, validation, UI, tests, and docs. Do not introduce a new dependency unless the standard library or existing stack cannot solve the problem clearly.
```

## Artifact 2: reusable skills and subagents

Recommended reusable skill:

- `skills/grillme-with-docs/`

Purpose:

- force the AI to critique a proposed implementation against the case study brief,
- require documentation updates alongside code,
- check that the four required artifacts remain visible,
- produce a concrete follow-up checklist.

Recommended subagents:

- `agents/day-2/build-feature.md`
- `agents/day-2/triage-bug.md`
- `agents/day-2/generate-migration.md`
- `agents/day-2/on-call-diagnostics.md`
- `agents/day-2/dependency-upgrade.md`

Each subagent should specify:

- when to use it,
- input format,
- expected outputs,
- verification commands,
- refusal or escalation cases.

## Artifact 3: day-2 agents

The most important day-2 agent is `build-feature`.

It should implement a feature end to end:

```md
Given a feature request, produce and apply a vertical slice:

1. Domain model change.
2. Database migration if needed.
3. Validation update.
4. UI update.
5. Tests.
6. Documentation update.
7. Verification summary.
```

For the recommended workshop scheduling app, example tasks:

- Add cancellation reason.
- Add technician assignment.
- Add customer search.
- Add workshop bay capacity.
- Add appointment conflict detection.
- Add appointment history.

## Artifact 4: eval and verification loop

Minimum deterministic gate:

```bash
npm run lint
npm run typecheck
npm test
npm run build
```

Recommended package scripts:

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

Add an AI review gate as a documented manual or scripted step:

```md
AI review checklist:

- Does the change preserve the intentionally small product scope?
- Are domain names dealership-specific and understandable?
- Are invalid states impossible or validated?
- Are tests added or updated?
- Are docs updated if behavior changed?
- Is there a rollback path for schema changes?
```

## Suggested CI

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [main]

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
      - run: npm ci
      - run: npm run verify
```

## Basic auth strategy

Use middleware-level basic auth for the deployed demo.

```ts
import { NextRequest, NextResponse } from "next/server";

export function middleware(request: NextRequest) {
  const username = process.env.BASIC_AUTH_USERNAME;
  const password = process.env.BASIC_AUTH_PASSWORD;

  if (!username || !password) {
    return NextResponse.next();
  }

  const header = request.headers.get("authorization");
  const expected = `Basic ${Buffer.from(`${username}:${password}`).toString("base64")}`;

  if (header === expected) {
    return NextResponse.next();
  }

  return new NextResponse("Authentication required", {
    status: 401,
    headers: {
      "WWW-Authenticate": "Basic realm=\"Nextlane demo\"",
    },
  });
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
};
```

## Demo plan

Prepared day-2 demo:

1. Start from a working app.
2. Ask the `build-feature` agent to add cancellation reason.
3. Let the agent inspect rules and docs.
4. Apply schema, validation, UI, tests, and docs.
5. Run `npm run verify`.
6. Use `grillme-with-docs` to critique the change.
7. Commit.

This directly maps to the grading rubric and makes the live unseen task feel routine.
