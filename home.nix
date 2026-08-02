{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  # CLIs that ship only on npm, so `brews` can't declare them. Same rule as
  # Homebrew: declared here, never installed ad-hoc. Keyed by the binary each
  # package provides, which is what the activation below tests for.
  npmGlobals = {
    "pi" = "@earendil-works/pi-coding-agent";  # Pi coding agent
    "gh-axi" = "gh-axi";
    "chrome-devtools-axi" = "chrome-devtools-axi";
    "lavish-axi" = "lavish-axi";
    "tasks-axi" = "tasks-axi";
    "quota-axi" = "quota-axi";
  };
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  # Installs anything in npmGlobals that isn't already present, so a steady-state
  # switch does no network work. Activation runs on a nix-only PATH with no awk
  # and no /usr/bin, so nvm.sh cannot be sourced here; read nvm's default-version
  # alias instead, which needs nothing beyond coreutils. No usable Node yet (a
  # first switch, before Homebrew has installed nvm) warns and skips rather than
  # failing the whole switch; the next ./rebuild.sh picks it up.
  home.activation.npmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    nodeBin=""
    if [ -r "$HOME/.nvm/alias/default" ]; then
      nodeBin="$HOME/.nvm/versions/node/v$(cat "$HOME/.nvm/alias/default")/bin"
    fi
    # Fallback for a default alias that points at another alias rather than a version.
    # Pure globbing: activation runs under `set -e -o pipefail`, where a pipeline
    # that finds nothing would abort the whole switch.
    if [ ! -x "$nodeBin/npm" ]; then
      for candidate in "$HOME"/.nvm/versions/node/*/bin; do
        if [ -x "$candidate/npm" ]; then nodeBin="$candidate"; fi
      done
    fi
    if [ ! -x "$nodeBin/npm" ]; then
      echo "npmGlobals: no nvm-managed npm found, skipping; re-run ./rebuild.sh once Node is installed" >&2
    else
      export PATH="$nodeBin:$PATH"
      ${lib.concatStringsSep "\n      " (lib.mapAttrsToList
        (bin: pkg: ''command -v ${bin} > /dev/null || npm install -g ${pkg}'')
        npmGlobals)}
    fi
  '';

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    # Login-shell env: brew, then nvm (node + the npm-global axi tools live under ~/.nvm).
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"
      export NVM_DIR="$HOME/.nvm"
      [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && . "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
      [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && . "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
    '';
    initContent = ''
      bindkey '^f' autosuggest-accept

      # uv tool shims and gallopify-internal binaries (no-mistakes, treehouse)
      export PATH="$HOME/.local/bin:$PATH"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
      publish-md = "${config.home.homeDirectory}/github/gallopify_playground/tools/markdown_publish/publish-md";
    };
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "revvu";
      email = "reevu.adakroy@gmail.com";
    };
    # gh serves credentials; the empty first entry resets the helper list so
    # the system osxkeychain helper can't hang headless pushes on a GUI prompt.
    settings.credential."https://github.com".helper = [ "" "!gh auth git-credential" ];
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";
  # settings.json's statusLine runs this by absolute path, so it has to land in
  # ~/.claude rather than only existing in the repo.
  home.file.".claude/statusline.py".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/statusline.py";

  # One global agent policy (home/global-agents.md — named distinctly from the
  # repo-root AGENTS.md, which holds project notes for agents editing this repo),
  # linked into each agent's own discovery location:
  # Claude reads ~/.claude/CLAUDE.md; Codex reads ~/.codex/AGENTS.md.
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/global-agents.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/global-agents.md";
}
