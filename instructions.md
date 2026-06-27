# Nextlane · Staff AI Engineer Case Study

**Case Study · Staff / Principal AI Engineer**

## The brief

# Build the rails, not just the app.

Ship a small slice of a Dealer Management System, then show us the AI-engineering system you built around it: the rails that let an AI agent keep extending and operating the product after day one.

| Format | Time | Stack | Auth | Deploy |
| --- | --- | --- | --- | --- |
| Take-home | 1–2 days | Any you like | Basic, required | Free-tier host |

## What you build

### A thin DMS slice: your choice of module

Pick one module of a Dealer Management System and build a small, working version of it.

You choose the slice: vehicle inventory, a sales deal / quote, service & workshop scheduling, customer CRM, or another module you can argue is DMS-relevant. **Keep the app deliberately small.** Scoping it well is part of what we evaluate; we are not looking for a complete DMS.

> **The app is a gate, not the score.** It needs to run, ship with basic auth, and be deployed to a free-tier host (Vercel, Supabase, Cloudflare Workers, Netlify, Render: your call). Beyond that, the app itself is the *smaller* part of this challenge.

The part we weigh most heavily is everything *around* the app, the AI-engineering machinery that lets a model keep building and operating it after you ship. That's the next section.

## What we grade

### Four artifacts, committed in the repo

These live in your repository and are the primary objects of evaluation. We want evidence you got *more* out of the models than a naive user would.

**01 · Agent config & rules**
How you steer the model and encode project knowledge: conventions, domain context, and guardrails the agent must respect.
Files: `CLAUDE.md`, `.cursorrules`, `AGENTS.md`

**02 · Reusable skills & subagents**
Leverage, not one-off prompts. Authored skills, slash-commands, or subagents, e.g. a "scaffold-new-module" generator or a domain-aware code reviewer.
Files: `/skills`, `/commands`, `subagents`

**03 · Day-2 agents**
Agents that keep building the product *after* ship. Above all, implementing new features end to end (a new module, field, or workflow), plus bug-report triage, migration generation, on-call diagnostics, and dependency upgrades.
Files: `build-feature`, `triage`, `migrate`

**04 · Eval & verification loop**
How AI verifies its own output before it ships: a test harness, an AI review gate, an eval suite for generated changes, a CI hook. The path that lets AI iterate *safely*.
Files: `tests`, `eval`, `CI gate`

## The point of the exercise

### The loop your rails should enable

Once the MVP ships, an AI agent should be able to run this loop with minimal hand-holding, and never ship a change that didn't pass your gate.

```
        Ship to dealers
              │
              ▼
   Verify & gate ◄──── AI RAILS ────► Observe & triage
              ▲     (rules · skills        │
              │      day-2 agents · evals) │
              └──── AI proposes change ◄───┘
```

- **Observe & triage**: your day-2 agents
- **Build & propose**: agents ship features, skills do the work
- **Verify & gate**: your eval loop blocks bad changes

## How we score it

### What the points are for

Weighted toward AI leverage and whether it actually works under live conditions.

| Dimension | Weight | Detail |
| --- | --- | --- |
| AI leverage & artifact quality | **45%** | Quality, reusability and thoughtfulness of the four artifacts above. |
| Day-2 extensibility, proven live | **25%** | Does your scaffolding deliver when we hand you a fresh task? Speed, safety, how much the AI carries. |
| Engineering judgment & delivery | **20%** | Scoping, architecture, tests, basic auth, CI, and the deployed app. (DevOps / cloud fit lives here.) |
| Communication & technical leadership | **10%** | Can you teach your approach clearly? Staff-level mentoring signal. |

The DMS app's correctness is a **pass/fail gate**, not a scored dimension: it must run, deploy, and let us log in. Spend your remaining energy on the rails.

## What happens

### From take-home to live extension

Four steps. The last one is where your rails earn their keep.

1. **Build** — 1–2 days
2. **Submit** — repo + live URL
3. **Present** — any format
4. **Extend live** — a fresh task, from us

> **The live session — You'll extend your own product, live**
>
> At the presentation you'll demo the app, walk us through your agent setup and skills, and run one day-2 task you prepared. Then **we'll hand you a fresh, previously-unseen task** and watch you implement it using your own scaffolding. There's nothing to prepare for it. That's the point. If your rails are good, this is the easy part.

## Before the session

### What to submit

> **Send it back to us 1–2 days before your case study presentation.** That gives the panel time to review your repo, run the app, and prepare the live extension task.

- **A repository** with full commit history. Showing how the model and you worked together is welcome. Attribute AI commits if you like.
- **A live deployed URL** on a free-tier host, with working basic auth.
- **The four artifacts** committed in the repo: rules, reusable skills/subagents, day-2 agents, and your eval/verification loop.
- **A short README** pointing us to each of the above and explaining how to run the day-2 agents yourself.

Bring your own laptop and tooling to the live session. You'll be driving.

---

*Staff / Principal AI Engineer · Case Study · Confidential*
