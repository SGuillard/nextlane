# Operational hardening (deferred)

Safety controls that live in **GitHub / Vercel settings**, not in the repo, so
they can't be committed as code. They are recorded here so the guarantee is
captured and can be applied later. Nothing here is wired up yet — each item is a
to-do with the exact steps to do it.

Related decisions: the CI gate and verification loop (ADR-0002); stack, auth,
and deploy (ADR-0001); production bug triage (ADR-0004); heterogeneous advisory
PR review (ADR-0005).

## TODO

- [ ] Enable branch protection on `main` (GitHub) — see below.
- [ ] Confirm Vercel preview-per-PR + production-from-`main`-only — see below.
- [ ] Turn on Vercel **skew protection** (Pro) — see below.
- [ ] Set up a **manual-approval canary** rolling release (Pro) — see below.
- [ ] Add the **heterogeneous AI review** as a required status check — see below.
- [ ] Wire **bug-triage intake**: bug issue template + `triage` label + trigger — see below.

---

## 1. Branch protection on `main` (GitHub)

**Why.** The `block-commit-on-main` hook (`.claude/hooks/block-commit-on-main.sh`,
wired in `.claude/settings.json`) is **client-side**: it only fires inside a
Claude Code session in this checkout. It does nothing against a plain `git push`,
edits in the GitHub web UI, another machine, or any tool that doesn't read
`.claude/settings.json`. Branch protection is **server-side** and enforced for
everyone and everything, so the two are complementary layers — the hook is a
fast in-loop nudge, branch protection is the hard guarantee.

| | `block-commit-on-main` hook | Branch protection |
| --- | --- | --- |
| Where | Local, in-session | Server-side (GitHub) |
| Catches | Claude committing to `main` | *All* pushes to `main` |
| Bypassable by | `git` directly, web UI, other tools | Repo admins only |

**Rules to set on `main`:**

- Require a pull request before merging (blocks direct pushes — the core rule).
- Require status checks to pass → select the **`verify`** job from
  `.github/workflows/ci.yml`. This makes the CI gate the literal merge condition.
