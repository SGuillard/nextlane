# Golden specs

Feature specs the day-2 agents must implement **completely** (every layer in
`docs/definition-of-done.md`) and pass `npm run verify`. These double as the
prepared and likely live-extension tasks, so a green eval here is direct
evidence the live task will go smoothly.

Each spec is the exact input format `agents/day-2/build-feature.md` expects.

## G1 — cancellation reason (the prepared demo)

```md
Feature request: Add a cancellationReason to cancelled appointments.
Context: WorkshopAppointment; status already includes "cancelled".
Acceptance criteria:
- cancellationReason is required only when status is "cancelled".
- The edit form shows the field conditionally on status = cancelled.
- The detail view shows the reason for cancelled appointments.
Known constraints: do not change other statuses; keep the slice small.
```

Required coverage: model · migration · validation (conditional-required) · UI
(form + detail) · unit test for the rule · docs.

## G2 — technician assignment

```md
Feature request: Assign a technician to an appointment.
Context: introduce a Technician lookup; appointment gets an optional technicianId.
Acceptance criteria:
- A technician can be selected on create/edit.
- The detail and list views show the assigned technician.
Known constraints: a thin lookup, not a full HR module.
```

Required coverage: new entity + relation · migration · validation (FK exists) ·
UI · seed update · tests · docs.

## G3 — no-show status

```md
Feature request: Add a "no_show" status for appointments the customer missed.
Context: extends WorkshopAppointmentStatus and the transition graph.
Acceptance criteria:
- confirmed -> no_show is allowed; no_show is terminal.
- Illegal transitions into/out of no_show are rejected.
Known constraints: do not alter existing legal transitions.
```

Required coverage: enum/type · migration · status-graph update · tests for the
new legal edge AND rejected illegal edges · UI · docs.

## Scoring

A spec **passes** when, after the agent runs it:

- every required layer above was changed, and
- `npm run verify` is green, and
- `domain-review` and `grillme-with-docs` both pass.

Any missing layer = fail (the rail leaks). Record which layer was missed.
