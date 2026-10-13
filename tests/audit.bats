#!/usr/bin/env bats
# Freezes bin/audit and bin/audit-page: every live input is a fixture through
# the AUDIT_* overrides the scripts document. The fixture set under
# tests/fixtures/audit describes a machine with no-mistakes and claude-swap
# behind releases older than four weeks (no-mistakes with breaking-change
# notes), the codex cask and six npm globals behind, and a policy with one
# path that resolves and one that does not.

setup() {
  BIN="$BATS_TEST_DIRNAME/../bin"
  FX="$BATS_TEST_TMPDIR/fx"
  cp -R "$BATS_TEST_DIRNAME/fixtures/audit" "$FX"
  mkdir -p "$FX/home/inbox"
  export AUDIT_FIXTURES="$FX" AUDIT_POLICY="$FX/policy.md" AUDIT_HOME="$FX/home"
  export AUDIT_NOW=1793534400 # 2026-11-01, so the Sep 26 and Sep 2 releases are more than four weeks old

  # The inbox: a clone of a bare repo, so the push is real.
  git init -q --bare "$BATS_TEST_TMPDIR/bare"
  git clone -q "$BATS_TEST_TMPDIR/bare" "$BATS_TEST_TMPDIR/inbox" 2>/dev/null
  INBOX="$BATS_TEST_TMPDIR/inbox"
  cat >"$INBOX/README.md" <<'MD'
# Inbox

| Doc | What it is | Next step |
|---|---|---|
| `drift/drift-2026-10-04.html` | an older audit | gone next week |
| `other.html` | some page | keep |

## Known issue

Not a table row.
MD
  git -C "$INBOX" add README.md
  git -C "$INBOX" -c user.name=t -c user.email=t@t commit -qm init
  git -C "$INBOX" push -q 2>/dev/null
  git -C "$INBOX" config user.name t
  git -C "$INBOX" config user.email t@t

  printf '#!/bin/sh\necho "Update no-mistakes first: its notes say breaking."\necho\necho "The rest can wait."\n' >"$BATS_TEST_TMPDIR/claude"
  chmod +x "$BATS_TEST_TMPDIR/claude"
  printf '#!/bin/sh\nsleep 5\necho late\n' >"$BATS_TEST_TMPDIR/slow-claude"
  chmod +x "$BATS_TEST_TMPDIR/slow-claude"
  printf '.k{color:red}\n' >"$BATS_TEST_TMPDIR/skin.css"
  export AUDIT_INBOX="$INBOX" AUDIT_CLAUDE="$BATS_TEST_TMPDIR/claude" AUDIT_SKIN="$BATS_TEST_TMPDIR/skin.css"
}

# --- bin/audit ----------------------------------------------------------------

@test "audit: every source answers, the JSON is complete, exit 0" {
  run "$BIN/audit"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.errors == []'
  echo "$output" | jq -e '.doctor == {status: 0, output: "clean: everything on this machine is declared or exempt"}'
  echo "$output" | jq -e '.versions | length == 12'
  echo "$output" | jq -e '.versions[] | select(.name == "no-mistakes") | .installed == "v1.80.0" and .latest == "v1.84.0" and .released == "2026-09-26T08:31:52Z" and (.notes | test("BREAKING")) and .update == "no-mistakes update"'
  echo "$output" | jq -e '.versions[] | select(.name == "cursor-agent") | .installed == "2026.09.15-d2fe57e" and .latest == null'
  echo "$output" | jq -e '.versions[] | select(.name == "claude-swap") | .installed == "0.25.0" and .latest == "0.26.0" and .released == "2026-09-02T18:29:37Z"'
  echo "$output" | jq -e '.versions[] | select(.name == "codex") | .installed == "0.154.0" and .latest == "0.162.1" and .update == "brew upgrade --cask codex"'
  echo "$output" | jq -e '.versions[] | select(.name == "lavish-axi") | .installed == "0.1.63" and .latest == "0.1.87"'
  echo "$output" | jq -e '.forks == [{name: "dotfiles", fork: "revvu/dotfiles", upstream: "kunchenguid/dotfiles", behind: 9, ahead: 29, merge_base: "2026-07-24T01:03:28Z"}, {name: "firstmate", fork: "revvu/firstmate", upstream: "kunchenguid/firstmate", behind: 344, ahead: 17, merge_base: "2026-09-07T19:41:14Z"}]'
  echo "$output" | jq -e '.policy.refs == [{ref: "~/gone/", kind: "path", ok: false}, {ref: "~/inbox/", kind: "path", ok: true}]'
  echo "$output" | jq -e '.date == "2026-11-01"'
}

