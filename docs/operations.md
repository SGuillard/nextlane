# Operational hardening (deferred)

Safety controls that live in **GitHub / Vercel settings**, not in the repo, so
they can't be committed as code. They are recorded here so the guarantee is
captured and can be applied later. Nothing here is wired up yet — each item is a
to-do with the exact steps to do it.

Related decisions: the CI gate and verification loop (ADR-0002); stack, auth,
and deploy (ADR-0001).

## TODO

- [ ] Enable branch protection on `main` (GitHub) — see below.
- [ ] Confirm Vercel preview-per-PR + production-from-`main`-only — see below.

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

**Adopt now (free tier, high value):**

- **Preview deployment per PR.** Every PR gets its own live URL — review the real
  thing before merge, alongside the gate. Usually on by default; confirm under
  **Settings → Git**. This is the biggest single win.
- **Production deploys only from `main`.** Set the Production Branch to `main` so
  nothing reaches production without passing the PR + CI gate. Previews cover
  every other branch.
- **Instant rollback.** Vercel keeps prior production deployments; if something
  slips through, **Deployments → ⋯ → Promote/Rollback** reverts in one click. No
  setup needed — just know it's there.

**Defer (over-ceremony for this slice):**

- **Gradual / percentage-based Rollouts** (shift X% of production traffic to a new
  deployment, then ramp). This is a Vercel **Pro/Enterprise paid feature**. For a
  single-dealership (ADR-0003), free-tier slice it's more machinery than the risk
  warrants — exactly the kind of over-ceremony ADR-0002 cautions against. Revisit
  only if traffic and blast radius grow.
- **Skew protection** (pins client/server to the same deployment version during a
  rollout). Useful at scale; not needed for one dealership. Note for later.

**Net:** previews + production-from-`main` + one-click rollback give the safety
that matters here for ~zero cost; staged rollouts are a deliberate "not yet."
