---
name: lavish-page
description: Write any Lavish page or file the reader will read (a note, a decision page, a morning report, an analysis, a prepped task, a decision stage, an outcome page) so that, holding only the page and his reader files, he can act on it. Ends with the reader review, a fresh agent playing the reader and a fact judge run in parallel, whose answers go in the page's Reader review log. Use before writing or rewriting any Lavish file, in any project; publishing refuses a page without that log.
---

# lavish-page

A page is finished when the reader, holding only it and what he already understands, can act on it.
Those two inputs are fixed before you write a word: the page carries everything else.
The global policy's "Lavish page standard" and "Reader files" sections are the rules; this skill is how to apply them, in order.
It covers every new Lavish file or rewrite, whoever writes it; an appended log line or a tracker row is not a new page.

## 1. Load the reader

- Read his portrait, the reader file beside the global agent policy: who he is, how he reasons, what convinces him.
- Read the project's reader file, the nearest one above the work: its big picture, then the group section the page belongs to; name the group before writing.
- List the concepts the page will rest on that neither file holds.
  Each goes into the page, introduced before it is used, or the page stops short of it.
- What he holds is what those two files hold.
  The chat and the pages he was shown are names he may recognise, not concepts he understands: shown is not understood.
  A name coined in a scratch file, a subagent report or a task outcome is not even recognised; never use one bare.
- Interim, until Lucidity's values are built into a proper system: read Lucidity's reader file, `~/github/gallopify-playground/lucidity-skills/reevu.md`, and skim the notes in `treadmill-tasks/notes/lucidity/` for the values they list.
  The notes are the source; this list only points at them, so when they disagree, the notes win.
  Every page applies these:
  - An ask earns his attention only for what his input uniquely provides; anything another source holds goes there first (`what-needs-you`).
  - Working, not conclusions: "2 + 1 + 1 = 4?", never "4?" (`knowledge-problem`, `information-flow`).
  - Setting work aside should not leave him remembering that it is open; parked work keeps its place by itself (`what-needs-you`).
  - What starts collapsed and the order things come in are attention choices: his moves lead, finished work leaves by itself (`attention`).

## 2. Show the working

- He wants to be convinced, not told: give "2 + 1 + 1 = 4?", never "4?".
- A number is measured, with its source, or marked as an estimate.
  An unverified claim says so where it stands; a visible gap beats a plausible fill.
- Every decision is a card: the problem it settles, the options, a recommended default, and the reason in terms he already holds.
  A recommendation he cannot reason about is a failure of the page, not of the reader.
- If the code contradicts something in his reader file, say what changed and since which commit.

## 3. Layer it

A reader spends attention to find what he must understand or do; the page's job is to make that cheap (Pirolli and Card's information foraging).
He understands in concepts, not terms: a concept is an idea with a job, what it is, what it does and why it matters here.
The first four rules are about concepts: which ones the page uses, in what order, at what level, and what it leaves closed.
The last three are about layout.

1. **Bottom line first, and he knows what is going on before he is asked.**
   The first screen says what this is, where it stands and what it needs from whom, so a reader who stops there still acts rightly.
   In that order: what the thing is for comes before where it stands, and where it stands comes before any ask.
   A page that proposes work (a task, a plan, a bug, a decision) says it in one paragraph starting "Problem:", at most three sentences: what we are solving, what done looks like, what it needs.
   A page that reports on work (a map, a tracker, a report) leads with the verdict, then the asks grouped by who holds them.
   Every ask is ready to act on: a verb first, what it is part of, what it unblocks, and the wait or the default.
2. **A concept is introduced, by what it does, before it is used.**
   A concept counts as held only if his reader files hold it or the page introduced it above; what he was shown or told does not count.
   A handle from the writer's process (a step or PR number, a decision id, a check's result such as "0 differences") never carries the meaning: say the concept it stands for, and keep the handle beside it as a link.
   A heading, tile or link speaks in held concepts and says enough about what is behind it to decide whether to open it; a section with one answer is headed by the answer.
