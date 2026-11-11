## Working habits

- Reproduce a bug end to end before changing code, so the fix targets the real cause.
- Weigh quality, simplicity, robustness, scalability and long-term maintainability over development cost.
- Do not over-weight the existing implementation; aim for the simplest, cleanest long-term solution.
- When testing end to end, be picky about the UI and hold it to pixel-level polish.
  Hold lint, failing tests and flakiness to the same bar.
  Fix what is small and in the area you are touching; list the rest in your reply.
- Follow YAGNI principles.
- Put each full sentence on its own line in long markdown.
- Never add an agent co-author line to a commit.

## Libraries and evidence

- Prefer mature products and components over custom solutions.
  Before writing custom code, survey the established options, including engines from other ecosystems with official ports, and weigh licensing and maintenance cost.
  Custom code that survives that check is small, justified in writing (what it is for, and why no library covers it), and frozen by a test that proves it.

## How work is organised

- Work is planned on Lavish pages, with depth matched to the task.
  Small, clear work just gets done; state any assumptions in the reply.
  Anything with open decisions gets a page that states the problem, each decision with a recommended default, and the plan.
  Review your own plan adversarially and spike risky assumptions before building.
  If you hit a gap the plan did not anticipate, stop and raise it instead of patching around it.
- Every Lavish page layers conceptually: the problem and who it is for, the core idea and its words, the core mechanisms, the general architecture and stack, each part in depth, risks and alternatives, decisions, the plan, the log.
  Each section uses only concepts introduced before it; push detail down to its layer and leave a short summary above.
  `inbox/treadmill/treadmill.html` is the model.
- Project work, and the Lavish pages that plan or explain it, live in Treadmill, not in the inbox or inside a project repo.
  A page that drives work is a task, written with the `treadmill-prep` skill; a page that drives no task (a plan, a glossary, a finding) is a note beside the project's tasks, added with `treadmill note <project> <file>`.
- The inbox, `~/github/gallopify-playground/inbox/`, is only for one-off work that belongs to no Treadmill project.
  The inbox is its own private repo, `revvu/agent-inbox`, checked out at that path on every machine.
  Its `README.md` lists each page with its next step; keep that table current.
  Work sessions start by pulling and opening the inbox; commit and push after each page change, so the other machine can resume.
  Several agents often work in the inbox at once, each on its own page; that is normal, not a conflict.
  Pull and push freely and expect other agents' commits to land between yours: no two agents touch the same file, so there is nothing to race on.
  The server pushes a weekly drift audit into the inbox, `drift/drift-<date>.html`, every Sunday night; a session that finds the newest drift row older than eight days says so.
  The audit only reports: the axi tools, no-mistakes, treehouse, cursor-agent and the casks are updated by hand, when its page says a release is out; Paper has no feed, its row shows the installed version per machine, and a gap between the two machines closes with a relaunch from the app.
- Each project has a scaffold repo (for example `atomic-skills`, `linear-skills`) that holds the skills and scripts agents use in that context.
  When an inbox page's work is done, remove its inbox row.
- A workspace `CLAUDE.md` routes to the scaffolds.
  Start project work from the scaffold directory so its rules and skills load.

## Reader files

Reevu's portrait is `reevu.md` beside this file: who he is, for anyone writing something he will read.
Read it before writing to him.
Change it only with Reevu; a line stays only if it changes what a writer does.

@~/.claude/reevu.md

- What he knows of a project is in the nearest `reevu.md` above the work: a scaffold's root, or an inbox page's folder.
  A scaffold's `CLAUDE.md` imports it with `@reevu.md`.
  Read it before writing to him.
  Its top is the big picture of the project; each group of tasks he has named gets its own section below.
  Whatever your message rests on that is not in it goes in the working; if the code changed since a line's commit, show what changed.
  Below a group nothing is written: what he tells you on one task stays in that conversation.
- A line enters a project `reevu.md` only when Reevu teaches it back: he explains it, in conversation or in something he wrote, and an agent checks it against the code and sources.
  An idea he originated counts as taught, including what he decided when he first described a project.
  Approvals, picked defaults and pages he was shown never enter; the code holds those.
  A claim the code contradicts becomes one question, not a line; there is no score.
  Lines compress what he understands, not how he said it: one idea per line, short but specific, with the date, how it entered, and the commit it was checked against.
  Split a line that holds two ideas.
  The compression comes after the check: his full answer and each claim's check go in the teach-back PR's description, so `git blame` on a line leads back to them.
- Reevu names groups of tasks inside a project, up front or in hindsight.
  Teach-backs, in any project, follow Treadmill's teach-back skill, `treadmill/skills/teach-back/SKILL.md` in the workspace: read it for when to ask and how to run one.

## Lavish skins

Every project has a Lavish skin: the nearest `.lavish-shared/lavish-skin.css` above the artifact's directory, a DaisyUI 5 theme on the Tailwind v4 browser + DaisyUI CDN runtime.
Use it, and offer to create one where a project has none.

## Lavish page standard

A reader who sees only the top of a page knows what is being solved and what it needs, without opening anything else.
- The page opens with a headline that states the situation, then a picture of the problem: a diagram, wireframe or animated flow showing where it breaks, what is missing and who holds each piece.
- Under the picture comes one plain paragraph that starts with "Problem:", at most three sentences: what we are solving, what done looks like, and what it needs (people, access, decisions). No label-and-value table.
- Keep it light: under 120 words above the fold, every section opens with a visual that the text only labels, and headings state conclusions, not topics.
- Choose the body visuals by page type: a step track for builds and trackers, a diagram for systems and bugs, decision cards with a recommended default for anything waiting on the user.
- History, logs, evidence and unverified items go in collapsed sections or a linked page.
- Use motion freely wherever it explains something (work flowing, state changing, progress filling), and always honour reduced motion.
- The reference examples are `inbox/lavish/page-styles.html` (the options tried) and `inbox/firstmate/firstmate-resync.html` (the standard applied).
- End every Lavish page with the `lavish-page` skill's review: a fresh agent playing Reevu lists what stops him acting, a fact judge checks the claims the page rests on, and the writer answers each item from evidence or marks it unknown.
  This covers every Lavish file, prepped tasks included.

## UI design

Paper is the source of truth for every screen: design in Paper first, then change the product to match it.
Never edit a Paper board to match what was built; a gap between the two is a product bug.
Feedback on a live screen goes into Paper first, then into the product.
Each board is an option (being explored), ready (approved, not yet built) or live (exactly what production shows); never edit a live board in place.
Build from Paper's exact values (tokens, get_jsx, get_computed_styles), never from screenshots, and a screen is done only when its build, diffed against its board, shows no difference that data, live content or rendering noise does not explain.
A screen built before its board enters Paper once, through the project's import tool, and follows these rules from then on.
Claude makes Paper edits on the Fable model; each project's Paper scaffold names its files, states and tools.

## no-mistakes

Run no-mistakes on substantial PRs only: new features, behaviour changes, non-trivial refactors.
Docs, generated artifacts, config tweaks and small mechanical edits ship without a run; adversarial review of a simple change invents defensive patches that cost more than the risk.
Run it with the other vendor: Claude runs it with Codex, and vice versa.
Initialise an unconfigured repo with `no-mistakes init`.
The no-mistakes skill covers driving a run.
