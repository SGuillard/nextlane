# Stack and authentication

We build the slice on Next.js (App Router) + TypeScript, Prisma over Supabase
Postgres, Better Auth for login, deployed to Vercel. This is a conventional,
well-supported stack with a single process for UI and API, and it matches the
reusable skills already in the repo (Prisma, TypeScript, auth).

## Considered options

- **Auth: Better Auth (chosen)** over **Supabase Auth** and **Clerk**.
  Supabase Auth was the obvious pick since the database is already Supabase, and
  Clerk is the least code. We chose Better Auth anyway because it keeps the user
  records in our own Prisma-managed tables (no second identity store, no extra
  vendor), and we already have a Better Auth skill. It supports both Google
  OAuth and email/password, which is all the gate requires.

## Consequences

- Login methods: Google OAuth + email/password.
- Users live in Prisma tables; domain rows reference the user id for the
  `createdBy` attribution, but the user record is owned by the auth layer.
- Lock-in is real (DB + auth), which is why this is recorded.
- Deployment safety controls (Vercel previews, production-from-`main`, skew
  protection, canary rollouts) live in Vercel settings, not the repo — recorded
  as deferred to-dos in [operations.md](../operations.md).
