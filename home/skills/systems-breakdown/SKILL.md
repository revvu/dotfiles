---
name: systems-breakdown
description: Turn big-picture exploratory work on a new project or area into a mechanism-by-mechanism breakdown, a Lavish note where each system gets its flow diagram, the one rule it keeps, its status argued from evidence, what we must build and how others solved it, backed by one cited source file in the project's scaffold. Use when investigating a new project, integration or environment, or when Reevu asks how X works end to end, what must be engineered, or for "a mechanism by mechanism breakdown".
---

# systems-breakdown

The page answers one question per system: what does this take end to end, and what must we engineer to get there.
It is a Lavish page, so `lavish-page` governs the reader, the working, the layering and the review; this skill is only the method that fills it.
The two reference notes in `revvu/treadmill-tasks` are `notes/schwab/schwab-systems.html` (a greenfield integration) and `notes/gallopify/staging-systems.html` (an existing system audited); read both before writing.

## 1. Gather the sources into one file

- Pull every scattered source (guides, digests, emails, chats, vendor docs, the code) into one source file in the project's scaffold, such as `<scaffold>/<area>.md`, through a PR.
- Each line carries its primary source: a document and page, an email, a URL, a file and line at a commit.
  A doc saying something is a claim; the code, data or the counterparty's own document is the source.
- Number what no source answers as an ask list (O1, O2, ...), each with who can answer it, and number the places sources disagree (C1, C2, ...).
- The same PR removes the scattered files it replaces, once each of their facts has moved in.
- The page cites the file's sections (`[§3.4]`) instead of restating its evidence.
- An audit of an existing system may need no file: the code at a named commit and read-only commands are the sources, listed in the log.

## 2. Find the core idea

- Name the one equation or loop every system runs, such as "intent, act, evidence, match" or "an environment is a commit plus settings plus data".
- Ground it in how others solved it (a prior project's note, an established practice, a vendor's model), cited, and say what differs here and why.
- Derive a few rules from it (R1, R2, ...) that every system keeps in its own terms.
  Few and composable: a rule that only one symptom needs belongs to that system, not here.
- Define the words the rest of the page uses, once.

## 3. Split into systems, and argue the split

- A system is a mechanism with its own job, its own flow and its own rule; aim for roughly five to twelve.
- Say why each split was made: what was merged because it is one mechanism, what was separated because it has its own data or owner.
- A concern with no flow of its own is not a system: show which systems already keep it, in one table.
- Draw the map: every system on one diagram or table, grouped, with where it runs and who holds it (the architecture layer), and the gap marked.

## 4. Write each system

Every system section has the same parts, in this order:

- **Headline**: the conclusion about this system, not its name.
- **Job**: one line.
- **Flow**: a diagram of the steps end to end, each step naming who acts (us, the counterparty, a person, a schedule); an unknown step is drawn with "?", not guessed.
  A sources line under it cites where each step came from.
- **Rule**: the one invariant this system keeps, stated so a check could prove it, tied back to the core rules.
- **Status**, when anything exists already: whole (the rule holds and a check proves it), partial (parts built, rule unproven), missing (no mechanism), broken (built and failing).
  Argue each with evidence: a file and line, a run, a commit, a count; a tile with no argument is a fill.
- **We build / it provides**: what we must engineer, then what the counterparty or platform already gives; in an audit, what is engineered and what is missing.
- **Others**: how others solved this mechanism, named and cited, and whether we follow them.
- **Done when**: the check that would prove the rule holds.
- **Open**: the numbered asks this system waits on, with what each answer would change.

## 5. Close the page

- Risks: a table of each risk and what guards it; alternatives weighed, collapsed, each with why not.
- Decisions as cards, each marked by owner: yours (only he can answer), agent default (taken unless he objects), applied (an earlier call of his, with its date), or routed (another owner, named).
- The plan: each step cut from a named system, with its owner and its done-when, ready to become Treadmill tasks with `treadmill-prep`.
- Needs you, at the top under the Problem paragraph: only what he alone holds, each with candidates, what it changes and a default where one exists; routed and settled items say so in one line and are not asks.
- Log, collapsed: what was not verified, the sources read, and the Reader review log.

## 6. Review and file

Run `lavish-page` step 5 on the finished page, then file it as a note beside the project's tasks with `treadmill note <project> <file>`, with the source file's PR on its Related line.
