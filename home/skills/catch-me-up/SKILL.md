---
name: catch-me-up
description: Print every need still open for Reevu, from the orchestrator's needs buffer checked against Treadmill's live state. Use when he types /catch-me-up or asks what needs him.
---

# catch-me-up

The orchestrator stays silent between his messages and keeps a needs buffer: one file per need in `~/.claude/orchestrate/needs/`, added as needs come in and deleted as he resolves them (the `orchestrate` skill).
A catch-up shows what is in the buffer now.
It marks nothing: a need he does not resolve shows again next time, as it then stands.

## Gather

1. Every file in `~/.claude/orchestrate/needs/`.
2. Treadmill's live state, in `~/github/gallopify-playground/treadmill-tasks` after `git pull`: `needs-you/`, and each stream under `open/` whose move names something for him.
   A need found there and not in the buffer is added to the buffer first.
3. Check each need still holds before printing it: the task is still stopped, the PR is still open, the question is still unanswered.
   One that has been settled elsewhere is deleted, not printed.

## Print

One numbered list, the needs that most hold up work first, each standing alone (he reads nothing else): what he decides or does, its link, the working, and the recommended default (none when the question is his to form).
Numbering lets him answer "3) default".
Below it, one line per stream that is moving with nothing for him, so he knows it is in hand.
When the buffer is empty, say so in one line.
Apply the orchestrate skill's three checks to the whole print.
