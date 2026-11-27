---
name: lavish-page
description: Write any Lavish page or file the reader will read (a note, a decision page, a morning report, an analysis, a prepped task, a decision stage, an outcome page) so that, holding only the page and his reader files, he can act on it. Keeps the form the reader asked for a page, held in the page's form line. Ends with the reader review, a fresh agent playing the reader, a fact judge and an agent reader run in parallel, recorded as a review mark in the page's head with the log off the page. Use before writing or rewriting any Lavish file, in any project; publishing refuses a page without the mark.
---

# lavish-page

A page is finished when the reader, holding only it and what he already understands, can act on it.
Those two inputs are fixed before you write a word: the page carries everything else.
The global policy's "Lavish page standard" and "Reader files" sections are the rules; this skill is how to apply them, in order.
It covers every new Lavish file or rewrite, whoever writes it; an appended log line or a tracker row is not a new page.

## 1. Load the reader

- Read the page's form line first, if it has one: `<meta name="lavish-form" content="...">` in its head, one per page, holding the form the reader asked for this page, in his words.
  When he states a form for a page (in chat, a brief or a stop answer), write it into the form line in his words; when it governs only part of the page, scope it in words ("top: ...; below: the standard").
  Never change an existing form line unless he does, and quote his words asking for the change where the publish route records it (a commit body, a PR description).
  The form overrides step 3's defaults wherever they conflict: the bottom line beside a picture, a visual per section, the fold for agents, the order list.
  Step 3's tests apply only as far as the form allows.
- Read his portrait, the reader file beside the global agent policy: who he is, how he reasons, what convinces him.
- Read the project's reader file, the nearest one above the work: its big picture, then the group section the page belongs to; name the group before writing.
- List the concepts the page will rest on that neither file holds.
  Each goes into the page, introduced before it is used, or the page stops short of it.
- What he holds is what those two files hold.
  The chat and the pages he was shown are names he may recognise, not concepts he understands: shown is not understood.
  A name coined in a scratch file, a subagent report or a task outcome is not even recognised; never use one bare.
- Interim, until Lucidity's values are built into a proper system: read Lucidity's reader file, `~/github/lucidity-skills/reevu.md` in the workspace, and skim the notes in `~/github/treadmill-tasks/notes/lucidity/` for the values they list.
  The notes are the source; this list only points at them, so when they disagree, the notes win.
  Every page applies these:
  - An ask earns his attention only for what his input uniquely provides; anything another source holds goes there first (`what-needs-you`).
  - Working, not conclusions: "2 + 1 + 1 = 4?", never "4?" (`knowledge-problem`, `information-flow`).
  - Setting work aside should not leave him remembering that it is open; parked work keeps its place by itself (`what-needs-you`).
  - What starts collapsed and the order things come in are attention choices: his moves lead, placed where they sit on the picture of the whole, and finished work leaves by itself (`attention`).

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
   A page that reports on work (a map, a tracker, a report) is built around the question its reader comes with ("what stands between us and the first trade?"): the verdict answers it, the picture of the whole is the answer's structure, and each status and ask sits on that picture beside the step it unblocks.
   Asks are told once, there; a list by holder is a view of those same items, linked, never a second telling above the picture.
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
5. **Overview first, detail on demand: the fold divides two readers.**
   The default view is for him: with nothing opened, it shows the whole, every route into it, blackboxes at the level of the decisions he holds, and everything he needs to act, with the reason for a recommendation beside it.
   Behind a closed fold is complete context for an agent that will carry the work: structured and complete, with ids, files, sources and done-checks, written for an agent to take in, not polished prose.
   The visible item names the concept and its fold carries everything needed to act on it, so the fact keeps one home.
   What neither reader needs is deleted, not folded; no fact is more than two opens from the default view.
6. **One home per fact.**
   Argue it once, at the shallowest place whose reader needs it; everywhere else mentions it in one line that links there.
   A summary line above its detail is that mention, not a second telling.
7. **One shape per kind, one meaning per signal.**
   Items of the same kind have the same parts in the same order; a colour or chip means one thing on the whole page.
   Keep apart what he acts on, what he reads to understand, what he looks up and what he audits.

Sources, one line each:

