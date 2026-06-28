# Heterogeneous advisory PR review

A second AI reviewer from a **different model family** comments on every PR with
severity-tagged findings (`error` / `warn` / `info`). The findings are
**advisory** — they inform the human's merge decision, they do not auto-veto.
But merge is **blocked until the review has run and posted**: the required status
check gates on the review *existing*, not on its *verdict*.

This refines ADR-0002, which rejected a post-PR reviewer as "a record, not a
guard." Here it is **both** — the findings are a record, and the requirement that
the review exists is the guard.

## Why a second, different-family model

A model reviewing output from its own family shares **correlated blind spots**:
if Claude's training has a gap, Claude-reviewing-Claude won't catch it. A reviewer
from a different family (an OpenAI or Google model) fails differently, so it
catches what the first one structurally cannot. The value is the **diversity**,
not the specific version — treat the exact model as swappable.

This stacks with, rather than replaces, the existing review:

| Review | When | Model | Behavior |
| --- | --- | --- | --- |
| `domain-review` | **pre-PR**, working-tree | Claude (same family) | **blocking** on `error` — hard guard before the PR exists |
| This ADR | **post-PR** | different family | **advisory** findings, merge blocked until it posts |

Same-family gate hard-stops bad changes before they are public; the different-
family reviewer guarantees a fresh-eyes second opinion on every PR before a human
merges. Diversity where it adds most, redundancy nowhere.

## Why advisory, but gated on completion

- **Advisory verdict.** An `error` finding does **not** mechanically block the
  merge; a human can merge a PR the AI flagged, with eyes open. This is
  deliberate: the machine guarantees *a review happened*; the human owns *what to
  do about it*. A comment-only bot with no gate would be the pure "record, not a
  guard" ADR-0002 rejected — so we add the gate below.
- **Gated on completion.** Merge is blocked until the review **runs and posts**.
  No independent second opinion on the PR → no merge. The guard is "a fresh-eyes
  review exists," not "the review approved."
- **Mechanism.** The review is a CI job that posts a PR review with severity-
  tagged findings, then exits `0` whenever it *completed*; it exits non-zero only
  if it **failed to run** (infra/API error). That job is a required status check.
  Result: can't merge until the review ran, verdict left advisory.
- **Tier by blast radius.** Don't run a full second review on every typo
  (ADR-0002 anti-over-ceremony). Gate it on invariant-touching changes and
  production hotfixes; trivial fixes skip it.

## Consequences

- A future hard-stop is a one-line flip: make the job exit non-zero on `error`.
  Today it stays advisory by choice.
- The required-status-check wiring is a GitHub setting, recorded as a to-do in
  `operations.md` alongside branch protection (ADR-0002 enforcement).
- Adds a cross-vendor API dependency (a key for the second model) to CI; scoped to
  the review job only.
