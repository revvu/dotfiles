# dotfiles

My Mac setup, managed with nix-darwin and home-manager.
One repo, one command, and a fresh Mac ends up configured the same way every time.

This is a fork of [Kun Chen's dotfiles](https://github.com/kunchenguid/dotfiles) ([walkthrough video](https://youtu.be/5N-okeDdIuI)).
The structure is his; read his README for the full design rationale.

## How this fork differs

- **Dev toolchain from nix, not Homebrew.**
  Node LTS, `gh`, `pnpm`, and `uv` are nix packages, so the activation scripts that need them can never hit a bootstrap-ordering gap.
  `no-mistakes`, `treehouse`, and `cursor-agent` update themselves, so they are never pinned: activation installs each one only if it is missing.
  npm-only CLIs (`npmGlobals` in `home.nix`) install into `~/.npm-global`; PyPI-only CLIs (`uvTools`) install as `uv tool` shims in `~/.local/bin`.
  Both install only what's missing, so a steady-state switch does no network work.
- **Helix instead of Neovim.**
  Two TOML files replace the Lua config and lazy.nvim plugin bootstrap; LSP, pickers, and themes ship built in.
  Same rose-pine moon look, transparent background, italics off (theme override in `home/.config/helix/themes/`).
- **Browsers.**
  Brave for personal use; Chrome installed only as an automation target (`chrome-devtools-axi` launches it isolated and headless).
- **More tools.**
  `doppler` (secrets), `no-mistakes` (AI-driven pre-PR gate), Codex (its second-agent reviewer), OpenSuperWhisper (local dictation, from the `my-monkeys` tap).
- **One agent policy file.**
  `home/global-agents.md` is symlinked to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.pi/agent/AGENTS.md`, so Claude, Codex, and Pi share one set of instructions.
  Claude's status line script is tracked too; its `settings.json` is seeded once from `settings.seed.json` and then owned by the app.
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

`homebrew.onActivation.cleanup = "none"`: applying never removes anything, so brew packages or casks not declared in `configuration.nix` stay installed.

## Daily use

Edit the config files in place, then apply:

```sh
./rebuild.sh
```

Files under `home/` (Helix, WezTerm, herdr's `config.toml`, Claude's status line, the shared agent policy) are symlinked into place with `mkOutOfStoreSymlink`, so editing them here edits the live config — no rebuild needed.
Only herdr's `config.toml` is linked; its runtime files stay outside the repo.
Rebuild only for changes to package lists or system defaults.

Validate without applying:

```sh
nix flake check --no-build
nix build .#darwinConfigurations.mac.system --dry-run
```

## Repo tour

- `flake.nix` - entry point; wires nixpkgs, nix-darwin, home-manager, nix-homebrew, and declares the `mac` machine.
- `configuration.nix` - system level: macOS defaults, Homebrew.
- `home.nix` - user level: packages, shell, prompt, activation scripts, symlinks.
- `home/` - the actual config files that get symlinked into place.

## License

MIT No Attribution, same as upstream.
See `LICENSE`.
