# Build spec — Service & Workshop Scheduling slice

> This is the concrete *what* and *how* behind `project-plan.md`. The plan sets
> scope and priorities; this document is what an agent (or a human) builds
> against. Keep it aligned with the implementation — when behavior changes,
> this file changes with it.

## Scope decision (locked)

- **In:** Customer, Vehicle, Workshop Appointment, and a minimal **Service Bay**
  so the no-double-booking rule is a real, dealership-grounded constraint
  (a bay is a finite resource; two appointments cannot share a bay and time).
- **Out of MVP, reserved as live-extension tasks:** technician assignment, bay
  capacity (>1 vehicle per bay), no-show status, customer search,
  next-available-slot.
- **Out entirely:** in-product AI features, multi-agent orchestration, RAG,
  sales/inventory/invoicing, RBAC, real email/SMS. See `project-plan.md`
  "What we are NOT building".

The app stays small on purpose. Effort goes to the rails (45%) and to keeping
the slice trivially extendable for the live task (25%).

## Domain model

```ts
type ServiceBay = {
  id: string;
  name: string;        // "Bay 1", "Bay 2" — dealership-facing label
};

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
  serviceBayId: string;        // the finite resource the conflict rule guards
  startsAt: string;            // ISO 8601
  endsAt: string;              // ISO 8601
  status: WorkshopAppointmentStatus;
  reason: string;              // why the vehicle is in (e.g. "brake service")
  notes?: string;
};
```

`serviceBayId` is the one addition over the original plan's model. It is the
hook that makes double-booking validation, and later the bay-capacity and
technician live tasks, anchor onto something real.

## Validation rules (the testable core)

All enforced **server-side, close to the write** (create/update appointment).
Each rule gets a unit test; the bay-conflict rule also gets one e2e assertion.

1. **No appointment in the past** — `startsAt` must be >= now (on create).
2. **Time ordering** — `endsAt` must be strictly after `startsAt`.
3. **No bay double-booking** — for a given `serviceBayId`, no two
   non-cancelled appointments may overlap in `[startsAt, endsAt)`. Cancelled
   appointments free the bay.
4. **Status transition graph** — only the edges below are allowed:

```txt
requested  -> confirmed | cancelled
confirmed  -> in_progress | cancelled
in_progress-> done | cancelled
done       -> (terminal)
cancelled  -> (terminal)
```

Validation lives in a pure module (`src/domain/appointment.ts`) returning a
typed result (`{ ok: true } | { ok: false; errors: string[] }`) so it is unit
-testable without a DB and reusable by both the API route and any future agent
code.

## Screens & routes

App Router, all behind basic-auth middleware.

| Route | Purpose | Notes |
|---|---|---|
| `/` | Appointment dashboard / list | default view; shows status + bay + time |
| `/appointments/new` | Create form | bay + customer + vehicle pickers, time, reason |
| `/appointments/[id]` | Detail view | full record + allowed status actions |
| `/appointments/[id]/edit` | Edit form | same validation as create |

Minimal customer + vehicle management exists only to support appointments
(seeded data + a thin create form is enough; no separate CRM screens).

Data access through Next.js Route Handlers (`/api/appointments`, etc.) or
server actions — pick one and keep it consistent. Validation runs in the
handler/action before any write.

## Auth (fail-closed — fixes the review finding)

Middleware basic auth, credentials from env (`BASIC_AUTH_USERNAME`,
`BASIC_AUTH_PASSWORD`). **If the env vars are missing, return 503 / refuse the
request** rather than `next()`. The deployed gate must never silently run
without auth.

```ts
export function middleware(request: NextRequest) {
  const username = process.env.BASIC_AUTH_USERNAME;
  const password = process.env.BASIC_AUTH_PASSWORD;

  // Fail closed: misconfiguration must not disable auth on the deployed app.
  if (!username || !password) {
    return new NextResponse("Auth not configured", { status: 503 });
  }

  const header = request.headers.get("authorization");
  const expected =
    `Basic ${Buffer.from(`${username}:${password}`).toString("base64")}`;

  if (header === expected) return NextResponse.next();

  return new NextResponse("Authentication required", {
    status: 401,
    headers: { "WWW-Authenticate": 'Basic realm="Nextlane demo"' },
  });
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico).*)"],
};
```

A local override (`ALLOW_NO_AUTH=1`, dev-only) may relax this for tests, but it
is never set in deployment and is documented as such.

## Data layer

- **Prisma** with `provider = "postgresql"`. Production is a **Supabase**
  free-tier Postgres; local dev runs the same engine via the Supabase CLI
  (`supabase start`, Postgres in Docker) so there is **no provider mismatch** —
  migrations are generated against the same database they ship to.
