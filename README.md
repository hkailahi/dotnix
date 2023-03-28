# dotnix

## Steps

* Install nix
(Needed to boostrap initial configuration) per https://github.com/LnL7/nix-darwin#install
```bash
$ nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
$ ./result/bin/darwin-installer
```

* Initialize with minimal config flake

Per https://github.com/LnL7/nix-darwin#flakes-experimental

Replace "Henelis-MacBook-Pro-2" with result of `hostname | cut -f 1 -d .`
```nix:configuration.nix
{
  description = "Heneli's darwin system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, darwin, nixpkgs }: {
    darwinConfigurations."Henelis-MacBook-Pro-2" = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [ ./configuration.nix ];
    };
  };
}
``` 

Run following to bootstrap system

```
# Get a default configuration.nix in repo
$ cp ~/.nixpkgs/darwin-configuration.nix ~/.config/dotnix
$ mv darwin-configuration.nix configuration.nix
```

```bash
$ nix build ~/.config/darwin\#darwinConfigurations.Henelis-MacBook-Pro-2.system
$ ./result/sw/bin/darwin-rebuild switch --flake ~/.config/darwin
```
