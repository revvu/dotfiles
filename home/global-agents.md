## General Guidelines

- When writing commit messages, never auto-add your agent name as co-author.
- When doing bug fixes, always start by reproducing the bug in an E2E setting.
  This makes sure you find the real problem so your fix will actually solve it. 
- When making technical decisions, do not give any weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long-term maintainability.
- Do not over weight existing implementations. We're always aiming for the simplest, cleanest, long-term solutions. 
- When writing or substantially editing long markdown files, put each full sentence on its own line.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed alongside your work.
- Apply the same high standard of engineering excellence: lint, test failures and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed. 

- Avoid custom solutions when there are mature products and components that already exist. Prefer leveraging what's proven to work well.
- When integrating with an external service, pin specs to observed behavior, not documentation.
  SDK types and vendor docs describe what is possible across all configurations; only a live capture (network response, real API call) shows what your instance actually returns.
  Never let a documented target state override a primary observation you already have.
- Any code path that cannot be exercised before production (feature flags, instance-specific behavior, third-party steps) must be listed in the spec as UNVERIFIED, with a mandatory live verification step immediately after deploy.
  "Verified against types" or "covered by mocks" never upgrades an unverified path.
- A diagnosis may only be closed with positive evidence.
  "Most likely X" without a captured error, log line, or reproduction stays open as undetermined — and missing observability is itself the first finding to fix.

## Lavish skins

Every project has its own Lavish skin so its artifacts are on-brand and easy to tell apart at a glance.
Before authoring any Lavish artifact, walk up from the artifact's project directory and use the nearest `.lavish-shared/lavish-skin.css`.
Set `<html lang="en" data-theme="<name>">` using the `theme-name:` declared in the skin's header comment, and inline the entire skin file into the artifact's `<style>` block — inline, never `<link>`, so the artifact stays portable when opened or exported outside Lavish.
Skins are DaisyUI 5 custom themes, so keep using the standard Tailwind v4 browser + DaisyUI CDN runtime for structure and components.
Never invent brand colors inside an individual artifact — if the brand needs adjusting, change the skin file, deriving from the token source of truth named in its header.
When starting artifact work in a project that has no skin yet, offer to create one: derive it from the project's real design system if it has one, otherwise design a distinctive theme and record the rationale in the skin's header.

## Linear

All Linear work — creating, editing, or commenting on issues — runs from `~/github/gallopify_playground/linear`.
Start Linear tasks from that directory so its style rules (CLAUDE.md) and skills (style-check, new-issue, sync-issue, groundwork, and the rest) are loaded; do not push text to Linear from anywhere else.

## Model routing (Explore vs Execute)

Standing matrix (Fable for judgment/design, Codex for frontier implement/review, Cursor for speed implement) lives in firstmate when you are in a firstmate home: `docs/routing-policy.md`, `config/crew-dispatch.json`, `/plan-to-fleet`.

**Crew-dispatch is not ambient magic.**
It only chooses harnesses when First Mate spawns crewmates.
A normal Claude (or Codex) chat does **not** automatically hand Lavish/Paper edits to Cursor unless you follow the Explore rules below.

### Explore (single chat, decisions still open)

Stay on the current strong model (prefer Fable when available) for:

- clarifying questions and framing
- architecture and product judgment
- critiquing Lavish/Paper and deciding which variant wins
- taste and layout calls

Delegate to **Cursor** for mechanical speed work so Claude quota stays on judgment:

- generating several rough Lavish or Paper variants to compare
- applying an already-decided bulk edit to Lavish HTML
- other fast, low-ambiguity artifact edits where quality-good-enough beats frontier reasoning

How to delegate:

1. Keep this conversation as the judgment surface.
2. Run Cursor non-interactively against the artifact workspace, for example:
   `agent --yolo --trust --workspace <dir> -p "<precise edit brief>"`
   (`cursor-agent` is fine if that is the binary on PATH.)
3. Re-read the artifact here, then continue questioning or converging.

Do **not** delegate:

- tiny one-line fixes cheaper to do inline
- pure discussion turns with no file edit
- final taste/layout convergence (stay on Fable)
- when the human explicitly wants you to edit

When intent locks and work should parallelize, switch to First Mate Execute (`/plan-to-fleet`) instead of improvising an ad-hoc Cursor fleet from this chat.

### Execute (First Mate fleet)

Use crew-dispatch and quota-axi for harness choice.
When spawning Claude, prefer multi-account selection via `config/claude-cswap-auto` and `bin/fm-cswap-pick.sh` (see firstmate `docs/multi-account-quota.md`).

## For Complex Tasks


### Plan-Implementation Split

Before implementing any task, work with the user to construct task-specific "___ plan.md" and "___ implementation.md" files.
Write the plan file first: it describes 1) the problem statement and 2) what a globally optimal solution looks like. Importantly, this optimal solution should be constructed as a state machine.
There must have no references to the codebase within the plan. For any given task, planning and implementation are strictly segregated.

The implementation file concretely bridges the transition from the current implementation to the optimal solution.

Construct both files over several passes with the user.
First, research the problem and propose a simple solution. Then the "refinement loop" begins:

1) Present all open decisions to the user.
2) Incorporate the responses, then perform an adversarial review for simplifications, assumptions, and gaps.
3) Spike any assumptions.
4) Back to 1.

Continue the loop until no gaps, simplifications, decisions, or unvetted assumptions remain.

The goal: two high-signal, thorough documents.
A newly-instantiated, context-free agent should be able to implement the entire optimal solution from only these two docs.
If that agent hits an unanticipated problem, error, or gap, stop implementation and resume the refinement loop.


### no-mistakes pipeline

Run no-mistakes on every non-markdown-only PR you produce — the pre-share correctness gate (nine serial steps, each a fresh agent; GitHub branch protection is the separate merge gate).
It is expensive but agent-agnostic: if you are Claude run it with Codex, and vice versa; initialize an unconfigured repo with `no-mistakes init`.

Start a branch's first run with `git push no-mistakes <branch>` (the only way to start a never-pushed branch), then drive every gate with `no-mistakes axi respond` from a checkout on the run's branch.
The `axi` call blocks until the next gate, `checks-passed`, or `outcome:` — that blocking call is your only monitor, so keep it running, act on what it prints, and loop respond-on-gate until it ends; never leave it unattended or poll `axi status` in its place.
Fix findings you can judge (`--action fix --findings <ids>`) and escalate `ask-user` findings to the human.
Treat `outcome: checks-passed` as done: report the PR link and hand the merge to the human — never wait or poll for the merge.

A launchd babysitter (`com.gallopify.no-mistakes-babysitter`) is the session-independent backstop for a run nobody is actively driving; never disable it, and read `~/.no-mistakes/logs/babysitter.log` when you suspect a run is stuck.
It self-heals a hung ci-fix agent (the run retries automatically) and flags the two cases that need you: a stuck non-ci step — recover with `no-mistakes axi abort` then rerun — and a parked gate, meaning a run is awaiting a `respond` nobody gave, so pick it up and drive it.

After the task is completed and the code, its plan and implementation files should be saved as an artifact to a docs/ folder for future reference.