- **Two connection strings (the Prisma-on-serverless detail that matters):**
  - `DATABASE_URL` → Supabase **pooled** connection (PgBouncer, port `6543`,
    transaction mode). The app's runtime uses this so serverless fan-out cannot
    exhaust Postgres connections.
  - `DIRECT_URL` → Supabase **direct** connection (port `5432`). Prisma uses
    this for `migrate` / introspection, which need a non-pooled session.
  Both are env vars, never committed; documented in the README.
- `prisma/schema.prisma` mirrors the domain model above and declares both
  `url = env("DATABASE_URL")` and `directUrl = env("DIRECT_URL")`.
- `prisma/seed.ts` seeds: 3–4 service bays, a handful of customers + vehicles,
  and a spread of appointments across statuses so the panel can log in and
  click around immediately.

> We use Supabase only as a hosted Postgres (database + connection pooler). We
> are **not** adopting Supabase Auth, its client SDK, or row-level security —
> basic auth stays in middleware and all access goes through Prisma. Keeps the
> dependency surface small and the slice portable.

## File / folder shape (flat and conventional)

```txt
src/
  app/                       # routes + server actions/handlers
    api/appointments/...
    appointments/...
    page.tsx                 # dashboard
  domain/
    appointment.ts           # pure validation + status-graph logic
    appointment.test.ts      # unit tests for the rules
  lib/
    db.ts                    # Prisma client
  middleware.ts              # basic auth (fail-closed)
prisma/
  schema.prisma
  seed.ts
e2e/
  appointment.spec.ts        # one happy path + one bay-conflict block
```

No speculative `agents/` runtime, `vector-store/`, or `ai/orchestrator` —
those appear only when a real feature needs them.

## Verification gate

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

`npm run verify` is the canonical deterministic gate. CI
(`.github/workflows/ci.yml`, Node 22) runs `npm ci && npm run verify` on PR and
on push to `main`; green is the merge condition.

## The rails — concrete detail

### Reusable skills

- `grillme-with-docs` — **exists.** The AI review gate (this review you're
  reading). Run before every commit.
- `scaffold-new-module` — **to build, highest priority.** Given a short spec
  (entity name, fields, statuses), it generates a full vertical slice: Prisma
  model + migration, pure validation module + tests, route + form + detail
  view, seed update, and a docs stub. This is the artifact the 45% leans on and
  it should be built right after the app shell so it can scaffold the slice
  itself.

### Day-2 agents

- `build-feature` — **exists.** End-to-end feature slice + verify + review.
- `triage-bug` — **exists.** Reproduce → smallest fix → regression test.
- `generate-migration`, `on-call-diagnostics`, `dependency-upgrade` —
  **decision: trim from the docs for now** OR add as explicit "planned" stubs.
  Do not leave them described as if they exist. (See review finding #2.)

### AI review gate wiring

The gate is `grillme-with-docs`, invoked manually as `/grillme-with-docs` (or
by following `SKILL.md`) as the last step of every day-2 agent before it
proposes a commit. It **blocks** on: scope preserved, DMS-specific names,
invalid states impossible/validated, tests added, docs updated, rollback path
for schema changes.

## Live-extension task bench (proves day-2, 25%)

Each maps cleanly onto `scaffold-new-module` / `build-feature` and anchors on
the model above:

| Task | Touches |
|---|---|
| Add cancellation reason | field + conditional validation + form + detail + test |
| Add technician assignment | new lookup + FK on appointment + UI + test |
| Add bay capacity (>1/bay) | relax conflict rule + config + test |
| Add no-show status | extend status graph + transitions + test |
| Add customer search | query + UI, no schema change |
| Next-available-slot | pure function over appointments + bays + UI |

The prepared demo task is **cancellation reason** (already specified in
`agents/day-2/build-feature.md`).

## Implementation sequence (fits 1–2 days)

1. App shell: Next.js + TypeScript + Tailwind + `package.json` scripts.
2. Basic-auth middleware (fail-closed).
3. Prisma schema (incl. `ServiceBay`) + seed.
4. Pure `domain/appointment.ts` validation + status graph + unit tests.
5. Appointment CRUD: dashboard, create/edit form, detail view.
6. One e2e happy path + one bay-conflict block.
7. `scaffold-new-module` skill (so it can scaffold future slices).
8. Wire `npm run verify` + CI + the `grillme-with-docs` gate.
9. Reconcile docs (README status, agent roster) with reality.
10. Deploy to Vercel + Supabase Postgres; confirm login works on the live URL.
11. Prepare the cancellation-reason demo task end to end.
```
