#!/usr/bin/env bats
# Freezes bin/lavish-review-gate, the PreToolUse hook that refuses to publish
# a Lavish page without its Reader review log. Each test feeds the hook the
# JSON Claude Code sends and asserts on the decision: a deny naming the
# lavish-page skill, or no output (allow). The inbox is a throwaway git repo
# through LAVISH_REVIEW_INBOX.

setup() {
  GATE="$BATS_TEST_DIRNAME/../bin/lavish-review-gate"
  INBOX="$BATS_TEST_TMPDIR/inbox"
  export LAVISH_REVIEW_INBOX="$INBOX"
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

@test "a command that publishes nothing passes without output" {
  run call "ls -la && echo done"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
