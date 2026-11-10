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
- List what the page will rest on that is not in either file.
  Each item goes into the page's working, introduced before it is used, or the page stops short of it.
- His context is the chat plus pages he has opened.
  A name coined in a scratch file, a subagent report or a task outcome is unseen until the page introduces it; never use one bare.

## 2. Show the working

- He wants to be convinced, not told: give "2 + 1 + 1 = 4?", never "4?".
- A number is measured, with its source, or marked as an estimate.
  An unverified claim says so where it stands; a visible gap beats a plausible fill.
- Every decision is a card: the problem it settles, the options, a recommended default, and the reason in terms he already holds.
  A recommendation he cannot reason about is a failure of the page, not of the reader.
- If the code contradicts something in his reader file, say what changed and since which commit.

## 3. Layer it

Each section uses only concepts introduced above it; push detail down and leave a one-line summary above.
The order, skipping layers the page does not need:

1. Headline that states the situation, then a picture of the problem (where it breaks, what is missing, who holds each piece).
2. One paragraph starting "Problem:", at most three sentences: what we are solving, what done looks like, what it needs.
3. The core idea and its words: the few terms the rest of the page uses, defined once.
4. The core mechanisms.
5. The architecture and stack.
6. Each part in depth.
7. Risks and alternatives.
8. Decisions.
9. The plan.
10. The log, collapsed, ending with the Reader review log (step 5).

Under 120 words above the fold.
Every section opens with a visual that its text only labels: a step track for builds and trackers, a diagram for systems and bugs, decision cards for anything waiting on him, a step-by-step table when he has to follow a mechanism in order.
Headings state conclusions, not topics.
History, evidence and per-item detail go in `<details>`.

## 4. Build it

- Inline the nearest `.lavish-shared/lavish-skin.css` whole in `<style>`, never linked, and set `<html lang="en" data-theme="...">` to the theme that file defines.
  Copy the `<head>` from an existing page of the same project.
- Motion only where it explains something, always under `prefers-reduced-motion`.
- Works at 390 px wide, with no horizontal scroll.
- Every full sentence on its own line in the source.
- The model pages are the ones the global policy names.
- Under the headline, a **Related** line links the pages a reader of this one would look for next: the pages it builds on, answers or is weighed against, and their design boards.
  Each link gets a few words on why, and uses the page's full address, so it works wherever the page is opened.

## 5. Reader review

The writer cannot see what the reader is missing, because the writer knows it.
So two fresh agents read the draft in parallel, and the writer answers both lists in one pass.

### 5a. Write the seen list

A short file, `seen.md`, beside the draft: what the reader has been shown or told on this topic, and what he has not.

- **From the chat**: his words, quoted verbatim, and what he was told, marked as told.
- **From the records**: pages or notes he opened, where the project keeps a read record, and pages he said he read.
  A read record is a floor, not the list: it shows a page was opened, not understood, and knows nothing of chat.
- **What he does NOT know**: every term, mechanism and name the page uses that neither source shows he was given.
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
You are the person described in <portrait>. Read <portrait> (that is you) and <project reader file>. What you have seen is <seen.md>; that and the page are all you know, so open no other file. Read <page> as yourself. What is missing or wrong before you could understand it and act on its decisions? For each item give where it is, what you'd think, and the fix: unknown terms, conclusions without working, recommendations you can't reason about, things put to you that aren't really your decision. Keep it to the 15 that matter most, most important first, starting with the one that most stops you acting, and end with whether you could act on it. Write to <dir>/review.md.
```

**Fact judge**, holding the sources:

```text
You are a fact judge. Read <page>. From the page itself, pick the claims its headline and each of its decisions rest on; you choose them, not the writer. Check each against the primary sources: the code at <repo paths>, logs, command output, CI runs, commits and data you can query. A doc, README, contract or policy saying something is a claim to check, not a source. Mark each claim holds, wrong or unsupported, and give the evidence: a file and line, a log line, a run, a commit, or what you looked for and did not find. Judge facts only, not wording or layout. List the wrong ones first. Write to <dir>/facts.md.
```

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
