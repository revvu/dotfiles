---
name: systems-breakdown
description: Turn big-picture exploratory work on a new project or area into a mechanism-by-mechanism breakdown, a Lavish note whose clickable map opens each system's flow, the rule it keeps, its status argued from evidence, what we must build and how others solved it, backed by one cited source file in the project's scaffold. Use when investigating a new project, integration or environment, or when Reevu asks how X works end to end, what must be engineered, or for "a mechanism by mechanism breakdown".
---

# systems-breakdown

The page answers one question per system: what does this take end to end, and what must we engineer to get there.
It is a Lavish page, so `lavish-page` governs the reader, the working, the layering and the review; this skill is only the method that fills it.
The reference notes in `revvu/treadmill-tasks` are `notes/schwab/schwab-map-atlas.html` (the map-and-panel form this skill describes), `notes/schwab/schwab-systems.html` (the greenfield integration it was built from) and `notes/gallopify/staging-systems.html` (an existing system audited); read them before writing.

## 1. Gather the sources into one file

- Pull every scattered source (guides, digests, emails, chats, vendor docs, the code) into one source file in the project's scaffold, such as `<scaffold>/<area>.md`, through a PR.
- Each line carries its primary source: a document and page, an email, a URL, a file and line at a commit.
  A doc saying something is a claim; the code, data or the counterparty's own document is the source.
- Number what no source answers as an ask list (O1, O2, ...), each with who can answer it, and number the places sources disagree (C1, C2, ...).
- The same PR removes the scattered files it replaces, once each of their facts has moved in.
- The page cites the file's sections (`[§3.4]`) instead of restating its evidence, inside each system's sources fold; the codes (O, C, R) stay in the file and the folds, and the visible page names the thing.
- An audit of an existing system may need no file: the code at a named commit and read-only commands are the sources, listed in the log.

## 2. Find the core idea

- Name the one equation or loop every system runs, such as "intent, act, evidence, match" or "an environment is a commit plus settings plus data".
- Ground it in how others solved it (a prior project's note, an established practice, a vendor's model), cited, and say what differs here and why.
- Derive a few rules from it (R1, R2, ...) that every system keeps in its own terms.
  Few and composable: a rule that only one symptom needs belongs to that system, not here.
- Define the words the rest of the page uses, once, in the reader's vocabulary; every coined term is a cost he pays on each use.

## 3. Split into systems, and argue the split

- A system is a mechanism with its own job, its own flow and its own rule; aim for roughly five to twelve.
- Say why each split was made: what was merged because it is one mechanism, what was separated because it has its own data or owner.
- A concern with no flow of its own is not a system: show which systems already keep it, in one table.
- Draw the map: every system on one diagram, grouped by stage of the journey, each tile its business name, who acts and a status, with cross-cutting systems in a strip beside the journey.
  The map is the page's overview (`lavish-page` step 3): it takes the full width, and a tile opens that system's panel under the map, one panel at a time, with a Close; on a phone the panel opens under the tapped tile.
  No tabs, and nothing that leaves the page or changes its address: which panel is open is in-page state.

## 4. Write each system

Each system is a panel opened from its tile, not a section of the scroll.
Every panel has the same parts, in this order; the first five are visible when it opens, the rest fold inside it:

- **Title**: the system's business name, with its status.
- **Job**: one line.
- **Flow**: a short chain of the steps end to end, each step naming who acts (us, the counterparty, a person, a schedule); an unknown step is drawn with "?", not guessed.
- **Status**, when anything exists already: built (the rule holds and a check proves it), partly built (parts built, rule unproven), not started (no mechanism), broken (built and failing).
  Argue each with evidence in a line or two: what exists today, and what blocks it.
- **Business needs | what we build**, side by side: what the business needs from this system, and what we must engineer (in an audit, what is engineered and what is missing).
- Folded: **Open** (the asks this system waits on, by name, with what each answer would change), **Done when** (the check that would prove the rule holds, and how we test it), and **Engineering and sources**: the rule this system keeps, stated so a check could prove it and tied to the core rules; how others solved it, cited; what the counterparty already provides; and where each flow step came from.

## 5. Close the page

- Risks: a table of each risk and what guards it; alternatives weighed, collapsed, each with why not.
- Decisions as cards, each marked by owner: yours (only he can answer), agent default (taken unless he objects), applied (an earlier call of his, with its date), or routed (another owner, named).
- The plan: each step cut from a named system, with its owner and its done-when, ready to become Treadmill tasks with `treadmill-prep`.
- Needs you, at the top under the bottom line, grouped by the person who holds each item: only what he alone holds, each with candidates, what it changes and a default where one exists; routed and settled items say so in one line and are not asks.
- Log, collapsed: what was not verified, the sources read, and the Reader review log.

## 6. Review and file

Run `lavish-page` step 5 on the finished page, then file it as a note beside the project's tasks with `treadmill note <project> <file>`, with the source file's PR on its Related line.
