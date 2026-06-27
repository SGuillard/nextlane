# Day-2 agent: triage-bug

Use this workflow to investigate a reported issue without broad rewrites.

## Input

```md
Bug report:
Observed behavior:
Expected behavior:
Reproduction steps:
Logs or screenshots:
```

## Process

1. Reproduce the issue or identify why it cannot be reproduced.
2. Classify the affected DMS workflow.
3. Identify the smallest fix.
4. Add a regression test before or alongside the fix.
5. Update docs if behavior changes.
6. Run verification.
7. Run `skills/grillme-with-docs` review.

## Output

```md
## Bug triage summary

### Reproduction
- ...

### Root cause
- ...

### Fix
- ...

### Regression coverage
- ...

### Verification
- ...
```
