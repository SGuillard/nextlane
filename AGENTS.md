# Agent operating rules

These rules apply to every AI agent working on this repository.

## Product scope

Build a deliberately small Dealer Management System slice. The recommended module is Service & Workshop Scheduling.

Do not expand toward a full DMS unless the user explicitly asks for it. The app is a pass/fail gate; the AI rails are the main evaluation target.

## Default workflow

For any feature request:

1. Read `README.md` and the relevant docs in `docs/`.
2. Identify the smallest vertical DMS workflow affected.
3. Update domain model, validation, UI, tests, and docs together.
4. Run the verification gate.
5. Use `skills/grillme-with-docs` to review the change.
6. Commit only after the gate passes.

## TypeScript conventions

- Use explicit domain types.
- Prefer discriminated unions for domain statuses.
- Keep validation close to write operations.
- Avoid `any` unless there is a documented reason.
- Keep server-only code out of client components.

## DMS vocabulary

Prefer dealership vocabulary:

- customer,
- vehicle,
- VIN,
- registration number,
- workshop appointment,
- technician,
- service bay,
- quote,
- stock item.

Avoid generic CRM vocabulary when a DMS-specific term is clearer.

## Safety rules

- Do not skip tests for schema or validation changes.
- Do not introduce external services for the MVP unless required for deployment.
- Do not store secrets in the repository.
- Keep basic auth documented and enabled in deployment.
- Prefer small commits with explicit messages.

## Verification

Expected gate:

```bash
npm run lint
npm run typecheck
npm test
npm run build
```

When `npm run verify` exists, use it as the canonical gate.