3. **Blackbox to the decision.**
   For each decision or act, show what the choice turns on: what each part takes and gives, the promise it keeps, what it costs.
   Close every inside that does not change the choice, and open a box only where its inside does; never close the thing the choice turns on.
   A system is drawn whole as boxes first, then followed part by part.
4. **One level of abstraction per layer, chosen for the decision.**
   Each section and each figure stays at one zoom level, the whole before its parts.
   Its units are the ones the decision is about (where membership lives, who can be locked out), not the ones the work was organised in (PRs, steps, tickets).
   Depth follows what he holds: a held concept gets a sentence, one whose reader-file line the code has since contradicted gets the change, an open one gets the full working.
5. **Overview first, detail on demand.**
   With nothing opened, the page shows the whole and every route into it.
   Visible is what most readers need to act or to choose what to open; one open away is what some need; what no reader needs is deleted, not folded.
   Nothing he must have to act is folded, and the reason for a recommendation stays beside it.
   No fact is more than two opens from the default view.
6. **One home per fact.**
   Argue it once, at the shallowest place whose reader needs it; everywhere else mentions it in one line that links there.
   A summary line above its detail is that mention, not a second telling.
7. **One shape per kind, one meaning per signal.**
   Items of the same kind have the same parts in the same order; a colour or chip means one thing on the whole page.
   Keep apart what he acts on, what he reads to understand, what he looks up and what he audits.

Sources, one line each:

- Information foraging: Pirolli and Card, "Information Foraging", Psychological Review, 1999.
- Bottom line first, situation before ask: the military BLUF convention; Minto's pyramid principle and its situation, complication, question, answer; Treadmill's information-economy page, `inbox/treadmill/treadmill-information-economy.html` (an ask arrives in one frame: what it is part of, what it unblocks).
- Concepts before use: Ausubel, 1968, "the most important single factor influencing learning is what the learner already knows"; Lucidity's `learning-in-treadmill` (every ask names the concepts it rests on, held, stale or open); Nielsen's heuristic 2, speak the users' language.
- Blackbox to the decision: his own method, "Black-box the flow, then follow each byte process by process" (Jun 26 and Jul 6, 2026, in `inbox/reader/scratch/portrait/all/own-words.md`); Parnas, "On the Criteria To Be Used in Decomposing Systems into Modules", 1972 (information hiding); Hayek, 1945, "how little the individual participants need to know in order to be able to take the right action", as Lucidity's `information-flow` uses it.
- One level per layer: the C4 model's one zoom level per diagram; Bret Victor, "Up and Down the Ladder of Abstraction", 2011; depth by what he holds is the expertise reversal effect (Kalyuga, Ayres, Chandler and Sweller, 2003), as Lucidity's `maximize-learning` applies it.
- Overview first: Shneiderman, "The Eyes Have It", 1996; Nielsen, "Progressive Disclosure", 2006, which caps it at two levels.
- One home: DRY, "a single, authoritative representation" (Hunt and Thomas, 1999).
- One shape: Gestalt similarity, Bertin's visual variables and Horn's information mapping.

The order, skipping layers the page does not need:

1. A title that names the thing, then the bottom line and the picture of the whole, both on the first screen where they fit.
2. The core idea and its concepts: the few the rest of the page uses, each introduced once by what it does.
3. The core mechanisms.
4. The architecture and stack.
5. Each part in depth.
6. Risks and alternatives.
7. Decisions.
8. The plan.
9. The log, collapsed, ending with the Reader review log (step 5).

Every section opens with a visual that its text only labels: a step track for builds and trackers, a diagram or clickable map for systems and bugs, decision cards for anything waiting on him, a step-by-step table when he has to follow a mechanism in order.

Before the review, apply four tests at 1280 and 390 px.

- **Stop test**: cover everything below the first screen; can he say what this is, where it stands and what is asked of him?
- **Concept test**: list the concepts the first screen and each decision rest on, and mark each held (his reader files), introduced above, or neither; fix every neither.
- **Split test**: each block in the default view is visible because most readers need it, one open down behind a label that says what it is because some do, or deleted because none do; anything he needs to act comes up.
- **Readability test**: readability of the artifact is most important.
  Look at the screenshots, not the source: avoid text density, and aim to convey each point effectively and articulately, with short sentences, one idea per line and room to breathe.

