{ pkgs, lib, ... }: {
  home.username = "hkailahi";
  home.homeDirectory = "/Users/hkailahi";
  home.stateVersion = "22.11";
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "vscode"
  ];
  
  home.packages = with pkgs; [
    # Shell
    pkgs.bashInteractive
    
    # CLI Programs
    bat
    delta
    tldr
    tree

    # Nix-specific Tools
    haskellPackages.nix-derivation
    nix-direnv
    nix-tree
    nixpkgs-fmt
    rnix-lsp
  ];

  ##### Home-Manager Program Options ###############################################################
  programs.bash = {
    enable = true;
    profileExtra = builtins.readFile ./bash_profile;
    # initExtra = builtins.readFile ./bashrc;
  };

  programs.direnv.enable = true;
  programs.direnv = {
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.exa = {
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
    extensions = with pkgs.vscode-extensions; [
      # Nix
      bbenoist.nix
      jnoortheen.nix-ide
      arrterian.nix-env-selector
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
        # Mypy
        name = "mypy";
        publisher = "matangover";
        version = "0.2.2";
        sha256 = "sha256-eaiR30HjPCpOLUKQqiQ2Oqj+XY+JNnV47bM5KD2Mouk=";
      }
      {
        # Run python doctests inline like HLS
        name = "python-inline-repl";
        publisher = "zijie";
        version = "0.0.1";
        sha256 = "sha256-rn/ZR5OgDaxAGB+Q0FJ3Vx1VIAVosoZq1A5z+hptiI0=";
      }
      {
        # Access documentation with Zeal (linux kapeli/Dash.app alternetive)
        name = "vscode-dash"; # configure in vscode's settings.json through nix
        publisher = "deerawan";
        version = "2.4.0";
        sha256 = "sha256-Yqn59ppNWQRMWGYVLLWofogds+4t/WRRtSSfomPWQy4=";
      }
    ];
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
}