- Information foraging: Pirolli and Card, "Information Foraging", Psychological Review, 1999.
- The reader's question as the frame: Minto, "The Pyramid Principle", 1987, the top of the pyramid answers the question already in the reader's mind; Larkin and Simon, "Why a Diagram is (Sometimes) Worth Ten Thousand Words", Cognitive Science, 1987, a diagram indexes information by location, so what is used together is found together without search; Mayer, "Multimedia Learning", 2001, spatial contiguity, words placed beside the part of the picture they describe; Lucidity's `information-flow`, a record sits beside what it governs.
- Bottom line first, situation before ask: the military BLUF convention; Minto's pyramid principle and its situation, complication, question, answer; Treadmill's information-economy page, `~/github/inbox/treadmill/treadmill-information-economy.html` (an ask arrives in one frame: what it is part of, what it unblocks).
- Concepts before use: Ausubel, 1968, "the most important single factor influencing learning is what the learner already knows"; Lucidity's `learning-in-treadmill` (every ask names the concepts it rests on, held, stale or open); Nielsen's heuristic 2, speak the users' language.
- Blackbox to the decision: his own method, "Black-box the flow, then follow each byte process by process" (Jun 26 and Jul 6, 2026, in `~/github/inbox/reader/scratch/portrait/all/own-words.md`); Parnas, "On the Criteria To Be Used in Decomposing Systems into Modules", 1972 (information hiding); Hayek, 1945, "how little the individual participants need to know in order to be able to take the right action", as Lucidity's `information-flow` uses it.
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
9. The log, collapsed; the Reader review log stays off the page (step 5d).

Every section opens with a visual that its text only labels: a step track for builds and trackers, a diagram or clickable map for systems and bugs, decision cards for anything waiting on him, a step-by-step table when he has to follow a mechanism in order.

Before the review, apply four tests at 1280 and 390 px.

- **Stop test**: cover everything below the first screen; can he say what this is, where it stands and what is asked of him?
- **Concept test**: list the concepts the first screen and each decision rest on, and mark each held (his reader files), introduced above, or neither; fix every neither.
- **Split test**: each block is visible because he needs it to understand or decide, behind a closed fold because an agent needs it to act, or deleted because neither does; anything he needs comes up, and anything only an agent needs goes down.
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
So three fresh agents read the draft in parallel, and the writer answers all three lists in one pass.

### 5a. Write the seen list

A short file, `seen.md`, beside the draft: what he asked, and what he has been shown or told on this topic.
It tells the reviewer which names he may recognise, never what he understands: shown is not understood (step 1).

- **From the chat**: his words, quoted verbatim, and what he was told, marked as told.
- **From the records**: pages or notes he opened, where the project keeps a read record, and pages he said he read.
- **Concepts he does not hold**: every concept the page rests on that his reader files do not hold, including those behind names he was shown.
  Reviewers use this part most; never leave it out.
- **The form line**: the page's form line, quoted whole, or "none".
- **Left out**: his reader files. The reviewer reads them directly, so the seen list never copies them.

A writer with no chat (a worker running a task) builds it from the task file instead: his brief, his answers to stops, his comments, plus the read records.
**Untested**: no worker has built a seen list yet.

The seen list belongs to this one page: it goes into the review log file (step 5d) so he can correct it, and is used nowhere else.
A line in it never enters a reader file; only a teach-back does that.

### 5b. Launch all three agents at once

Three **fresh** agents, started with no context, on Opus, in the same turn.
Never a fork: a fork inherits the writer's conversation and reviews with the writer's knowledge.
Fill in only the paths; the prompts are fixed.

**Reviewer**, playing the reader:

```text
You are the person described in <portrait>. Read <portrait> (that is you) and <project reader file>; the concepts you hold are the ones those two files hold, and no others. <seen.md> is what you asked and what you were shown or told on this topic; shown is not understood, so a name there is one you may recognise, not a concept you hold. That and the page are all you know, so open no other file. The page's form line, if it has one, is quoted in <seen.md>: it is what you asked for this page, so check the page against it and ask for nothing it rules out. Read <page> as yourself, top to bottom, with every fold closed, as rendered in <screenshots> at 1280 and 390 px; the default view is yours, and what sits behind a closed fold is written for an agent, so open one only when its label makes you want to.
You think in concepts, not terms: a concept is an idea with a job, what it is, what it does and why it matters here. First restate each decision on the page in one line: what is being chosen, why, and which part you would doubt; any you cannot restate is your first item. Then judge the page's information design, section by section:
1. Order: what question did you come to this page with, and is the page built around it, with the verdict answering it and each ask placed on the picture of the whole beside what it unblocks, rather than in a list above it or told twice? Is each concept one you hold or one the page introduced above it, by what it does? Do you know what this is and where it stands before anything is asked of you?
2. Handles: does a label from the writer's process (a step or PR number, a decision id, a check's result such as "0 differences") stand where the concept it names should be?
3. Blackboxing: for the decision at hand, does the page show what the choice turns on and close what does not change it? Is something you need to understand or decide hidden behind a fold, or something only an agent needs left open?
4. Abstraction: does each section stay at one level, the whole before its parts, with units that are what the decision is about rather than how the work was organised?
Then readability, which matters most for every artifact: where is the text too dense, and where does a point fail to come across quickly and articulately? Then the rest: conclusions without working, recommendations you can't reason about, things put to you that aren't really your decision.
For each item give where it is, which check it breaks, what you'd think, and the fix: the concept to introduce or the handle to replace, what to open or close, what to move. Keep it to the 15 that matter most, most important first, starting with the one that most stops you acting, and end with whether you could act on it. Write to <dir>/review.md.
```