Word counts and screens tall are only a before-and-after diagnostic on a rewrite, never a target.

## 4. Build it

- Inline the nearest `.lavish-shared/lavish-skin.css` whole in `<style>`, never linked, and set `<html lang="en" data-theme="...">` to the theme that file defines.
  Copy the `<head>` from an existing page of the same project.
- Motion only where it explains something, always under `prefers-reduced-motion`.
- Works at 390 px wide, with no horizontal scroll.
- Every full sentence on its own line in the source.
- The model pages are the ones the global policy names.
- Under the title, a **Related** line links the pages a reader of this one would look for next: the pages it builds on, answers or is weighed against, and their design boards.
  Each link gets a few words on why, and uses the page's full address, so it works wherever the page is opened.

## 5. Reader review

The writer cannot see what the reader is missing, because the writer knows it.
So two fresh agents read the draft in parallel, and the writer answers both lists in one pass.

### 5a. Write the seen list

A short file, `seen.md`, beside the draft: what he asked, and what he has been shown or told on this topic.
It tells the reviewer which names he may recognise, never what he understands: shown is not understood (step 1).

- **From the chat**: his words, quoted verbatim, and what he was told, marked as told.
- **From the records**: pages or notes he opened, where the project keeps a read record, and pages he said he read.
- **Concepts he does not hold**: every concept the page rests on that his reader files do not hold, including those behind names he was shown.
  Reviewers use this part most; never leave it out.
- **Left out**: his reader files. The reviewer reads them directly, so the seen list never copies them.

A writer with no chat (a worker running a task) builds it from the task file instead: his brief, his answers to stops, his comments, plus the read records.
**Untested**: no worker has built a seen list yet.

The seen list belongs to this one page: it is published in the page's log so he can correct it, and is used nowhere else.
A line in it never enters a reader file; only a teach-back does that.

### 5b. Launch both agents at once

Two **fresh** agents, started with no context, on Opus, in the same turn.
Never a fork: a fork inherits the writer's conversation and reviews with the writer's knowledge.
Fill in only the paths; the prompts are fixed.

**Reviewer**, playing the reader:

```text
You are the person described in <portrait>. Read <portrait> (that is you) and <project reader file>; the concepts you hold are the ones those two files hold, and no others. <seen.md> is what you asked and what you were shown or told on this topic; shown is not understood, so a name there is one you may recognise, not a concept you hold. That and the page are all you know, so open no other file. Read <page> as yourself, top to bottom, and look at it as rendered in <screenshots> at 1280 and 390 px.
You think in concepts, not terms: a concept is an idea with a job, what it is, what it does and why it matters here. First restate each decision on the page in one line: what is being chosen, why, and which part you would doubt; any you cannot restate is your first item. Then judge the page's information design, section by section:
1. Order: is each concept one you hold or one the page introduced above it, by what it does? Do you know what this is and where it stands before anything is asked of you?
2. Handles: does a label from the writer's process (a step or PR number, a decision id, a check's result such as "0 differences") stand where the concept it names should be?
3. Blackboxing: for the decision at hand, does the page show what the choice turns on and close what does not change it? Is something you need closed, or something you don't need open?
4. Abstraction: does each section stay at one level, the whole before its parts, with units that are what the decision is about rather than how the work was organised?
Then readability, which matters most for every artifact: where is the text too dense, and where does a point fail to come across quickly and articulately? Then the rest: conclusions without working, recommendations you can't reason about, things put to you that aren't really your decision.
For each item give where it is, which check it breaks, what you'd think, and the fix: the concept to introduce or the handle to replace, what to open or close, what to move. Keep it to the 15 that matter most, most important first, starting with the one that most stops you acting, and end with whether you could act on it. Write to <dir>/review.md.
```

**Fact judge**, holding the sources:

