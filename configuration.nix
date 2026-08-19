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
    # No caskArgs.no_quarantine: Homebrew 6 dropped --no-quarantine from
    # `brew install`, so passing it fails every cask. It was never needed —
    # brew's own quarantine code sets the no-translocation bit (bit 8) on the
    # xattr it writes, so cask apps launch from /Applications, not from a
    # random AppTranslocation path.
    taps = [
      "my-monkeys/tap"  # OpenSuperWhisper's cask lives here, not in homebrew-cask
    ];
    brews = [
      "doppler"  # gallopify secrets: doppler run --project ... wraps every service
      "herdr"
    ];
    casks = [
      "wezterm"
      "claude-code"
      "brave-browser"  # personal browser
      "codex"          # no-mistakes is agent-agnostic: Claude-authored PRs run the Codex leg
      "google-chrome"  # automation browser only: chrome-devtools-axi launches it isolated+headless
      "my-monkeys/tap/opensuperwhisper"  # local dictation, from the tap above
    ];
  };
}