@test "audit: a source that does not answer leaves nulls, an errors line and exit 1" {
  rm "$FX/nm-release" "$FX/compare-firstmate"
  run "$BIN/audit"
  [ "$status" -eq 1 ]
  echo "$output" | jq -e '.errors | length == 2'
  echo "$output" | jq -e '.versions[] | select(.name == "no-mistakes") | .installed == "v1.80.0" and .latest == null and .notes == null'
  echo "$output" | jq -e '.forks[] | select(.name == "firstmate") | .behind == null'
  echo "$output" | jq -e '.versions | length == 12'
}

@test "audit: the doctor's exit code is carried, not interpreted" {
  printf 'brews\tstray\nunowned: 1\n' >"$FX/doctor"; printf '1\n' >"$FX/doctor.status"
  run "$BIN/audit"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.doctor.status == 1 and (.doctor.output | test("stray"))'
}

@test "audit: failed npm requests leave every npm latest unknown" {
  for failure in missing empty error invalid status; do
    cp "$BATS_TEST_DIRNAME/fixtures/audit/npm-outdated" "$FX/npm-outdated"
    printf '0\n' >"$FX/npm-outdated.status"
    case "$failure" in
      missing) rm "$FX/npm-outdated" ;;
      empty) : >"$FX/npm-outdated" ;;
      error) printf '{"error":{"code":"E401"}}\n' >"$FX/npm-outdated" ;;
      invalid) printf 'not JSON\n' >"$FX/npm-outdated" ;;
      status) printf '2\n' >"$FX/npm-outdated.status" ;;
    esac
    run "$BIN/audit"
    [ "$status" -eq 1 ]
    echo "$output" | jq -e '[.errors[] | select(startswith("npm-outdated:"))] | length == 1'
    echo "$output" | jq -e '[.versions[] | select(.kind == "npm")] | length == 6 and all(.latest == null and .installed != null)'
  done
}

@test "audit: npm exit 1 with outdated results succeeds" {
  printf '1\n' >"$FX/npm-outdated.status"
  run "$BIN/audit"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.errors == []'
  echo "$output" | jq -e '.versions[] | select(.name == "lavish-axi") | .latest == "0.1.87"'
}

@test "audit: an empty npm result object means installed versions are current" {
  printf '{}\n' >"$FX/npm-outdated"
  run "$BIN/audit"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '[.versions[] | select(.kind == "npm")] | length == 6 and all(.latest == .installed)'
}

@test "audit-page: failed npm requests render no feed for every npm row" {
  printf '{"error":{"code":"E401"}}\n' >"$FX/npm-outdated"
  run "$BIN/audit-page"
  [ "$status" -eq 0 ]
  page | grep -q 'npm-outdated:'
  [ "$(page | grep -o '>no feed<' | wc -l | tr -d ' ')" -eq 14 ]
  ! page | grep -q 'npm install -g'
}

@test "audit-page: both GitHub releases retain flags beyond 4000 characters" {
  for source in nm-release th-release; do
    jq '.body = (("x" * 4100) + " SECURITY")' "$FX/$source" >"$FX/release.json"
    mv "$FX/release.json" "$FX/$source"
  done
  "$BIN/audit" >"$BATS_TEST_TMPDIR/audit.json"
  jq -e '[.versions[] | select(.kind == "github")] | all(.notes | endswith(" SECURITY"))' "$BATS_TEST_TMPDIR/audit.json"
  run "$BIN/audit-page" "$BATS_TEST_TMPDIR/audit.json"
  [ "$status" -eq 0 ]
  [ "$(page | grep -c 'notes: breaking or security')" -eq 2 ]
  grep -q '2 with breaking or security notes' "$INBOX/README.md"
}

# --- bin/audit-page -----------------------------------------------------------

page() { cat "$INBOX/drift/drift-2026-11-01.html"; }

