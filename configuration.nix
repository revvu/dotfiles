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
    onActivation.cleanup = "none";  # applying never removes an installed item
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "doppler"  # gallopify secrets: doppler run --project ... wraps every service
      "herdr"
    ];
    # CLI tools that Homebrew ships as casks. GUI apps are not declared here;
    # the README lists them.
    casks = [
      "claude-code@latest"
      "codex"  # no-mistakes is agent-agnostic: Claude-authored PRs run the Codex leg
    ];
  };

  # Codex's lowest-priority config layer. Codex writes ~/.codex/config.toml
  # itself, so that file stays app-owned and untracked.
  environment.etc."codex/config.toml".text = ''
    model = "gpt-6-astra"
    model_reasoning_effort = "medium"

    [marketplaces.posthog]
    source_type = "git"
    source = "https://github.com/PostHog/ai-plugin.git"
  '';
}
