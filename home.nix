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
  # Python CLIs that ship only on PyPI, installed as isolated uv tools. Same
  # rule as Homebrew and npm: declared here, never installed ad-hoc. Keyed by
  # a binary each tool puts in ~/.local/bin, which is what the activation tests.
  uvTools = {
    "claude-swap" = "claude-swap";  # multi-account switcher for Claude Code
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
    helix     # editor; config is the edit-in-place symlink below
    nodejs    # current LTS; npm globals land in ~/.npm-global (prefix below)
    gh        # GitHub CLI (gh-axi and no-mistakes call into it)
    pnpm      # gallopify frontend package manager (no corepack packageManager pins)
    uv        # python tooling; the uvTools activation below installs its shims
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "hx";
  # The nix store is read-only, so `npm install -g` needs a writable prefix.
  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
    # uv tool shims and gallopify-internal binaries (no-mistakes, treehouse)
    "${config.home.homeDirectory}/.local/bin"
  ];

  # Installs anything in npmGlobals that isn't already present, so a steady-state
  # switch does no network work. Node is the nix package above, addressed by
  # store path because activation runs on a minimal PATH; the same switch that
  # runs this script installs it, so it's always available here.
  home.activation.npmGlobals = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="${pkgs.nodejs}/bin:$PATH"
    ${lib.concatStringsSep "\n    " (lib.mapAttrsToList
      (bin: pkg: ''[ -x "$HOME/.npm-global/bin/${bin}" ] || npm install -g ${pkg}'')
      npmGlobals)}
  '';

  # Same contract as npmGlobals: install only what's missing, so a steady-state
  # switch does no network work. uv is the nix package above, addressed by store
  # path because activation runs on a minimal PATH; the same switch that runs
  # this script installs it, so it's always available here. The shims land in
  # ~/.local/bin, which home.sessionPath puts on PATH.
  home.activation.uvTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.concatStringsSep "\n    " (lib.mapAttrsToList
      (bin: pkg: ''[ -x "$HOME/.local/bin/${bin}" ] || ${pkgs.uv}/bin/uv tool install ${pkg}'')
      uvTools)}
  '';

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    # Login-shell env: brew (node comes from nix, npm globals from ~/.npm-global).
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    '';
    initContent = ''
      bindkey '^f' autosuggest-accept
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
  home.file.".config/helix".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/helix";
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
