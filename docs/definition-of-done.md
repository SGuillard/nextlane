# Definition of Done

> Single source of truth for "a complete change". The rules (`AGENTS.md`,
> `CLAUDE.md`, `.cursorrules`), the day-2 agents, the review skills
> (`grillme-with-docs`, `domain-review`), and the eval harness (`eval/`) all
> reference this file. If this list changes, those reference it rather than
> redefining "done" — that is what keeps the rails consistent.

A change is **done** only when every applicable item holds.

## Vertical slice complete

A change to product behavior touches every applicable layer:

- [ ] **Domain model** — explicit TypeScript types; discriminated unions for
      statuses.
- [ ] **Schema + migration** — Prisma model updated; migration generated with a
      documented rollback/backfill note.
- [ ] **Validation** — enforced server-side, close to the write, in a pure
      module returning a typed result.
- [ ] **UI** — list/detail/form updated as needed, using dealership vocabulary.
- [ ] **Tests** — unit tests for every validation rule and every illegal status
      transition; e2e for any new happy path.
- [ ] **Docs** — README / `docs/build-spec.md` / registries updated; no doc
      describes anything that does not exist.

## Quality bar

- [ ] Scope stayed within the deliberately-small DMS slice.
- [ ] Names are DMS-specific and understandable.
- [ ] Invalid states are impossible or validated.
- [ ] Auth remains fail-closed; no secrets committed.

## Gate passed

- [ ] `npm run verify` (lint + typecheck + test + build) is green.
- [ ] `domain-review` verdict: Pass.
- [ ] `grillme-with-docs` verdict: Pass or Pass with fixes (fixes applied).

Only after all applicable boxes are checked may a change be proposed for commit.
