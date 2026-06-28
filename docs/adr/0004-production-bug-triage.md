# Production bug triage

How a bug in the **live** product becomes a verified fix. This is the day-2
`triage-bug` agent's job — the "Observe & triage" half of the loop, as opposed to
`domain-review`, which prevents bad changes *before* they ship. A production bug
flows: detection → a structured issue → reproduce (failing test) → diagnose →
fix → the existing gate → a human-merged PR. The fix re-enters the same pre-ship
rails on the way out; triage is just a second entry point into the gate.

## The flow

```
detection ──► GitHub issue (bug template, `triage` label) ──► triage-bug run
                                                                  │
   reproduce (failing test = the contract) ──► diagnose root cause ──► fix
                                                                  │
   GATE (npm run verify + invariants + domain-review) ──► open PR ──► human merges
```

## Why this shape

- **One intake contract for every detection source.** Bugs arrive three ways:
  a human report, a runtime error, or a runtime **invariant violation**. All
  three funnel into one structured GitHub issue (`.github/ISSUE_TEMPLATE/bug.yml`,
  `triage` label) so the agent always consumes the same shape. Required fields are
  the ones that make a bug *reproducible*: expected vs actual, affected entity
  (which `Quote` id), timestamp, and the **deployment id** (ties the bug to a
  Vercel deploy for rollback/skew correlation).
- **Reproduce-before-fix is non-negotiable.** The failing repro test is triage's
  contract, the way a grilled spec is `build-feature`'s (ADR-0002). The bug's
  acceptance criterion is "this no longer happens," so the red→green test *is* the
  acceptance test — no grilling needed, the red test is the unambiguous spec.
- **Invariants become production tripwires.** The same checks the gate enforces
  pre-ship (`total = Σ lines − discount`, forward-only state machine) are asserted
  at runtime in production; a violation auto-opens a `triage` issue with the entity
  and deployment id pre-filled. This catches silent corruption that never crashes
  and no user reports — the highest-value, most domain-specific detection we have.
- **Mitigate and fix are two tracks.** When a prod bug lands, the immediate move
  is **rollback** (Vercel one-click, see `operations.md`) — stop the bleeding in
  seconds. Triage works the root cause in parallel on a branch. Dealers don't wait
  for a green PR to stop seeing the bug.

## Autonomy boundary

The global instructions ask for *autonomous-to-the-gate, human-at-the-ship-
boundary, ceremony-scaled-by-risk* (ADR-0002: "minimal hand-holding," "how much
the AI carries," but `ship-change`: "never commit or push without an explicit
request"). Triage inherits that posture:

| Stage | Who | Rationale |
| --- | --- | --- |
| Detect → intake (issue) | **auto** | "observe & triage" is the agent's job |
| Reproduce → diagnose → fix | **auto** | "how much the AI carries" |
| Gate + domain-review | **auto** | "never ship a change that didn't pass your gate" |
| Commit / push / open PR | **human-triggered** | authorizing the triage run *is* the request |
| Merge / deploy | **human ack** | irreversible, outward-facing |

- **Auto-intake, never auto-merge.** An issue body is **untrusted external input**
  — anyone who can file an issue can write its text, so it is a prompt-injection
  surface. Triage *proposes* a PR; a human pulls the trigger.
- **Tier by blast radius.** A trivial, low-risk fix may flow nearly hands-off
  (auto-PR, and auto-merge once the gate is green). A fix touching a money or
  state-machine invariant always gets a human ack. The autonomy dial is set per
  bug by blast radius, not globally — ADR-0002's "trivial field skips the grill"
  applied to bugs.

## Consequences

- `triage-bug` shares the `ship-change` tail with `build-feature` (ADR-0002), so
  commit → PR logic lives in one place; it differs only at the front (a failing
  repro test instead of a grilled spec).
- New settings/triggers live in `operations.md`: the bug issue template + `triage`
  label, and the label-triggered Claude Code session.
- Deferred at current scale (single dealership, ADR-0003): an error-tracker
  (Sentry) auto-issue integration and a cron "on-call diagnostics" agent that
  sweeps logs proactively. Vercel runtime errors cover detection until traffic
  grows.