- Require branches to be up to date before merging.
- Block force-pushes and deletions on `main`.
- **Required approvals: 0.** This is a solo repo — requiring an approval would
  just block the only author (you can't approve your own PR). The `verify` check
  plus the `domain-review` self-check are the gate; keeping approvals at 0
  preserves "how much the AI carries" (ADR-0002).

**Apply it (run later, needs GitHub access):**

```bash
gh api -X PUT repos/sguillard/nextlane/branches/main/protection \
  -F required_status_checks.strict=true \
  -F 'required_status_checks.contexts[]=verify' \
  -F enforce_admins=true \
  -F required_pull_request_reviews.required_approving_review_count=0 \
  -F restrictions=null
```

Or via the UI: **Settings → Branches → Add branch ruleset** for `main` with the
rules above.

---

## 2. Vercel rollout safety

**Why.** Deployment is the last gap after the CI gate. The goal is to never put a
bad change in front of dealers, and to recover in seconds if one slips through.

> **Plan note.** This project is on the Vercel **Pro** plan, so rolling releases
> and skew protection are both available (rolling releases are plan-gated —
> lower tiers return `plan_not_supported` — but Pro is supported). The earlier
> "defer because it's paid" reasoning does not apply here; the question is value
> vs. complexity, not cost.

**Adopt now (high value, low cost):**

- **Preview deployment per PR.** Every PR gets its own live URL — review the real
  thing before merge, alongside the gate. Usually on by default; confirm under
  **Settings → Git**. This is the biggest single win.
- **Production deploys only from `main`.** Set the Production Branch to `main` so
  nothing reaches production without passing the PR + CI gate. Previews cover
  every other branch.
- **Instant rollback.** Vercel keeps prior production deployments; if something
  slips through, **Deployments → ⋯ → Promote/Rollback** reverts in one click. No
  setup needed — just know it's there.
- **Skew protection (Pro).** Pins a client session to the deployment version it
  loaded, so a dealer with an old tab open during a deploy doesn't hit
  version-skew errors. One toggle (**Settings → Advanced**, or the framework
  adapter, e.g. `skewProtection: true`); a real correctness safeguard,
  independent of traffic volume. No reason to defer it now that we're on Pro.
- **Manual-approval canary (rolling release, Pro).** Deploy to production as a
  canary, smoke-check it, then approve to 100% — a gate between "built in prod"
  and "fully live" that pays off even at low traffic:

  ```bash
  vercel rolling-release configure --enable --advancement-type=manual-approval
  # deploy, then once verified:
  vercel rolling-release approve --dpl <deployment-url> --currentStageIndex 0
  vercel rolling-release complete --dpl <deployment-url>
  ```

**Defer (available on Pro, but low value at current scale):**

- **Automatic percentage ramps** (e.g. `--stage 10,5m --stage 50,10m`). Gradual
  ramps earn their value by *sampling real traffic* before going wide; a single
  dealership (ADR-0003) has too little traffic for a 10% canary to be a
  meaningful sample, so automatic ramps add machinery without much signal here.
  Keep the manual-approval canary above; switch to automatic ramps if traffic
  and blast radius grow.

**Net:** on Pro, the safety that matters here is previews + production-from-`main`
+ one-click rollback + **skew protection** + a **manual-approval canary**.
Automatic percentage ramps are a deliberate "not yet" — gated by traffic, not by
cost.

---

## 3. Heterogeneous AI review as a required check (GitHub)

Decision and rationale: ADR-0005. A second AI reviewer from a **different model
family** posts severity-tagged findings (`error` / `warn` / `info`) on every PR.
The findings are **advisory** (they inform the human's merge click, they do not
auto-veto), but **merge is blocked until the review has run and posted**.

**How it gates.** The review is a CI job that posts a PR review, then exits `0`
whenever it *completed*, and non-zero only if it **failed to run**. Add that job
as a **required status check** so merge is blocked until the review exists — the
guard is "a fresh-eyes review happened," not "the review approved."

**To wire it (run later, needs GitHub access + a second-model API key):**

- Add the review job to `.github/workflows/` (calls a different-family model;
  reads the PR diff; posts findings via the PR review API; exits `0` on completion,
  non-zero only on infra/API failure). Store the API key as a repo secret.
- Add its check name to branch protection's required checks, next to `verify`:

  ```bash
  gh api -X PATCH repos/sguillard/nextlane/branches/main/protection/required_status_checks \
    -F 'contexts[]=verify' \
    -F 'contexts[]=ai-review'
  ```

- The lowest-friction starting point is **GitHub Copilot code review**
  (`request_copilot_review`) — a different model, native integration, no key to
  manage — promoted to a required check.

**Knobs (per ADR-0005):** keep it **advisory** for now (an `error` finding does
not block merge — a human can override with eyes open). A future hard-stop is a
one-line flip: make the job exit non-zero on `error`. Tier it to
invariant-touching changes and hotfixes; trivial fixes skip it.

---

## 4. Bug-triage intake (GitHub)

Decision and rationale: ADR-0004. Production bugs funnel into one structured
GitHub issue, which triggers a `triage-bug` run.

**To wire it (run later, needs GitHub access):**

- Add `.github/ISSUE_TEMPLATE/bug.yml` with the reproducibility fields: expected
  vs actual, affected entity (`Quote` id), timestamp, **deployment id**, and
  logs/stack trace. This is the intake contract the triage agent consumes.
- Add a `triage` label; a bug issue carrying it kicks a Claude Code session that
  runs the triage flow.
- **Runtime tripwires (app code, not a setting):** assert the domain invariants
  (`total = Σ lines − discount`, forward-only state machine) at runtime in
  production; on violation, auto-open a `triage` issue with the entity and
  deployment id pre-filled. This is the highest-value detection source — it
  catches silent corruption no user reports.
- **Boundary (ADR-0004):** auto-intake, **never auto-merge** — an issue body is
  untrusted input, so triage proposes a PR and a human acks the merge.

**Deferred at current scale (ADR-0003):** Sentry auto-issue integration and a
cron "on-call diagnostics" log sweep. Vercel runtime errors cover detection until
traffic grows.
