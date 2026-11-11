#!/usr/bin/env bats
# Freezes bin/lavish-review-gate, the PreToolUse hook that refuses to publish
# a Lavish page without its Reader review log. Each test feeds the hook the
# JSON Claude Code sends and asserts on the decision: a deny naming the
# lavish-page skill, or no output (allow). The inbox and the treadmill-tasks
# clone are throwaway git repos through LAVISH_REVIEW_INBOX and
# LAVISH_REVIEW_TASKS.

setup() {
  GATE="$BATS_TEST_DIRNAME/../bin/lavish-review-gate"
  INBOX="$BATS_TEST_TMPDIR/inbox"
  export LAVISH_REVIEW_INBOX="$INBOX"
  TASKS="$BATS_TEST_TMPDIR/treadmill-tasks"
  export LAVISH_REVIEW_TASKS="$TASKS"
  git init -q "$TASKS"
  git -C "$TASKS" config user.name t
  git -C "$TASKS" config user.email t@t
  mkdir -p "$TASKS/backlog" "$TASKS/launch"
  git -C "$TASKS" commit -q --allow-empty -m init
  git init -q "$INBOX"
  git -C "$INBOX" config user.name t
  git -C "$INBOX" config user.email t@t
  printf '# Inbox\n' >"$INBOX/README.md"
  git -C "$INBOX" add README.md
  git -C "$INBOX" commit -qm init

  mkdir -p "$INBOX/topic"
  cat >"$INBOX/topic/reviewed.html" <<'HTML'
<html><body><h1>A page</h1>
<details id="reader-review">
<summary>Reader review · 12 items, 7 claims · Nov 5</summary>
<p>Both lists answered.</p>
</details>
</body></html>
HTML
  cat >"$INBOX/topic/unreviewed.html" <<'HTML'
<html><body><h1>A page</h1>
<details><summary>Log</summary><p>No review.</p></details>
</body></html>
HTML
}

# The hook's stdin for a Bash call: the command, run from a cwd.
call() {
  jq -n --arg c "$1" --arg d "${2:-$INBOX}" \
    '{hook_event_name: "PreToolUse", tool_name: "Bash", tool_input: {command: $c}, cwd: $d}' |
    "$GATE"
}

denied() {
  echo "$output" | jq -e '.hookSpecificOutput.hookEventName == "PreToolUse" and .hookSpecificOutput.permissionDecision == "deny"'
  echo "$output" | jq -e '.hookSpecificOutput.permissionDecisionReason | test("lavish-page")'
}

@test "lavish-axi: a page with the Reader review log passes" {
  run call "lavish-axi topic/reviewed.html"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "lavish-axi: a page without the log is refused, naming the skill" {
  run call "lavish-axi topic/unreviewed.html"
  [ "$status" -eq 0 ]
  denied
  echo "$output" | jq -e '.hookSpecificOutput.permissionDecisionReason | test("unreviewed.html")'
}

@test "lavish-axi share, from another directory through cd, is refused too" {
  run call "cd $INBOX/topic && lavish-axi share unreviewed.html --private" "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]
  denied
}

@test "lavish-axi poll and reply continue a session and pass" {
  run call "lavish-axi poll topic/unreviewed.html"
  [ -z "$output" ]
  run call "lavish-axi reply topic/unreviewed.html --agent-reply done"
  [ -z "$output" ]
}

@test "git commit in the inbox: a staged new page with the log passes" {
  git -C "$INBOX" add topic/reviewed.html
  run call "git commit -m page"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "git commit in the inbox: a staged new page without the log is refused" {
  git -C "$INBOX" add topic/unreviewed.html
  run call "git commit -m page"
  [ "$status" -eq 0 ]
  denied
}

@test "git add -A && git commit in the inbox sees the new pages it is about to stage" {
  run call "git -C $INBOX add -A && git -C $INBOX commit -m pages" "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]
  denied
  echo "$output" | jq -e '.hookSpecificOutput.permissionDecisionReason | test("unreviewed.html") and (test("/reviewed.html") | not)'
}

@test "git commit naming only the reviewed page passes" {
  run call "git add topic/reviewed.html README.md && git commit -m page"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "git add naming a new page without the log, then commit, is refused" {
  run call "git add topic/unreviewed.html && git commit -m page"
  [ "$status" -eq 0 ]
  denied
}

@test "git commit modifying an old page without the log passes" {
  git -C "$INBOX" add topic/unreviewed.html
  git -C "$INBOX" commit -qm "an old page, written before the review"
  printf '<p>A log line.</p>\n' >>"$INBOX/topic/unreviewed.html"
  run call "git add topic/unreviewed.html && git commit -m 'log line'"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  run call "git commit -am 'log line'"
  [ -z "$output" ]
  run call "git add -A && git commit -m 'log line'"
  [ -z "$output" ]
}

@test "git commit outside the inbox passes, whatever it stages" {
  OTHER="$BATS_TEST_TMPDIR/other"
  git init -q "$OTHER"
  cp "$INBOX/topic/unreviewed.html" "$OTHER/"
  git -C "$OTHER" add unreviewed.html
  run call "git commit -m page" "$OTHER"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "treadmill note: a page with the log passes, one without is refused" {
  run call "uv run --no-project python \$RUNNER/bin/treadmill note schwab topic/reviewed.html"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  run call "uv run --no-project python \$RUNNER/bin/treadmill note schwab topic/unreviewed.html"
  [ "$status" -eq 0 ]
  denied
  echo "$output" | jq -e '.hookSpecificOutput.permissionDecisionReason | test("unreviewed.html")'
}

@test "treadmill commands other than note pass" {
  run call "treadmill stage unreviewed Ledger && treadmill lint topic/unreviewed.html"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "git commit in the treadmill-tasks clone: a new task without the log is refused" {
  cp "$INBOX/topic/unreviewed.html" "$TASKS/backlog/task.html"
  run call "git -C $TASKS add backlog/task.html && git -C $TASKS commit -m 'prep: task' -- backlog/task.html" "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]
  denied
  echo "$output" | jq -e '.hookSpecificOutput.permissionDecisionReason | test("backlog/task.html")'
}

@test "git commit in the treadmill-tasks clone: a new task with the log passes" {
  cp "$INBOX/topic/reviewed.html" "$TASKS/backlog/task.html"
  run call "git -C $TASKS add backlog/task.html && git -C $TASKS commit -m 'prep: task' -- backlog/task.html" "$BATS_TEST_TMPDIR"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "git commit moving an old task without the log passes" {
  cp "$INBOX/topic/unreviewed.html" "$TASKS/backlog/task.html"
  git -C "$TASKS" add backlog/task.html
  git -C "$TASKS" commit -qm "an old task, written before the review"
  git -C "$TASKS" mv backlog/task.html launch/task.html
  run call "git commit -m 'launch: task'" "$TASKS"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "a command that publishes nothing passes without output" {
  run call "ls -la && echo done"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
