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
  # launchd starts jobs with /usr/bin:/bin:/usr/sbin:/sbin; the agents below
  # get the same PATH a login shell has, so the tools they spawn resolve.
  launchdPath = lib.concatStringsSep ":" [
    "/Users/${user}/.npm-global/bin"
    "/Users/${user}/.local/bin"
    "/etc/profiles/per-user/${user}/bin"
    "/run/current-system/sw/bin"
    "/nix/var/nix/profiles/default/bin"
    "/opt/homebrew/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
  ];
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
    postgresql_17  # psql and the other clients the gallopify backend calls
    mupdf     # mutool
    qpdf
    tree
    actionlint
    shellcheck
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "hx";
  # The nix store is read-only, so `npm install -g` needs a writable prefix.
  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
    # uv tool shims and gallopify-internal binaries
    "${config.home.homeDirectory}/.local/bin"
  ];

  # Self-updating tools: the repo guarantees presence, never a version.
  # Updates are run by hand (no-mistakes update, treehouse update) when the
  # weekly audit says a release is out.
  # Runs in a subshell: the PATH it needs (/usr/bin for the installers) must
  # not leak into later activation steps, which rely on GNU coreutils.
  home.activation.selfUpdatingTools = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    (
      mkdir -p "$HOME/.local/bin"
      export PATH="$HOME/.local/bin:${pkgs.curl}/bin:/usr/bin:/bin:$PATH"
      [ -x "$HOME/.no-mistakes/bin/no-mistakes" ] || curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | NO_MISTAKES_LINK_DIR="$HOME/.local/bin" sh
      [ -x "$HOME/.local/bin/treehouse" ] || curl -fsSL https://kunchenguid.github.io/treehouse/install.sh | sh
      [ -x "$HOME/.local/bin/cursor-agent" ] || curl -fsS https://cursor.com/install | bash
    )
  '';


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
    ignores = [ "**/.claude/settings.local.json" ];
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

  # Only the config file: herdr keeps its sockets, logs and sessions next to it.
  home.file.".config/herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr/config.toml";
  # herdr's server is a launchd user agent so it starts at login inside the GUI
  # session, where the login keychain is unlocked. Claude Code, Doppler and
  # cursor-agent keep their credentials in that keychain, and macOS unlocks it
  # per security session: a process started over ssh is locked out, so on a
  # headless machine every agent has to descend from this job.
  # Exit codes drive KeepAlive: a crash (non-zero) is restarted, `herdr server
  # stop` (zero) stays stopped until the next login. A server already started
  # by hand makes this one exit 1, and launchd retries every ten seconds until
  # that one exits.
  launchd.agents.herdr = {
    enable = true;
    config = {
      ProgramArguments = [ "/opt/homebrew/bin/herdr" "server" ];
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
      EnvironmentVariables.PATH = launchdPath;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/herdr-server.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/herdr-server.log";
    };
  };
  # claude-swap's auto-switch, for the same reason: it reads and rewrites
  # Claude Code's login in the keychain, so it has to live in the GUI session.
  # It polls every minute and moves the default login to the account with most
  # headroom when the active one reaches 90% of its 5h or 7d window, or of the
  # Fable weekly window (the limit hit most). firstmate's per-spawn slot pick
  # is separate and composes with this: it launches crewmates isolated on their
  # own slot without touching the default login.
  launchd.agents.cswap-auto = {
    enable = true;
    config = {
      ProgramArguments = [ "/Users/${user}/.local/bin/cswap" "auto" "--model" "Fable" ];
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
      EnvironmentVariables.PATH = launchdPath;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/cswap-auto.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/cswap-auto.log";
    };
  };
  # The weekly drift audit (bin/audit gathers, bin/audit-page renders and pushes
  # the page into the agent inbox): Sunday 21:10. Declared on every machine,
  # built only on the server: audit-page --scheduled checks the hostname, so
  # one home.nix serves both. It lives in the GUI session for the same reason
  # as the two above, claude -p reads the login keychain. launchd runs a
  # calendar job it missed while asleep, not one it missed while powered off.
  launchd.agents.audit = {
    enable = true;
    config = {
      ProgramArguments = [ "${dotfiles}/bin/audit-page" "--scheduled" ];
      StartCalendarInterval = [ { Weekday = 0; Hour = 21; Minute = 10; } ];
      EnvironmentVariables.PATH = launchdPath;
      EnvironmentVariables.NPM_CONFIG_PREFIX = config.home.sessionVariables.NPM_CONFIG_PREFIX;
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/audit.log";
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/audit.log";
    };
  };
  # Claude Code writes settings.json itself, so the repo only seeds it once.
  home.activation.claudeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    settings="$HOME/.claude/settings.json"
    if [ -L "$settings" ] || [ ! -e "$settings" ]; then
      rm -f "$settings"
      install -m 644 ${./home/.claude/settings.seed.json} "$settings"
    fi
  '';


  # settings.json's statusLine runs this by absolute path, so it has to land in
  # ~/.claude rather than only existing in the repo.
  home.file.".claude/statusline.py".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/statusline.py";

  # One global agent policy (home/global-agents.md — named distinctly from the
  # repo-root AGENTS.md, which holds project notes for agents editing this repo),
  # linked into each agent's own discovery location:
  # Claude reads ~/.claude/CLAUDE.md; Codex reads ~/.codex/AGENTS.md; Pi reads
  # ~/.pi/agent/AGENTS.md. Cursor has no file location: its User Rules are pasted by hand.
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/global-agents.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/global-agents.md";
  home.file.".pi/agent/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/global-agents.md";

  # bin/doctor compares the live machine with what this evaluation declared,
  # so the declared sets are written out by the same evaluation. Brew items
  # are not listed here: the doctor reads the Brewfile the system activates.
  home.file.".config/doctor/declared.json".text = builtins.toJSON {
    npm = builtins.attrNames npmGlobals;
    uv = builtins.attrNames uvTools;
    # self-updating tools (installed above) and their aliases
    localBin = [ "agent" "cursor" "cursor-agent" "cswap" "no-mistakes" "treehouse" ];
    # installed by hand, listed in the README, never declared
    exempt = {
      brews = [ ];
      casks = [ "wezterm" "brave-browser" "google-chrome" "opensuperwhisper" ];
      taps = [ "my-monkeys/tap" "automic-vault/isotopes" ];
    };
  };
}
