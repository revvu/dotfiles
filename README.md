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
- herdr's server is a launchd user agent (`launchd.agents.herdr` in `home.nix`), started at login inside the GUI session so the agents it spawns can read the login keychain, which macOS unlocks per session and never for ssh. It restarts after a crash; `herdr server stop` keeps it stopped until the next login. launchd's own output lands in `~/Library/Logs/herdr-server.log`.
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

The server is a lidded MacBook with FileVault on, so every reboot stops at the FileVault prompt, which macOS draws on the built-in panel only (the server's is broken).
At its keyboard: press Return, type the login password, press Return.
FileVault then logs the user in, and that login is all the machine needs: the launchd agents start and the keychain is unlocked.
`sudo fdesetup authrestart` only skips the disk unlock and leaves the Mac at the login window, where the GUI session does not exist (no agents, no keychain, no Tailscale app); sshd does run there, so reach it by its LAN name rather than the tailnet name.
Unattended reboots would take the standard headless-Mac setup, FileVault off plus automatic login for the user, which is what headless Mac mini guides and macOS CI-runner setups do; deferred on purpose in Oct 2026, reboots are handled at the keyboard.

## Repo tour

- `flake.nix` - entry point; wires nixpkgs, nix-darwin, home-manager, nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - system level: macOS defaults, Homebrew, Codex's base config.
- `home.nix` - user level: packages, shell, prompt, activation scripts, symlinks, the declared sets the doctor reads.
- `home/` - the actual config files that get symlinked into place.
- `bin/doctor` - reports unowned items; `tests/doctor.bats` freezes its behaviour.
- `.github/workflows/build.yml` - every PR and push to main runs the flake check, the full system build, shellcheck and the doctor's tests on a macOS runner.

## License

MIT No Attribution, same as upstream.
See `LICENSE`.
