---
name: ship-change
description: Finalize an already-implemented, verified change — create a feature branch, conventional commit, push, and open a PR with a structured description via the gh CLI. The shared tail of build-feature and triage-bug. Use as /ship-change when the change is green and reviewed.
metadata:
  version: '1.0.0'
  category: workflow
---

# Ship Change

Turns a finished, verified change into a pushed branch and a pull request. Runs
**after** the gate is green and `domain-review` has passed. No ticket system, no
changesets — the spec doc is the source of truth.

## Preconditions

- There are changes to ship (`git status` is not clean).
- `npm run verify` is green (lint, typecheck, tests, build, invariants).
- `domain-review` passed with no error-severity findings.
- **Never commit or push without an explicit request from the user.**

## Workflow

### 1. Branch

- If on `main`/`master`, create a feature branch from `main`:
  `git checkout -b feature/<kebab-description>`
- If already on a feature branch, keep using it.

### 2. Commit (Conventional Commits)

- `git add -A`
- Subject: `type: description` where type is one of
  `feat | fix | chore | refactor | docs | test | perf`.
- One clear subject line; add a body only when the *why* isn't obvious.
- End AI-authored commits with the trailer:
  `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`

### 3. Push

- `git push -u origin <branch>`

### 4. Open the PR (gh CLI, current repo's origin)

`gh pr create --base main --title "<conventional title>" --body "<body>"`

Body sections:

```markdown
## Summary
- Bullet points of what changed and why.

## Spec
Link to docs/specs/<feature>.md and the acceptance criteria it satisfies.

## Type of change
- [ ] Feature
- [ ] Fix
- [ ] Refactor
- [ ] Docs

## Test plan
How to verify, and which acceptance tests cover the change.
```

- No reviewers assigned (solo project).
- Do **not** hardcode a repo — `gh` uses the current repository's origin.
- End the PR body with:
  `🤖 Generated with [Claude Code](https://claude.com/claude-code)`

### 5. Summary

Print: branch name, commit subject, PR url.

## Notes

- AI review is **not** run here — `domain-review` already ran as a blocking
  step before this skill, on the working-tree diff. `ship-change` only commits
  and opens the PR.