```text
You are a fact judge. Read <page>. From the page itself, pick the claims its bottom line and each of its decisions rest on; you choose them, not the writer. Check each against the primary sources: the code at <repo paths>, logs, command output, CI runs, commits and data you can query. A doc, README, contract or policy saying something is a claim to check, not a source. Mark each claim holds, wrong or unsupported, and give the evidence: a file and line, a log line, a run, a commit, or what you looked for and did not find. Judge facts only, not wording or layout. List the wrong ones first. Write to <dir>/facts.md.
```

Interim, until Lucidity's values are built into a proper system: append to the reviewer prompt "Also read <Lucidity reader file> and the Lucidity ideas in step 1 of <this skill>, and list where the page breaks one."

The four checks are step 3's rules 1 to 4; the restatement is the cold read in Lucidity's `information-flow` (a reader who cannot say what was chosen, why, and which term to doubt was not given the working).
The reviewer holds no sources by design, so it cannot tell a confident wrong claim from a right one; the judge holds the sources, so it cannot tell what the reader has seen.
Neither needs the other's output, so running them together costs no wall time.

**A Codex writer** cannot start a Claude subagent; it runs each prompt as a headless Claude session, which is also fresh, both in the background, then waits for both.
A headless session cannot answer a permission prompt, so each prompt's last sentence becomes "Print it as your answer." and the shell writes the file:

```sh
claude -p --model opus --allowedTools "Read,Grep,Glob" "<reviewer prompt, paths filled>" > "<dir>/review.md" &
claude -p --model opus --allowedTools "Read,Grep,Glob,Bash" "<fact judge prompt, paths filled>" > "<dir>/facts.md" &
wait
```

**Untested**: no Codex writer has run this yet; check that both files hold a list before going on.

### 5c. Answer every item, in one pass

Each reviewer item and each judged claim gets exactly one answer:

- **Fixed**: the page changed. If the item named a missing or wrong fact, the fix cites where it was checked: a file and line, a log, a run, a commit.
- **Unknown**: the fact cannot be checked now. The page marks it unknown where the claim stands, says what would settle it, and does not fill it.
- **Rejected**: the reviewer or judge is wrong, with the evidence why; for example the seen list was wrong, or it misread the page.
  Rejections stay visible in the log: the writer judging its own critic is the bias this round exists to avoid.

A claim the judge marked holds needs no change; log it as holds.
Never reword to sound sure: rewording leaves the false premise standing.
New text the answers add can bring new errors; check each new fact as you would any other.

One round: the reader is the next reader.
Anything added after the review is marked in the log as not reviewed.

### 5d. Write the Reader review log

The last section of the page, collapsed, in exactly this shape; the publish check looks for the summary line and refuses a page without it:

```html
<details id="reader-review">
<summary>Reader review · 12 items, 7 claims · Nov 5</summary>
<p>Two fresh Opus agents, in parallel: a reviewer playing the reader, holding only his two reader files, the seen list below and the page; a fact judge holding the code, logs and runs. Reviewer's verdict: "…".</p>
<table>
  <tr><th>#</th><th>Reviewer item</th><th>Answer</th></tr>
  <tr><td>1</td><td>The item, in one line.</td><td>Fixed: what changed, and where it was checked.</td></tr>
</table>
<table>
  <tr><th>#</th><th>Claim</th><th>Judge</th><th>Answer</th></tr>
  <tr><td>1</td><td>The claim, in one line.</td><td>Wrong: the evidence.</td><td>Fixed: what the page says now.</td></tr>
</table>
<p>Rejected: none. (Or: the rejected items' numbers.)</p>
<details><summary>The seen list the reviewer held</summary><pre>…seen.md…</pre></details>
</details>
```

The counts in the summary are the reviewer's items and the judge's claims.
`review.md` and `facts.md` are scratch; the log is the record.

## 6. Publish

Publish the page the way its project does (a note command, a review session, or a commit with its index row).
Then add this page to the Related line of each page it links, and republish those, so every link runs both ways.
A page without a Reader review log is refused at publish, with a message naming this skill; the answer is to run step 5, never to write a log without it.
