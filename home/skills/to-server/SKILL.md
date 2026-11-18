---
name: to-server
description: Hand all of the laptop's work over to the server so Reevu can close his laptop: stop every agent at a clean point, open a stream per piece of work, copy laptop-only inputs across, write one brief, and start an Orchestrator on the server that preps each piece as a task and launches it into its stream, for the Shepard to drive. Run by the laptop Orchestrator when he types /to-server or says he wants to close his laptop.
---

# to-server

Reevu wants to close his laptop; everything running here moves to the server, `server.tail334649.ts.net`, and nothing is lost.
Every piece of work lands in a Treadmill stream as a launched task, so the Shepard drives it and its asks reach Needs you.
Only a piece that cannot become a task is done directly, by the server Orchestrator, as the last fallback.
A piece of work is one job with its own end state: one stream, one section of the brief.
Running /to-server is his word to prep each piece and launch it without showing him the task first; if he says otherwise, follow him.

## Running commands on the server

Every Treadmill call runs on the server, never on the laptop: the laptop's calls clone the tasks repo and time out.
Run server commands as a script on the server's login shell, which loads its PATH (herdr, jq):

```sh
ssh server.tail334649.ts.net zsh -l <<'EOF'
treadmill() { ~/github/gallopify-playground/treadmill-main/bin/treadmill "$@"; }
<commands>
EOF
```

`treadmill` below means that function: the runner copy the tick keeps at main, the same one the shepard skill uses, since `treadmill` is not on the server's login PATH.
Never pass a command as ssh arguments, as in `ssh <host> zsh -lc '<command>'`: ssh joins them into one string, so the server runs only the command's first word.
A command that reads stdin takes a nested heredoc inside the script, since the script itself is ssh's stdin.

## 1. Stop at a clean point

Tell every subagent you started, through `SendMessage`, and every herdr agent working on the laptop (`herdr agent list`, then `herdr agent prompt <name> "..."`):
"Stop at the next clean point, commit and push your work to a branch, and report what is done and what is left, with branch names and paths."
Wait for every report.
Stop each background shell you started (`TaskStop`), after noting what it was for.

## 2. One stream per piece of work

While he is still at the laptop, list the pieces of work, and run `treadmill stream list` on the server.
For each piece, use a fitting open stream; otherwise ask him for its name, with no default, as orchestrate's Streams section says.
Then, in a server script, point the stream at the piece's brief section, which also opens a new one:

```sh
treadmill stream open <project> '<name>' 'Handover: prep from ~/.claude/orchestrate/BRIEF-<date>.md, section "<title>"'
```

`<project>` is a key of the projects in the runner's `scaffolds.json`; the name is at most 60 characters and the move at most 200.
Open the streams before the server Orchestrator starts: an open stream with nothing running and work left is the Shepard's to prep, so no piece is lost or invisible if that session dies.
A piece whose project is not in the registry cannot be a stream; it goes to the brief as a piece the server Orchestrator does directly.

In a server script, record each answer he gave to an open need in this conversation, verbatim, with any `Settled with him: ...` line:

```sh
treadmill need answer <slug> - <<'ANSWER'
<his words>
ANSWER
```

## 3. Copy laptop-only inputs

Find each file the remaining work needs that exists only on this laptop: untracked or unpushed files, downloads, attachments he dropped into a repo.
Copy each to the same path on the server: `ssh server.tail334649.ts.net mkdir -p <dir>`, then `scp <path> server.tail334649.ts.net:<path>`.
Check it arrived with `ssh server.tail334649.ts.net ls -l <path>`.

## 4. Write one brief

Write `~/.claude/orchestrate/BRIEF-<YYYY-MM-DD>.md` (add `-2` if that name is taken on the server) and copy it to the same path on the server.
The server Orchestrator knows only the brief, so it carries everything and never your guess at an answer:

- **Start:** you are Reevu's Orchestrator on the server, and he has closed his laptop; each section below is one piece of work, to prep, stage and launch into its stream.
- **Standing rules:** the lines from his files and from this conversation that bind the work (environments, channels, who may see what, commit rules).
- **Per piece:** its stream (project and name); Reevu's words, verbatim; what he approved, quoted; done so far (commits, branches, paths); left, as steps; and the standing rules that bind it, which go into its task with its section.

## 5. Start the server Orchestrator

Fill in the tab name (unique, such as `handover-<MMDD>`) and the brief's path, then run on the server:

```sh
ssh server.tail334649.ts.net zsh -l <<'EOF'
name=handover-<MMDD>
pane=$(herdr tab create --cwd ~/github/gallopify-playground --label "$name" --no-focus | jq -r .result.root_pane.pane_id)
herdr agent start "$name" --kind claude --pane "$pane"
herdr agent prompt "$name" "$(cat <<'PROMPT'
Run as /orchestrate: you are Reevu's Orchestrator on the server, and he has closed his laptop.
Read ~/.claude/orchestrate/BRIEF-<date>.md; each piece of work in it has its own section and its own open stream.
Reevu ran /to-server, which is his word, in this conversation, to prep each piece and launch it: the delegated launch of treadmill-prep's step 10.
For each piece, have a subagent prep a task with treadmill-prep that carries its brief section verbatim, stage it into its stream with `treadmill stage <slug> "<stream>"`, and launch it with `treadmill launch <slug>`.
`treadmill` is the runner copy the shepard skill names, not the treadmill checkout.
Each prep uses its own clone of the tasks repo, never the shared ~/github/gallopify-playground/treadmill-tasks.
Independent pieces may be prepped in parallel by subagents; pieces that depend on each other are one wave in one agent, linted in one call so data-after-task resolves.
A piece that needs only Reevu's answer becomes a need: `treadmill need put <slug> <file>`, shaped as the shepard skill says.
A piece prep cannot shape into a task, do directly, through a subagent.
If prep or launch fails, write a need naming the draft's path.
End when every piece is launched, a need, or done.
PROMPT
)" --wait --until working --until blocked --timeout 30000
herdr agent read "$name"
EOF
```

`--wait --until working --until blocked` returns once the agent has taken the prompt, as Treadmill's own starts do; a bare `--wait` would hold the laptop until the whole handover settles.
Read the output and confirm the agent has started on the brief.

## 6. Confirm the laptop is idle, then tell him

Check that nothing still works on the laptop: no subagent running, no background shell, and `herdr agent list` shows no agent working.
Then tell him, in a few lines: each piece's stream, the server Orchestrator's herdr tab name and the brief's path, what was copied, and that it is safe to close the laptop.
