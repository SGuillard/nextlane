# Day-2 agent: on-call-diagnostics

Use this workflow to investigate a live incident on the deployed app and propose
a remediation — the "operate" half of the day-2 loop. It diagnoses and proposes;
it does not push fixes to production on its own.

## Read first

- `docs/build-spec.md` (auth, data layer, routes)
- `AGENTS.md`

## Input

```md
Symptom:          # what users / monitoring report
When started:     # first seen, recent deploys
Scope:            # who/what is affected
Logs / signals:   # error output, status codes, metrics
```

## Process

1. Restate the symptom and its blast radius.
2. Form ranked hypotheses (recent deploy, migration, auth misconfig, data, host).
3. Inspect read-only signals: logs, recent commits/migrations, env config
   (presence, never values), health of the route involved.
4. Identify the most likely root cause with evidence.
5. Propose remediation, smallest first: config fix, rollback, or a scoped code
   fix routed through `build-feature` / `triage-bug`.
6. Note a guardrail to prevent recurrence (a test, a validation, a check).

## Output

```md
## Diagnostics summary

### Symptom & impact
- ...

### Most likely root cause
- <cause> — <evidence>

### Remediation (smallest first)
1. ...

### Prevent recurrence
- ...
```

## Refusal / escalation

- Do not mutate production data or apply a destructive remediation without human
  approval; propose it and stop.
- Escalate immediately if the symptom indicates exposed secrets or auth running
  without credentials (fail-open) — that is a security incident.