**Fact judge**, holding the sources:

```text
You are a fact judge. Read <page>. From the page itself, pick the claims its bottom line and each of its decisions rest on; you choose them, not the writer. Check each against the primary sources: the code at <repo paths>, logs, command output, CI runs, commits and data you can query. A doc, README, contract or policy saying something is a claim to check, not a source. Mark each claim holds, wrong or unsupported, and give the evidence: a file and line, a log line, a run, a commit, or what you looked for and did not find. Judge facts only, not wording or layout. List the wrong ones first. Write to <dir>/facts.md.
```

**Agent reader**, taking the work forward:

```text
You are a fresh agent about to carry forward the work <page> drives, with no way to ask its author. Read <page> with every fold open, and <what it drives: the task file, the work it hands off>, and any file or source they point to. Nothing else counts: what they do not say or link, you do not know.
The page's form line, if it has one, `<meta name="lavish-form" content="...">` in its head, is the form the reader asked for this page; it overrides the default shape, so check the folds against it and ask for nothing it rules out.
First restate the work in four lines: its purpose, the end state that counts as done, your first action, and the first point where you would stop and ask. Any line you cannot fill is your first item.
Then judge whether the folded content is complete context to carry the work, against six questions:
1. Intent: does it say why the work exists and what end state counts as done, well enough that you would still choose rightly if the plan stopped fitting?
2. State: does it say what is done, what is decided (with the reason and who decided) and what is open, so you can tell them apart and would not reopen a settled choice?
3. Contract: does it say what must hold before you start (inputs, access, prior work, waits) and what checkable condition proves you have finished?
4. Boundary: does it say what is yours to change, what you must not touch, and which decisions are the reader's (the blackboxes in the page's default view), so you know when to stop and ask rather than choose?
5. Contingency: does it say what is known to go wrong, and for each, what to do or when to stop?
6. Grounding: does every reference resolve without the author (ids, paths, commands, links, commits, sources), and is there anything you would load only to ignore?
For each gap give where it is, which question it fails, what you would have done wrong or had to ask, and the fix: the fact, reference or check to add, or what to cut. Keep it to the 15 that matter most, most important first, and end with whether you could carry the work forward from this alone. Write to <dir>/context.md.
```

Interim, until Lucidity's values are built into a proper system: append to the reviewer prompt "Also read <Lucidity reader file> and the Lucidity ideas in step 1 of <this skill>, and list where the page breaks one."

The four checks are step 3's rules 1 to 4; the restatement is the cold read in Lucidity's `information-flow` (a reader who cannot say what was chosen, why, and which term to doubt was not given the working).
The agent reader's restatement is I-PASS's synthesis by receiver; its six questions compose how others hand work to someone who must act without the author:

- Intent: commander's intent in US Army mission command (ADP 6-0, 2019), the purpose and end state that let a subordinate act without further orders when the plan stops fitting.
- State: SBAR's situation and background (Kaiser Permanente, as IHI publishes it) and I-PASS's patient summary (Starmer et al., NEJM, 2014).
- Contract: Meyer, "Applying Design by Contract", IEEE Computer, 1992, a precondition the caller guarantees and a postcondition the routine proves.
- Boundary: Parnas, 1972, a module's interface says what others may rely on and hides the rest; mission command's disciplined initiative acts within intent.
- Contingency: I-PASS's situation awareness and contingency planning; Google's SRE book, where a playbook written ahead gives "roughly a 3x improvement in MTTR" over winging it.
- Grounding: Anthropic, "Effective context engineering for AI agents", 2025, the smallest set of high-signal tokens, and prompts fail when they "assume shared context"; Lucidity's `agent-context`, loaded is not applied.

