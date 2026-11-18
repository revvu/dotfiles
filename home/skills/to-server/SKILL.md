---
name: to-server
description: Hand all of the laptop's work over to the server so Reevu can close his laptop: stop every agent at a clean point, copy laptop-only inputs across, write one brief, and start a worker on the server in a new herdr tab. Run by the laptop Orchestrator when he types /to-server or says he wants to close his laptop.
---

# to-server

Reevu wants to close his laptop; everything running here moves to the server, `server.tail334649.ts.net`, and nothing is lost.
Treadmill streams need nothing from you: the Shepard on the server already drives every open stream.
Everything else goes to one new worker on the server, through one brief.
Run every server command as `ssh server.tail334649.ts.net zsh -lc '<command>'`, so the server's login PATH (herdr, treadmill) loads.

## 1. Stop at a clean point

Tell every subagent you started, through `SendMessage`, and every herdr agent working on the laptop (`herdr agent list`, then `herdr agent prompt <name> "..."`):
"Stop at the next clean point, commit and push your work to a branch, and report what is done and what is left, with branch names and paths."
Wait for every report.
Stop each background shell you started (`TaskStop`), after noting what it was for.

## 2. Settle the stream work

For work that belongs to a Treadmill stream, make sure the tasks repo holds it: each task or note staged in its stream, each answer of his recorded with `treadmill need answer`.
The Shepard takes it from there; it does not go in the brief.

## 3. Copy laptop-only inputs

Find each file the remaining work needs that exists only on this laptop: untracked or unpushed files, downloads, attachments he dropped into a repo.
Copy each to the same path on the server: `ssh server.tail334649.ts.net mkdir -p <dir>`, then `scp <path> server.tail334649.ts.net:<path>`.
Check it arrived with `ssh server.tail334649.ts.net ls -l <path>`.

## 4. Write one brief

Write `~/.claude/orchestrate/BRIEF-<YYYY-MM-DD>.md` (add `-2` if that name is taken on the server) and copy it to the same path on the server.
The worker knows only the brief, so it carries everything and never your guess at an answer:

- **Start:** `cd ~/github/gallopify-playground`; pull treadmill-tasks; read `~/.claude/reevu.md` and each project's `reevu.md` before writing to him.
  When a job finishes or needs him, write a need with `treadmill-main/bin/treadmill need put <slug> <file>` (`For: reevu`, last line `Default: ...`; the shape is in the shepard skill) so his /catch-me-up shows it.
  Commit and push everything; keep nothing only in the session.
  The Shepard's pane and streams are not yours.
- **Standing rules:** the lines from his files and from this conversation that bind the work (environments, channels, who may see what, commit rules).
- **Per job:** Reevu's words, verbatim; what he approved, quoted; done so far (commits, branches, paths); left, as steps.

## 5. Start the worker

On the server, all under `ssh server.tail334649.ts.net zsh -lc '...'`:

1. `herdr tab create --cwd ~/github/gallopify-playground --label <name> --no-focus`, where `<name>` is unique, e.g. `worker-<MMDD>`.
   Read the new pane id from `.result.root_pane.pane_id` (pipe through `jq -r`).
2. `herdr agent start <name> --kind claude --pane <pane-id>`.
3. `herdr agent prompt <name> "Read ~/.claude/orchestrate/BRIEF-<date>.md and carry out all jobs in it. You are a worker on the server; Reevu has closed his laptop." --wait`.
4. `herdr agent read <name>` and confirm it has started on the brief.

## 6. Confirm the laptop is idle, then tell him

Check that nothing still works on the laptop: no subagent running, no background shell, and `herdr agent list` shows no agent working.
Then tell him, in a few lines: what went to the Shepard, what went to the worker (its herdr tab name and the brief's path), what was copied, and that it is safe to close the laptop.
