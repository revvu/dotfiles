#!/usr/bin/env bats
# Freezes bin/doctor: every live input is replaced by a fixture through the
# DOCTOR_* overrides the script documents.

setup() {
  DOCTOR="$BATS_TEST_DIRNAME/../bin/doctor"
  FX="$BATS_TEST_TMPDIR/fx"
  mkdir -p "$FX/npm-bin" "$FX/local-bin"

  cat >"$FX/declared.json" <<'EOF'
{"npm":["gh-axi","pi"],"uv":["claude-swap"],"localBin":["no-mistakes","treehouse"],
 "exempt":{"brews":[],"casks":["wezterm"],"taps":["my-monkeys/tap"]}}
EOF
  cat >"$FX/Brewfile" <<'EOF'
tap "supabase/tap"
brew "doppler"
brew "supabase/tap/supabase"
cask "claude-code@latest"
EOF
  printf 'doppler\nsupabase/tap/supabase\n' >"$FX/leaves"
  printf 'claude-code@latest\nwezterm\n' >"$FX/casks"
  printf 'supabase/tap\nmy-monkeys/tap\n' >"$FX/taps"
  printf 'claude-swap\n' >"$FX/uv"
  touch "$FX/npm-bin/gh-axi" "$FX/npm-bin/pi"
  touch "$FX/local-bin/no-mistakes" "$FX/local-bin/treehouse" "$FX/local-bin/claude-swap"

  git init -q "$FX/repo"
  echo x >"$FX/repo/tracked"
  git -C "$FX/repo" add tracked
  git -C "$FX/repo" -c user.name=t -c user.email=t@t commit -qm init

  export DOCTOR_DECLARED="$FX/declared.json" DOCTOR_BREWFILE="$FX/Brewfile"
  export DOCTOR_BREW_LEAVES="$FX/leaves" DOCTOR_BREW_CASKS="$FX/casks" DOCTOR_BREW_TAPS="$FX/taps"
  export DOCTOR_UV_TOOLS="$FX/uv" DOCTOR_NPM_BIN="$FX/npm-bin" DOCTOR_LOCAL_BIN="$FX/local-bin"
  export DOCTOR_REPO="$FX/repo"
}

@test "clean machine: exit 0 and one summary line" {
  run "$DOCTOR"
  [ "$status" -eq 0 ]
  [ "$output" = "clean: everything on this machine is declared or exempt" ]
}

@test "one stray per class: each is named, exit 1" {
  printf 'stray-formula\n' >>"$FX/leaves"
  printf 'stray-cask\n' >>"$FX/casks"
  printf 'stray/tap\n' >>"$FX/taps"
  printf 'stray-uv\n' >>"$FX/uv"
  touch "$FX/npm-bin/stray-npm" "$FX/local-bin/stray-bin"
  echo y >"$FX/repo/tracked"
  run "$DOCTOR"
  [ "$status" -eq 1 ]
  expected="$(printf 'brew formula\tstray-formula\nbrew cask\tstray-cask\nbrew tap\tstray/tap\nnpm global\tstray-npm\nuv tool\tstray-uv\nlocal bin\tstray-bin\nchanged tracked file\ttracked\n7 unowned item(s)')"
  [ "$output" = "$expected" ]
}

@test "exempt casks and taps are not reported" {
  # wezterm and my-monkeys/tap are live but only exempt, never in the Brewfile
  run "$DOCTOR"
  [ "$status" -eq 0 ]
}

@test "tap-qualified names match their short form" {
  # the Brewfile says supabase/tap/supabase; brew leaves may print either form
  printf 'doppler\nsupabase\n' >"$FX/leaves"
  run "$DOCTOR"
  [ "$status" -eq 0 ]
}

@test "missing declared.json: exit 2 with a hint" {
  export DOCTOR_DECLARED="$FX/nope.json"
  run "$DOCTOR"
  [ "$status" -eq 2 ]
  [[ "$output" == *"rebuild.sh"* ]]
}

@test "--help prints the header" {
  run "$DOCTOR" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Reports everything this machine has"* ]]
}
