---
name: catch-me-up
description: Print everything Reevu has not seen since his last catch-up, from the orchestrator's ledger and Treadmill's live state, then mark the ledger. Use when he types /catch-me-up or asks what he missed.
---

# catch-me-up

The orchestrator stays silent between his messages and records what happens in its ledger (the `orchestrate` skill).
This skill is the one place he reads it, so what he has seen is exactly what earlier catch-ups printed.

## Gather

1. The ledger, `~/.claude/orchestrate/ledger.md`: every line after the last `--- caught up <ISO time>` marker (all of it if there is none).
2. Live state, which wins over the ledger when they differ: in `~/github/gallopify-playground/treadmill-tasks` (after `git pull`), every file in `needs-you/`, every stream under `open/` with its move, and what is in `running/` and `launch/`.
   A ledger `needs-you` line whose item is no longer open is reported as settled, not as asked.
3. Anything still running in this session (background agents and jobs) that the ledger names as started.

Check the claims a line rests on before printing it, as for any report: a commit exists, a PR merged, a page is filed.

## Print

In this order, each item standing alone (he reads nothing else):

1. **Needs you**: one numbered list of every open ask, new or old, new ones marked new; each with what he decides, its link, the working and a recommended default (none when the question is his to form). Numbering lets him answer "3) default".
2. **Since your last catch-up**: what finished, merged or was answered, grouped by stream, one line each with its link.
3. **Still running**: one line each, with what it waits on.

When nothing changed and nothing is open, say so in one line.
Apply the orchestrate skill's three checks to the whole print.

## Mark

Append `--- caught up <ISO time>` to the ledger, so the next catch-up starts after it.
