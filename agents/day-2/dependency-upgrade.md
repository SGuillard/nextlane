# Day-2 agent: dependency-upgrade

Use this workflow to bump dependencies safely and report the risk. Keeps the
stack current without turning an upgrade into an unscoped refactor.

## Read first

- `docs/definition-of-done.md`
- `AGENTS.md` (do not add dependencies the existing stack already covers)

## Input

```md
Scope:        # specific package(s), or "patch/minor across the board"
Constraints:  # anything that must not change (e.g. stay on Next major N)
```

## Process

1. List current vs target versions; classify each bump (patch / minor / major).
2. Apply patch and minor bumps first; hold majors for explicit approval.
3. Run `npm run verify` after each meaningful group.
4. For any failure, read the changelog/migration guide and apply the smallest
   adaptation; do not refactor beyond what the upgrade requires.
5. Note any new deprecation warnings.
6. Run `domain-review`.

## Output

```md
## Upgrade summary

### Bumped
- <pkg> <from> -> <to>  (patch|minor|major)

### Held (need approval)
- <pkg> <from> -> <to> (major) — reason

### Verification
- npm run verify: <result>

### Risk / follow-ups
- <breaking changes, deprecations, anything to watch>
```

## Refusal / escalation

- Do not apply major version bumps without explicit approval.
- Escalate if a security advisory requires a major bump that breaks the gate —
  report the advisory and the blast radius rather than forcing it through.