The reviewer holds no sources by design, so it cannot tell a confident wrong claim from a right one; the judge holds the sources, so it cannot tell what the reader has seen; the agent reader reads only the folds and what the page drives, so it cannot tell whether he understands the default view.
None needs another's output, so running them together costs no wall time.

**A Codex writer** cannot start a Claude subagent; it runs each prompt as a headless Claude session, which is also fresh, all three in the background, then waits for all three.
A headless session cannot answer a permission prompt, so each prompt's last sentence becomes "Print it as your answer." and the shell writes the file:

```sh
claude -p --model opus --allowedTools "Read,Grep,Glob" "<reviewer prompt, paths filled>" > "<dir>/review.md" &
claude -p --model opus --allowedTools "Read,Grep,Glob,Bash" "<fact judge prompt, paths filled>" > "<dir>/facts.md" &
claude -p --model opus --allowedTools "Read,Grep,Glob" "<agent reader prompt, paths filled>" > "<dir>/context.md" &
wait
```

**Untested**: no Codex writer has run this yet; check that all three files hold a list before going on.

### 5c. Answer every item, in one pass

Each reviewer item, judged claim and agent-reader gap gets exactly one answer:

- **Fixed**: the page changed. If the item named a missing or wrong fact, the fix cites where it was checked: a file and line, a log, a run, a commit.
- **Unknown**: the fact cannot be checked now. The page marks it unknown where the claim stands, says what would settle it, and does not fill it.
- **Rejected**: the reviewer, judge or agent reader is wrong, with the evidence why; for example the seen list was wrong, or it misread the page.
  Rejections stay visible in the log: the writer judging its own critic is the bias this round exists to avoid.

A claim the judge marked holds needs no change; log it as holds.
Never reword to sound sure: rewording leaves the false premise standing.
New text the answers add can bring new errors; check each new fact as you would any other.

One round: the reader is the next reader.
Anything added after the review is marked in the review log file as not reviewed.

### 5d. Record the review: the mark on the page, the log off it

The log stays off the page, so revisions do not grow it.
The page carries only the review mark, one line in its head, which the publish check looks for and refuses a page without:

```html
<meta name="lavish-review" content="Nov 5 · 12 items, 7 claims, 5 gaps">
```

Name first, then content, in double quotes, with the date and the counts: the reviewer's items, the judge's claims and the agent reader's gaps.
On a revision that runs a new review, replace the mark; a page has one.

The log is a markdown file beside the page, `<page>.review.md` (for `plan.html`, `plan.review.md`), in this shape:

````markdown
Reader review · 12 items, 7 claims, 5 gaps · Nov 5

Three fresh Opus agents, in parallel: a reviewer playing the reader, holding only his two reader files, the seen list below and the page with its folds closed; a fact judge holding the code, logs and runs; an agent reader holding the folded content and what the page drives. Reviewer's verdict: "…". Agent reader's verdict: "…".

| # | Reviewer item | Answer |
|---|---|---|
| 1 | The item, in one line. | Fixed: what changed, and where it was checked. |

| # | Claim | Judge | Answer |
|---|---|---|---|
| 1 | The claim, in one line. | Wrong: the evidence. | Fixed: what the page says now. |

| # | Agent-reader gap | Answer |
|---|---|---|
| 1 | The gap and the question it fails, in one line. | Fixed: what the fold carries now. |

Rejected: none. (Or: the rejected items' numbers.)

The seen list the reviewer held:

```text
…seen.md…
```
````

Where the log lands depends on how the page is published:

- `treadmill note` and `treadmill file` put the sibling file in their commit body; leave it beside the page when you call them.
- A page committed by hand (the inbox, a scaffold repo) puts the log in that commit's message body.
- A page in a PR puts the log in the PR description.
- A page a Treadmill run writes to its `out/` folder keeps `out/<page stem>.review.md` beside it.
- A page published with `lavish-axi`, or by any route with no commit, keeps the sibling file next to the page.

`review.md`, `facts.md` and `context.md` are scratch; the log is the record.
Pages written before this rule carry the log on the page under `<summary>Reader review · N items, M claims · date</summary>`; the publish check still accepts that shape, and a rewrite that runs a new review replaces it with the mark.

## 6. Publish

Publish the page the way its project does (a note command, a review session, or a commit with its index row).
Then add this page to the Related line of each page it links, and republish those, so every link runs both ways.
A page with neither the review mark nor the older on-page summary is refused at publish, with a message naming this skill; the answer is to run step 5, never to write a mark or a log without it.
