# Day-2 agent: build-feature

Use this workflow to implement a new product capability end to end after the MVP has shipped.

## Input

```md
Feature request:
Context:
Acceptance criteria:
Known constraints:
```

## Process

1. Read `README.md`, `docs/ai-rails-strategy.md`, and `AGENTS.md`.
2. Restate the smallest vertical slice.
3. Identify affected files.
4. Apply the change across:
   - domain model,
   - database schema or migration,
   - validation,
   - UI,
   - tests,
   - documentation.
5. Run verification.
6. Run `skills/grillme-with-docs` review.
7. Summarize what changed and what was verified.

## Output

```md
## Implementation summary

### Files changed
- ...

### Behavior added
- ...

### Tests added or updated
- ...

### Verification
- ...

### Documentation updated
- ...

### Remaining trade-offs
- ...
```

## Default prepared task

Add a `cancellationReason` field to cancelled workshop appointments.

Acceptance criteria:

- The field is required only when status is `cancelled`.
- The form displays the field conditionally.
- The appointment detail view displays the reason for cancelled appointments.
- Tests cover the validation rule.
- Docs mention the new behavior.
