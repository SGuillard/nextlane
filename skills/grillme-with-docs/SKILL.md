---
name: grillme-with-docs
description: Pressure-test a proposed Nextlane case study change against the brief and keep docs aligned with the implementation. Use before committing a feature, bug fix, migration, agent update, or documentation change.
---

# GrillMe with Docs

Review workflow for the Nextlane case study.

Use this skill before committing a feature, bug fix, migration, agent update, or documentation change.

## Goal

Pressure-test a change against the case study brief and keep the documentation aligned with the implementation.

## Inputs

- Requested change.
- Files changed.
- Verification commands run.
- Known trade-offs.

## Read first

- `docs/case-study-brief.md` (authoritative scoring and scope)
- `README.md`
- `docs/project-plan.md`
- `docs/case-study-implementation-options.md`
- `docs/ai-rails-strategy.md`
- `AGENTS.md`
- Changed files

## Rubric

Score each item from 1 to 5:

1. Case study alignment: small DMS slice, basic auth, deployability, four required artifacts, day-2 extensibility.
2. AI leverage: reusable rules, skills, subagents, scaffolds, tests, eval gates, or docs.
3. DMS domain quality: dealership-specific vocabulary and clear domain model.
4. Engineering safety: TypeScript, validation, migrations, tests, CI, security.
5. Documentation alignment: README and docs describe the current implementation.

## Output

```md
## GrillMe review

### Verdict
Pass | Pass with fixes | Needs work

### Scores
- Case study alignment: /5
- AI leverage: /5
- DMS domain quality: /5
- Engineering safety: /5
- Documentation alignment: /5

### Strong points
- ...

### Issues
- ...

### Recommended fixes
- ...

### Missing docs
- ...

### Verification required before commit
- [ ] npm run lint
- [ ] npm run typecheck
- [ ] npm test
- [ ] npm run build
- [ ] npm run verify, if available
```

## Stop conditions

Mark the review as `Needs work` when:

- the app cannot run,
- basic auth is broken or undocumented,
- a schema change has no validation or test update,
- behavior changes without tests or docs,
- one of the four required artifacts is removed or hidden,
- the MVP becomes too broad for the case study.

## Preferred fixes

Prefer small fixes that increase reusable leverage:

- update a rule,
- add an agent workflow,
- add a test,
- add a fixture,
- update documentation for future agents.
