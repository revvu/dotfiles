# Project notes for agents

Deliberate decisions in this repo - do NOT silently revert them:

- `homebrew.onActivation.cleanup = "none"` in `configuration.nix` is intentional: applying never removes an installed item. Undeclared Homebrew items are reported, not deleted. Do not tighten it back to `uninstall` or `zap`, which once threatened to delete in-use tools and app data.
- This repo defines the environment only: tools, shell, prompt, agent policy, macOS defaults. GUI apps and app-owned state (Claude's settings, herdr's runtime files) live outside it and are listed in the README, not declared. `bin/doctor` reports anything the machine has that the repo does not own.
- `launchd.agents.herdr` in `home.nix` exists because the login keychain (Claude Code, Doppler and cursor-agent credentials) is unlocked only in the GUI session: agents on a headless Mac must descend from a launchd job in that session, never from an ssh-started process. Do not replace it with a shell-started server or a per-session `security unlock-keychain`.
- Never commit `.no-mistakes/` validation evidence to this public repo. `.no-mistakes/` is gitignored; if a validation pipeline stages evidence into a branch, drop it before merging.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
