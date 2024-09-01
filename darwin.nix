{ pkgs, pkgsUnstable, lib, config, ... }:
let
  tie = import
    (pkgs.fetchFromGitHub
      {
        owner = "justinwoo";
        repo = "easy-tie-nix";
        rev = "ca0d80f3767cdaa792f0904250f36f4125a4afa0";
        sha256 = "sha256-5IozQCF8Bt+A7Y7hhmNrMzmb9lplgRu59ylLghSppRM=";
      }
    )
    { inherit pkgs; };

in
{
  ##################################################################################################
  ### Configuring Nix + Nix-Darwin
  ##################################################################################################

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nixVersions.latest; # Per https://discourse.nixos.org/t/how-to-upgrade-nix-on-macos-with-home-manager/25147/4
    checkConfig = true;
    # nixPath = [
    #   { darwin-config = "$HOME/.nixpkgs/darwin-configuration.nix"; }
    #   "/nix/var/nix/profiles/per-user/root/channels"
    # ];
    settings = {
      # Generated by https://github.com/DeterminateSystems/nix-installer, version 0.6.0.
      "bash-prompt-prefix" = "(nix:$name)\040";
      "build-users-group" = "nixbld";
      "extra-nix-path" = "nixpkgs=flake:nixpkgs";
      "experimental-features" = "nix-command flakes";
      "auto-optimise-store" = true;
      "max-jobs" = "auto";
      "upgrade-nix-store-path-url" = "https://install.determinate.systems/nix-upgrade/stable/universal";

      # Manual Additions
      ## FIXME warning: ignoring untrusted substituter <blah>, you are not a trusted user.
      ## Run `man nix.conf` for more information on the `substituters` configuration option.
      "extra-trusted-substituters" = [
        "https://cache.nixos.org/"
        "https://iohk.cachix.org"
        "https://nix-community.cachix.org"
        "https://scarf.cachix.org"
      ];
      "extra-trusted-public-keys" = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-users = [
        "root"
        "jdoe"
      ];
    };
  };

  users.users.jdoe = {
    name = "jdoe";
    home = "/Users/jdoe";
  };

  # Create /etc/zshrc | /etc/bashrc that loads the nix-darwin environment.
  # FIXME `nix-darwin` can't set default shell
  programs.bash.enable = true;

  ##################################################################################################
  ### Package Management (via nixpkgs and homebrew)
  ##################################################################################################

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "raycast"
    "terraform"
    "vscode"
  ];

  # Provided by nixpkgs
  environment.systemPackages = [
    tie # FIXME Bad CPU type in executable - For full logs, run 'nix log /nix/store/fj4w2qxg3fdfphcr6z1llv8y50499b3k-tie-20240321.drv'
    # vulnix FIXME Enable with overlay
  ] 
  ++ (with pkgsUnstable;
    [
      tbls # Tool for documenting sql databases (postgres + clickhouse support)
    ]
  )
    ++ (with pkgs;
    [
      config.nix.package # Per https://discourse.nixos.org/t/how-to-upgrade-nix-on-macos-with-home-manager/25147/4

      # Programming Languages and Environments
      go
      python313
      # haskell.compiler.ghc94 # ghc-9.4.5 (lts-21.3)
      nodejs_22
      nodePackages.pnpm

      # Linters + Formatters
      haskellPackages.cabal-fmt
      hlint
      nixpkgs-fmt
      ormolu
      sqlfluff # SQL formatter that supports Postgres and ClickHouse
      treefmt # Runs all formatters

      # Infra
      dhall
      k9s
      terraform

      # Data
      sqlcheck # SQL Anti-Pattern Linter
      # python312Packages.sqlglot # SQL Parser (used in sqlmesh)

      # Data Store
      duckdb
      clickhouse
      sqlite

      # Shell
      bashInteractive

      # CLI Programs
      bat # modern `cat`
      delta # for diff-ing
      jc # convert cli command outputs to json
      procs # modern `ps`
      tldr # quick usage guide when you don't need the full manpages
      tree # visualize directory tree
      visidata # Excel for CLI

      # Nix-specific Tools
      cachix
      haskellPackages.nix-derivation
      nil # https://github.com/oxalica/nil#readme
      nix-direnv
      nix-info
      nix-tree
      sbomnix

      # GUI Apps
      raycast # alfred/spotlight alternative, productivity tool
      tailscale # work vpn

      # Other

      # Mac OS Setup - Scarf Deps - https://www.notion.so/scarf/Mac-OS-setup-...
      bitwarden-cli
      curlWithGnuTls
      wget
    ]);

  # Provided by nix-darwin.
  homebrew = {
    enable = true; # NOTE: Doesn't install homebrew. See https://daiderd.com/nix-darwin/manual/index.html#opt-homebrew.enable
    brews = [
      # https://formulae.brew.sh/formula/{name}
      
      # Dev dependencies

      # Other
      # { name = "bitwarden-cli"; }
      # { name = "mas"; }
    ];
    casks = [
      "1password"
      "1password-cli"
      "firefox" # browser
      "mullvadvpn" # privacy vpn
      "slack"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
    };
  };

  ##################################################################################################
  ### Mac OS System Settings
  ##################################################################################################

  ## See available configuration options at https://daiderd.com/nix-darwin/manual/index.html

  security.pam.enableSudoTouchIdAuth = true;

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      persistent-apps = [
        "/Applications/Firefox.app"
        "/System/Applications/Mail.app"
        "/System/Applications/Utilities/Terminal.app"
        "${pkgs.raycast}/Applications/Raycast.app"
        "/Applications/Mullvad\ VPN.app" # via brew cask
        "${pkgs.vscode}/Applications/Visual\ Studio\ Code.app"
      ];
      show-process-indicators = true;
      show-recents = false;
      static-only = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXPreferredViewStyle = "clmv"; # Finder View Options: “icnv” = Icon view (default), “Nlsv” = List view, “clmv” = Column View, “Flwv” = Gallery View
      _FXShowPosixPathInTitle = true; # show full posix filepath in window title
    };
    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = false;
    };
  };

  # NOTE TO SELF: Set up "external unknown keyboard" in System Preferences > Keyboard > Modifier Keys: 
    #   - Command key -> Option
    #   - Option key -> Commmand
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  ##################################################################################################
  ### Configurable Darwin Services + Packages
  ##################################################################################################

  ## See available configuration options at https://daiderd.com/nix-darwin/manual/index.html

  # TBD
  environment = {
    shellAliases = {
      ll = "ls -l";
    };
  };

  # TODO Move from `home.nix:programs.bash.bashrcExtra`????
  # systemPath = [
  #   "/usr/local/opt/postgresql@11/bin"
  #   "$HOME/.ghcup/bin"
  # ];

  # TODO Move from `home.nix:home.sessionVariables`????
  # variables = {
  #   EDITOR = "code";
  #   # Just keep copy of ./etc-nix files in .config/nix since nix.settings and nix.extraOptions refuse to work
  #   # FIXME 1/2024 - Settings in `darwin.nix` get applied to /etc/nix/nix.conf before this changes?
  #   NIX_CONF_DIR = "$HOME/.config/nix";
  # };
}
