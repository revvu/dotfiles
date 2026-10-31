# dotfiles

My Mac environment, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up with the same tools, shell, prompt, agent policy and macOS defaults every time.

This is a fork of [Kun Chen's dotfiles](https://github.com/kunchenguid/dotfiles) ([walkthrough video](https://youtu.be/5N-okeDdIuI)).
The structure is his; read his README for the full design rationale.

## Scope

The repo defines the environment and nothing else.

- Everything it declares has exactly one owner: a nix package, a Homebrew formula or cask, an npm global, a uv tool, or a self-updating tool that activation installs only when it is missing.
- GUI apps are not declared. They are installed by hand once and listed below.
- App-owned state stays out of the repo. Claude Code's `settings.json` is seeded once from `settings.seed.json` and then belongs to the app; herdr's sockets, logs and sessions live next to its linked `config.toml`.
- herdr's server is a launchd user agent (`launchd.agents.herdr` in `home.nix`), started at login inside the GUI session so the agents it spawns can read the login keychain, which macOS unlocks per session and never for ssh. It restarts after a crash; `herdr server stop` keeps it stopped until the next login. launchd's own output lands in `~/Library/Logs/herdr-server.log`. To use it from another machine, `ssh` in and run `herdr`, which attaches to this server. `herdr --remote <host>` and `herdr machine add <host>` (0.9.3) ask to restart it first; answer No, since the replacement would run from the ssh bridge, outside the GUI session, with the keychain locked.
- claude-swap's auto-switch runs the same way (`launchd.agents.cswap-auto`): every minute it checks the active Claude login and rotates to the account with most headroom at 90 percent of the 5h, 7d or Fable window. Its log is `~/Library/Logs/cswap-auto.log`; stop it for a session with `launchctl bootout gui/$(id -u)/org.nix-community.home.cswap-auto`.
- Applying never removes anything: `homebrew.onActivation.cleanup = "none"`.
  Anything the machine has that the repo does not own is reported by `bin/doctor`, not deleted.

## How this fork differs

- **Dev toolchain from nix, not Homebrew.**
  Node LTS, `gh`, `pnpm`, `uv`, `psql` and the rest are nix packages, so the activation scripts that need them never hit a bootstrap-ordering gap.
  npm-only CLIs (`npmGlobals` in `home.nix`) install into `~/.npm-global`; PyPI-only CLIs (`uvTools`) install as `uv tool` shims in `~/.local/bin`.
- **Self-updating tools are never pinned.**
  `no-mistakes`, `treehouse` and `cursor-agent` update themselves; activation installs each one only if it is missing, and updates are run by hand when a release is out.
- **Helix instead of Neovim.**
  Two TOML files replace the Lua config and lazy.nvim plugin bootstrap; LSP, pickers, and themes ship built in.
  Same rose-pine moon look, transparent background, italics off (theme override in `home/.config/helix/themes/`).
- **One agent policy file.**
  `home/global-agents.md` is symlinked to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.pi/agent/AGENTS.md`, so Claude, Codex, and Pi share one set of instructions.
  Codex also gets a system-level base config at `/etc/codex/config.toml`.
- **Small fixes.**
  `rebuild.sh` calls `darwin-rebuild` by absolute path (sudo's `secure_path` doesn't include nix-darwin's bin).
  Git identity is set declaratively.
  WezTerm renders DemiBold at 120 fps and dims inactive panes instead of unfocused windows.
  Upstream's pi `calm` extension and its tests are removed.

## Fresh-machine setup

```sh
git clone https://github.com/revvu/dotfiles.git
cd dotfiles
./bootstrap.sh
```

`bootstrap.sh` installs Determinate Nix, symlinks the repo to `~/.dotfiles`, checks the `user` in `flake.nix` against your macOS username, and runs the first `darwin-rebuild switch`.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

Files under `home/` (Helix, WezTerm, herdr's `config.toml`, Claude's status line, the shared agent policy) are symlinked into place with `mkOutOfStoreSymlink`, so editing them here edits the live config — no rebuild needed.
Rebuild only for changes to package lists or system defaults.

Validate without applying:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

See what the machine has that the repo does not declare:

```sh
bin/doctor
```

It reads the Brewfile the current system activates and the declared sets home-manager writes to `~/.config/doctor/declared.json`, prints every unowned brew formula, cask, tap, npm global, uv tool, `~/.local/bin` entry and app-changed tracked file, and exits 1 if there are any.
Its tests run with `bats tests`.

## GUI apps (installed by hand)

The repo declares the environment only. These are installed once, by hand, and update themselves or through `brew upgrade`:

- WezTerm: `brew install --cask wezterm` (its config is still tracked under `home/.config/wezterm`)
- Brave: `brew install --cask brave-browser`
- Google Chrome: `brew install --cask google-chrome` (automation target only: `chrome-devtools-axi` launches it isolated and headless)
- OpenSuperWhisper: `brew tap my-monkeys/tap && brew install --cask opensuperwhisper` (local dictation)
- Automic Vault: download from the vendor; it keeps its own `automic-vault/isotopes` tap

`bin/doctor` exempts these casks and taps; the exempt list lives next to the other declared sets in `home.nix`.

## Reboots on the server

The server is a lidded MacBook nobody sits at, so it runs the standard headless-Mac setup: FileVault off, automatic login for the user, sleep disabled (Oct 17, 2026; it replaced the FileVault-on setup of Oct 12, which stopped every reboot at a prompt drawn on the broken built-in panel).
Apple silicon keeps the volume hardware-encrypted either way; what FileVault added was the boot-time password gate.
Without it a boot lands in the user's GUI session on its own: the launchd agents start, the keychain is unlocked, the Tailscale app connects.
Measured twice on Oct 17: on the tailnet 50 s after the boot, no hands.

- Planned reboot: `ssh -t server 'sudo shutdown -r now'`, then wait a minute.
- Power loss: plug the charger in, then open and close the lid once.
  With the lid closed the Mac does not start on power alone (tested for 68 minutes; Apple silicon laptops boot on lid open, `BootPreference` is at its default), so the lid is the one touch.
  No display, keyboard or password.
- The switches: `sudo fdesetup disable`; `sudo sysadminctl -autologin set -userName <user> -password '<pw>'`, where the password is required (without it the command is a silent no-op); `sudo pmset -a disablesleep 1`.
  `bin/doctor` checks all three on the server and names any that drifted, which a macOS update can do.
- Verify: `ssh server 'fdesetup status; defaults read /Library/Preferences/com.apple.loginwindow autoLoginUser; pmset -g | grep SleepDisabled'` prints `FileVault is Off.`, the user, and `SleepDisabled 1`.
- Trade-off: anyone holding the laptop lands in the session, and the login password sits in `/etc/kcpassword` under a known weak obfuscation.
  Accepted for a Mac that stays in the house and holds nothing that is not also on GitHub.
- Rollback: `sudo sysadminctl -autologin off`, then `sudo fdesetup enable`; reboots stop at the FileVault prompt again.
- If a boot ever stops at the login window instead of the session, sshd still runs there: reach the Mac by its LAN name (the Tailscale app is not up), run the verify line, and flip whatever drifted.

## Weekly audit

Every Sunday at 21:10 the server runs `bin/audit-page --scheduled`: it gathers what the machine runs against what is released and pushes a page into the agent inbox, `drift/drift-<date>.html`, with its row in the inbox README.
Every run collects fresh facts with `bin/audit`; saved JSON is not accepted as input.
Each run that reaches publishing creates a commit, including reruns with identical output, then attempts to push.
See `bin/audit-page --help` for publishing preconditions, failure handling and overrides.
The page has what matters first, Claude's judgement of the week (what to update now, what can wait), then the facts: every tool against its latest release with its update line, the two forks against their upstreams, the doctor's report, and whether the global policy's paths and links still resolve.
The audit never installs, removes or updates tools; every update is a line on the page to run by hand.
The Scaffolds section is Treadmill's (`treadmill scaffolds audit`): one row per registry entry with the other machine's cell and the server's, one row for whether the two workspace `CLAUDE.md` copies differ, and the prune candidates; the other machine's cells come from its `drift/scaffolds-<host>.json` in the inbox.

```sh
bin/audit            # the facts as JSON, read-only
bin/audit-page       # the page, into the inbox, from this machine
bin/audit-page --help
```

The agent is declared for every machine and skips itself anywhere but the server (`AUDIT_HOST`, default `mac`), so a by-hand run elsewhere is the plain command.
It runs in the GUI session like herdr and cswap-auto, because `claude -p` reads the login keychain; a Sunday the server spends powered off is a Sunday without a page, and `~/Library/Logs/audit.log` says what happened.
Tests: `bats tests`, on the fixtures under `tests/fixtures/audit`.

## Repo tour

- `flake.nix` - entry point; wires nixpkgs, nix-darwin, home-manager, nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - system level: macOS defaults, Homebrew, Codex's base config.
- `home.nix` - user level: packages, shell, prompt, activation scripts, symlinks, the declared sets the doctor reads.
- `home/` - the actual config files that get symlinked into place.
- `bin/doctor` - reports unowned items; `tests/doctor.bats` freezes its behaviour.
- `bin/audit`, `bin/audit-page` - the weekly drift audit: facts as JSON, then the page pushed into the inbox; `tests/audit.bats` freezes both.
- `.github/workflows/build.yml` - every PR and push to main runs the flake check, the full system build, shellcheck and the bats tests on a macOS runner.

## License

MIT No Attribution, same as upstream.
See `LICENSE`.
