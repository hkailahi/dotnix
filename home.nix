{ pkgs, ... }:
{
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "code";
    # Just keep copy of ./etc-nix files in .config/nix since nix.settings and nix.extraOptions refuse to work
    # FIXME 1/2024 - Settings in `darwin.nix` get applied to /etc/nix/nix.conf before this changes?
    NIX_CONF_DIR = "$HOME/.config/nix";
  };

  ##### Home-Manager Configurable Packages ###############################################################
  programs.bash = {
    enable = true;
    profileExtra = builtins.readFile ./bash_profile;
    initExtra = builtins.readFile ./bashrc;

    ## Per https://github.com/nix-community/home-manager/issues/3133#issuecomment-1320315536
    # turn off the automated completion injection
    enableCompletion = false;
    # manually import completions using `-z` to check if it's been loaded instead of `-v`
    bashrcExtra = ''
      if [[ -z BASH_COMPLETION_VERSINFO ]]; then
        . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
      fi
    '';

    ## Per https://github.com/nix-community/home-manager/blob/bb4b25b302dbf0f527f190461b080b5262871756/modules/programs/bash.nix#L86
    # Modify default option set to remove macOS-incompatible options
    shellOptions = [

      # Append to history file rather than replacing it.
      "histappend"

      # check the window size after each command and, if
      # necessary, update the values of LINES and COLUMNS.
      "checkwinsize"

      # Extended globbing.
      "extglob"
      # "globstar"  # unavailable on macOS

      # Warn if closing shell with running jobs.
      # "checkjobs"  # unavailable on macOS
    ];
  };

  programs.direnv.enable = true;
  programs.direnv = {
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.git = {
    enable = true;
    includes = [{ path = "~/.config/nixpkgs/gitconfig"; }];
  };

  programs.jq.enable = true;

  # Settings adapted from https://github.com/the-argus/nixsys/blob/74ee1dd0ac503e241581ee8c3d7b719fa4305e1e/user/primary/lf.nix#L46
  programs.lf = {
    enable = true;
    settings = {
      drawbox = true;
      dirfirst = true;
      icons = true;
      ignorecase = true;
      preview = true;
      # shell = "${pkgs.dash}/bin/dash";
      # shellopts = "-eu";
      # tabstop = 2;
      # info = "size";
    };
    # previewer = {
    #   source = sandbox;
    #   keybinding = "i";
    # };
  };

  programs.neovim.enable = true;
  programs.neovim = {
    defaultEditor = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = [ ];
    extraPython3Packages = ps: [ ];
    plugins = [ ];
  };

  programs.nix-index.enable = true;
  programs.nix-index = {
    enableBashIntegration = true;
  };

  programs.pylint.enable = true;
  programs.pylint = {
    settings = { };
  };

  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;

    userSettings = {
      "editor" = {
        "fontSize" = 18;
        "formatOnPaste" = true;
        "tabSize" = 2;
        "rulers" = [ 100 ];
      };
      "files.trimTrailingWhitespace" = true;
      "markdown.preview.doubleClickToSwitchToEditor" = false;
      "markdown.preview.openMarkdownLinks" = "inEditor";
      "[markdown]" = {
        "editor.unicodeHighlight.allowedCharacters" = {
          "’" = true;
        };
        "editor.wordWrap" = "on";
      };
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      "nix.enableLanguageServer" = true; # Enable LSP.
      "nix.serverPath" = "nil";
      "nix.serverSettings" = {
        "nil" = {
          # "diagnostics" = {
          #   "ignored" = [ "unused_binding" "unused_with" ];
          # };
          "formatting" = {
            "command" = [ "nixpkgs-fmt" ];
          };
        };
      };
      "window.titleBarStyle" = "native";
    };

    extensions = with pkgs.vscode-extensions; [
      # Nix
      bbenoist.nix
      jnoortheen.nix-ide
      # arrterian.nix-env-selector
      # Haskell
      haskell.haskell
      # Python
      ms-python.python
      # ms-python.vscode-pylance # FIXME - allowUnfree
      # Documentation
      yzhang.markdown-all-in-one
      # Configuration
      tamasfe.even-better-toml
      # Theme
      # Tooling
      eamodio.gitlens
      # General
    ]

    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        # Automatically load environments with direnv
        name = "direnv";
        publisher = "mkhl";
        version = "0.14.0";
        sha256 = "sha256-T+bt6ku+zkqzP1gXNLcpjtFAevDRiSKnZaE7sM4pUOs=";
      }
      {
        # Mypy
        name = "mypy";
        publisher = "matangover";
        version = "0.2.2";
        sha256 = "sha256-eaiR30HjPCpOLUKQqiQ2Oqj+XY+JNnV47bM5KD2Mouk=";
      }
      {
        # Prettier JS formatter
        name = "prettier-vscode";
        publisher = "esbenp";
        version = "9.10.4";
        sha256 = "sha256-khtyB0Qbm+iuM1GsAaF32YRv1VBTIy7daeCKdgwCIC8=";
      }
      {
        # Pretty Typescript Errors
        name = "pretty-ts-errors";
        publisher = "yoavbls";
        version = "0.4.1";
        sha256 = "sha256-vY/dVO9k3LcXLYH9eX9blKMB+mDGCWkmU9ZU62YvAcM=";
      }
      {
        # Run python doctests inline like HLS
        name = "python-inline-repl";
        publisher = "zijie";
        version = "0.0.1";
        sha256 = "sha256-rn/ZR5OgDaxAGB+Q0FJ3Vx1VIAVosoZq1A5z+hptiI0=";
      }
      {
        # Documentation with Zeal (linux kapeli/Dash.app alternetive)
        name = "vscode-dash"; # configure in vscode's settings.json through nix
        publisher = "deerawan";
        version = "2.4.0";
        sha256 = "sha256-Yqn59ppNWQRMWGYVLLWofogds+4t/WRRtSSfomPWQy4=";
      }
      {
        # Language support for MDX
        name = "vscode-mdx";
        publisher = "unifiedjs";
        version = "1.3.0";
        sha256 = "sha256-TfqSU9V5vG7GwxEihUdEGC19VFHEUjlrTg+XXHdOYn4=";
      }
    ];
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
}