@test "audit-page: classifies every row and lists the update lines" {
  run "$BIN/audit-page"
  [ "$status" -eq 0 ]
  page | grep -q '<title>Drift audit 2026-11-01</title>'
  page | grep -q '\.k{color:red}'                      # the skin is inlined
  page | grep -q 'data-theme="gallopify"'
  [ "$(page | grep -c '>overdue<')" -eq 2 ]            # no-mistakes, claude-swap
  [ "$(page | grep -c 'badge-warning">behind<')" -eq 7 ]             # codex and six npm globals
  [ "$(page | grep -c '>current<')" -eq 2 ]            # treehouse, claude-code@latest
  [ "$(page | grep -o '>no feed<' | wc -l | tr -d ' ')" -eq 2 ] # cursor-agent's latest cell and its badge, one row
  [ "$(page | grep -c 'notes: breaking or security')" -eq 1 ]
  page | grep -q '<div class="n">9<span class="text-base muted"> / 12</span></div>'
  page | grep -q 'no-mistakes update'
  page | grep -q 'cswap upgrade'
  page | grep -q 'brew upgrade --cask codex'
  page | grep -q 'npm install -g lavish-axi@latest'
  ! page | grep -q 'treehouse update'
  page | grep -q '>resolves<'
  page | grep -q '>missing<'
  page | grep -q '<p>Update no-mistakes first: its notes say breaking.</p>'
  page | grep -q '<p>The rest can wait.</p>'
}

@test "audit-page: takes a JSON file, escapes it, and still renders when sources were missing" {
  rm "$FX/nm-release"
  "$BIN/audit" >"$BATS_TEST_TMPDIR/audit.json" || true
  run "$BIN/audit-page" "$BATS_TEST_TMPDIR/audit.json"
  [ "$status" -eq 0 ]
  page | grep -q 'Sources that did not answer'
  page | grep -q 'nm-release: no answer'
  page | grep -q '>no feed<'
}

@test "audit-page: pushes the page and replaces the older drift row in the README" {
  run "$BIN/audit-page"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^| `drift/drift-' "$INBOX/README.md")" -eq 1 ]
  grep -q '^| `drift/drift-2026-11-01.html` | Weekly drift audit from .*: 9 of 12 tools behind (2 more than four weeks, 1 with breaking or security notes), doctor clean, dotfiles 9, firstmate 344, commits behind upstream. | Run the update lines' "$INBOX/README.md"
  # The new row sits right after the last table row, before the prose.
  awk '/^\| `other.html`/ { getline; print }' "$INBOX/README.md" | grep -q '^| `drift/drift-2026-11-01.html`'
  git -C "$BATS_TEST_TMPDIR/bare" log --format=%s -1 | grep -q '^drift: weekly audit 2026-11-01 from '
  git -C "$BATS_TEST_TMPDIR/bare" ls-tree --name-only HEAD drift/ | grep -q 'drift-2026-11-01.html'
  git -C "$INBOX" status --porcelain | grep -q . && false || true
}

@test "audit-page: a rerun with nothing new makes no second commit" {
  run "$BIN/audit-page"
  [ "$status" -eq 0 ]
  run "$BIN/audit-page"
  [ "$status" -eq 0 ]
  [[ "$output" == *"nothing new to commit"* ]]
  [ "$(git -C "$BATS_TEST_TMPDIR/bare" rev-list --count HEAD)" -eq 2 ]
}

@test "audit-page: unchanged reruns retry publishing a commit left local" {
  printf '#!/bin/sh\nexit 1\n' >"$BATS_TEST_TMPDIR/bare/hooks/pre-receive"
  chmod +x "$BATS_TEST_TMPDIR/bare/hooks/pre-receive"
  run "$BIN/audit-page"
  [ "$status" -eq 1 ]
  audit_commit="$(git -C "$INBOX" rev-parse HEAD)"
  [ "$(git -C "$INBOX" rev-list --count HEAD)" -eq 2 ]
  [ "$(git -C "$BATS_TEST_TMPDIR/bare" rev-list --count HEAD)" -eq 1 ]
  run "$BIN/audit-page"
  [ "$status" -eq 1 ]
  [[ "$output" == *"nothing new to commit"* ]]
  [ "$(git -C "$INBOX" rev-parse HEAD)" = "$audit_commit" ]
  [ "$(git -C "$BATS_TEST_TMPDIR/bare" rev-list --count HEAD)" -eq 1 ]
  rm "$BATS_TEST_TMPDIR/bare/hooks/pre-receive"
  run "$BIN/audit-page"
  [ "$status" -eq 0 ]
  [[ "$output" == *"nothing new to commit"* ]]
  [ "$(git -C "$INBOX" rev-parse HEAD)" = "$audit_commit" ]
  [ "$(git -C "$BATS_TEST_TMPDIR/bare" rev-parse HEAD)" = "$audit_commit" ]
}

@test "audit-page: unrelated staged drafts are excluded from publishing and reruns" {
  printf 'private draft\n' >"$INBOX/draft.md"
  git -C "$INBOX" add draft.md
  run "$BIN/audit-page"
  [ "$status" -eq 0 ]
  [ "$(git -C "$BATS_TEST_TMPDIR/bare" diff-tree --no-commit-id --name-only -r HEAD)" = $'README.md\ndrift/drift-2026-11-01.html' ]
  [ -z "$(git -C "$BATS_TEST_TMPDIR/bare" ls-tree --name-only HEAD draft.md)" ]
  [ "$(git -C "$INBOX" diff --cached --name-only)" = draft.md ]
  run "$BIN/audit-page"
  [ "$status" -eq 0 ]
  [[ "$output" == *"nothing new to commit"* ]]
  [ "$(git -C "$BATS_TEST_TMPDIR/bare" rev-list --count HEAD)" -eq 2 ]
  [ "$(git -C "$INBOX" diff --cached --name-only)" = draft.md ]
}

@test "audit-page: uncommitted README edits prevent publishing and remain intact" {
  printf '\nPrivate README edit.\n' >>"$INBOX/README.md"
  cp "$INBOX/README.md" "$BATS_TEST_TMPDIR/expected-readme"
  for state in unstaged staged; do
    if [ "$state" = staged ]; then git -C "$INBOX" add README.md; fi
    before="$(git -C "$INBOX" status --porcelain)"
    run "$BIN/audit-page"
    [ "$status" -eq 1 ]
    [[ "$output" == *"inbox has local changes to README.md"* ]]
    cmp "$INBOX/README.md" "$BATS_TEST_TMPDIR/expected-readme"
    [ ! -e "$INBOX/drift" ]
    [ "$(git -C "$INBOX" status --porcelain)" = "$before" ]
    [ "$(git -C "$INBOX" rev-list --count HEAD)" -eq 1 ]
    [ "$(git -C "$BATS_TEST_TMPDIR/bare" rev-list --count HEAD)" -eq 1 ]
  done
}

@test "audit-page: uncommitted audit pages are preserved without publishing" {
  mkdir -p "$INBOX/drift"
  printf 'Private audit draft.\n' >"$INBOX/drift/drift-2026-11-01.html"
  cp "$INBOX/README.md" "$BATS_TEST_TMPDIR/expected-readme"
  for state in untracked staged; do
    if [ "$state" = staged ]; then git -C "$INBOX" add drift/drift-2026-11-01.html; fi
    before="$(git -C "$INBOX" status --porcelain)"
    run "$BIN/audit-page"
    [ "$status" -eq 1 ]
    [[ "$output" == *"inbox has local changes to drift/drift-2026-11-01.html"* ]]
    [ "$(page)" = 'Private audit draft.' ]
    cmp "$INBOX/README.md" "$BATS_TEST_TMPDIR/expected-readme"
    [ "$(git -C "$INBOX" status --porcelain)" = "$before" ]
    [ "$(git -C "$INBOX" rev-list --count HEAD)" -eq 1 ]
    [ "$(git -C "$BATS_TEST_TMPDIR/bare" rev-list --count HEAD)" -eq 1 ]
  done
}

@test "audit-page: Claude timing out ships the page without the judgement" {
  AUDIT_CLAUDE="$BATS_TEST_TMPDIR/slow-claude" AUDIT_CLAUDE_TIMEOUT=1 run "$BIN/audit-page"
  [ "$status" -eq 0 ]
  [[ "$output" == *"judgement missing"* ]]
  page | grep -q 'The judgement is missing this week: .*did not answer within 1 s'
  page | grep -q 'no-mistakes update'
}

@test "audit-page --scheduled: builds nothing on another host" {
  AUDIT_HOST=some-other-mac run "$BIN/audit-page" --scheduled
  [ "$status" -eq 0 ]
  [[ "$output" == *"skipped"* ]]
  [ ! -e "$INBOX/drift" ]
  [ "$(git -C "$BATS_TEST_TMPDIR/bare" rev-list --count HEAD)" -eq 1 ]
}

@test "audit-page: refuses an inbox that is not a checkout" {
  AUDIT_INBOX="$BATS_TEST_TMPDIR/nowhere" run "$BIN/audit-page"
  [ "$status" -eq 2 ]
}
