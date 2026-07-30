{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "gh"     # GitHub CLI (gh-axi and no-mistakes call into it)
      "herdr"
      "nvm"    # node lives under nvm; the axi tools are npm globals there
      "uv"     # python tooling; uv-managed tool shims live in ~/.local/bin
    ];
    casks = [
      "wezterm"
      "claude-code"
      "brave-browser"  # personal browser
      "codex"          # no-mistakes is agent-agnostic: Claude-authored PRs run the Codex leg
      "google-chrome"  # automation browser only: chrome-devtools-axi launches it isolated+headless
    ];
  };
}
