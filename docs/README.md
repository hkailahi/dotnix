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

## Give up

- nix-darwin was (prob? somehow?) reverting my nix installation (2.13.x -> 2.3.x) and this was causing issues with flake flags.
- detsys installer setup /etc/nix/nix.conf, which nix-darwin took issue with since it wants to control (nix.settings opt)
- <darwin> nix-channel permission issues when setting up (restart might have fixed it)
- after messing with it have `darwin-rebuild` command but running on configuration.nix isn't setting up `bat` anymore. Env issue?

-----------------------------------------

Attempt #2: Follow https://juliu.is/tidying-your-home-with-nix/

Using `~/.config/dotnix` instead of `~/.config/nixpkgs`

* Setup up flake.nix and home.nix

* Run `nix run .#homeConfigurations.hkailahi.activationPackage` to install home-manager and setup first configuration

After this, `home-manager switch --flake .#hkailahi` can be run to switch home profile (aka rebuild home env via flake.nix and home.nix)
- This is just a shorthand for above `nix run .#homeConf....`

NOTE: The `.` in `.#hkailahi` is the <flake-uri>. Since I'm running from `dotnix` repo, `.` works, otherwise `~/.config/dotnix` or similar prob

Per https://nix-community.github.io/home-manager/index.html#ch-nix-flakes
> The flake inputs are not upgraded automatically when switching. The analogy to the command home-manager --update ... is nix flake update.
>
> If updating more than one input is undesirable, the command nix flake lock --update-input <input-name> can be used.
>
> You can also pass flake-related options such as --recreate-lock-file or --update-input [input] to home-manager when building/switching, and these options will be forwarded to nix build. See the NixOS Wiki page for detail.

