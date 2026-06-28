# AI verification loop

The product is the rails that let an AI agent keep building and operating the
app, so the central decision is *how a change is specified, verified, and
shipped*. A feature flows: requirement → a spec doc (agent drafts it, the human
grills only the uncertain deltas) → implementation derived test-first from the
doc → a layered gate → a blocking self-review → `ship-change` opens the PR. We
also eval the rails themselves, not just the app.

## Why this shape

- **Spec-doc-driven, not ticket-driven.** The grilled spec doc is the contract
  the implementer consumes; its acceptance criteria map 1:1 to test names. The
  human-approval gate is the grilling, not eyeballing raw test files.
- **Adaptive front-end.** The agent tiers the ceremony by task size: a trivial
  field skips the grill, a risky change that touches an invariant gets the full
  treatment. Over-ceremony for small tasks would make the human the bottleneck
  and undercut "how much the AI carries."
- **Three-layer gate.** (1) deterministic CI — lint, typecheck, unit tests,
  build; (2) invariant/contract tests that hold for *any* feature
  (`total = Σ lines − discount`, forward-only state machine); (3) a domain-aware
  AI reviewer reading the diff against `CONTEXT.md` and the ADRs.
- **Review before ship, not after.** The brief asks how AI verifies its output
  *before* it ships. The AI review runs on the agent's own working-tree diff as
  a blocking step *before* the PR is opened, so a bad change is fixed before it
  is ever public. Layers 1+2 remain the hard merge blocker in CI. We rejected
  the post-PR review hook (a record, not a guard) to avoid running review twice.
- **Eval the rails.** A small, on-demand eval suite has two targets: a *builder*
  eval (golden day-2 specs run through the implementer agent, scored on whether
  they pass the gate) and a *reviewer* eval (labelled good/bad diffs scored on
  whether the AI reviewer catches them). It runs when a skill, agent, or
  `CLAUDE.md` changes — regression-testing the machinery — not on every PR,
  because it runs a full agent and is slow and non-deterministic.

## Consequences

- The unknown live task is safe without a pre-written spec: invariants, types,
  and the domain reviewer are all feature-agnostic, and the per-feature tests
  are written test-first from the just-in-time spec doc.
- Day-2 agents (`build-feature`, `triage-bug`) share the `ship-change` tail so
  commit → PR → review logic lives in one place.
- Interactive runs use a feature branch; the eval harness uses git worktrees for
  parallel, clean-state runs.
- The CI gate is enforced server-side by branch protection on `main` (a hard
  guarantee beyond the client-side `block-commit-on-main` hook) — recorded as a
  deferred to-do in [operations.md](../operations.md).
