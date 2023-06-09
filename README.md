# dotnix

Personal system configuration used on my 2019 Intel Macbook Pro.

- [dotnix](#dotnix)
  - [Understanding `dotnix`](#understanding-dotnix)
  - [Contents](#contents)
  - [Installation](#installation)
  - [How I Started](#how-i-started)

## Understanding `dotnix`

| File | Purpose | Notes |
|------|---------|-------|
| `home.nix` | My system configuration via [`home-manager`](https://github.com/nix-community/home-manager) including: <br />• apps (1Password, Firefox, VSCode)<br />• dev settings (`.git`, `.bashrc`)<br />• CLI tools (`bat`, `fzf`, `jq`)<br />...and more |• [Home-Manager Manual](https://nix-community.github.io/home-manager/index.html) - tool for declaratively managing system configuration, dotfiles, etc<br />• [Home-Manager Options](https://nix-community.github.io/home-manager/options.html) & [Options Search](https://mipmip.github.io/home-manager-option-search/) - pre-defined configurations available with `home-manager`<br />• [NixPkgs](https://search.nixos.org/packages) - package repository + binary cache with 100k+ available packages |
| `flake.nix` | Takes Nix expressions as input, then output things like package definitions, development environments, or, as is the case here, system configurations.<br /><br />For this specific repository, we can think of it as wrapping `home.nix` in order to provide it pinned dependencies and manage the outputs. | • [Zero to Nix Glossary](https://zero-to-nix.com/concepts/flakes)<br />• [xeiaso's Nix Flake Guides](https://xeiaso.net/blog/series/nix-flakes) |
| `flake.lock` | Pins dependencies used in flake inputs | |
| `bin/apply-system.sh` | Script to apply system configuration | Simple `home-manager switch...` invocation |
| `bin/update-system.sh` | Script to update dependencies | Simple `nix flake update` invocation |
| `etc-nix/*` | Deprecated | |


## Contents

Software installed with `dotnix` is specified in following ways:
  - [Home-Manager Options](https://mipmip.github.io/home-manager-option-search/)
    - Via `programs.*` in `home.nix`
  - [Nixpkgs](https://search.nixos.org/packages) Package Set
    - Via `home.packages` in `home.nix`, corresponding to `nixpkgs` release at `flake.nix:inputs.nixpkgs.url`
  - [Flake Inputs](https://zero-to-nix.com/concepts/flakes#inputs)
    - Via `inputs` in `flake.nix` and pinned in `flake.lock`

System-wide `nix` settings are specified in `home.nix` under the following declarations:
  - `nix.package`
    - Determines which version of `nix` is used
      - Has matching declaration under `home.packages.config.nix.package`
  - `home.sessionVariables`
    - Environment variables set at login
  - `nix.settings`
    - Replaces configuration that's usually found at `/etc/nix/nix.conf`
    - Sets feature flags, binary cache keys and locations, etc
  - `nix.registry`
    - Replaces configuration that's usually found at `/etc/nix/registry.json`
    - Same as default found at https://github.com/NixOS/flake-registry
      - > "The flake registry serves as a convenient method for the Nix CLI to associate short names with flake URIs, such as linking `nixpkgs` to `github:NixOS/nixpkgs/nixpkgs-unstable.`"

## Installation

1. Install `nix`

Follow the [Zero-to-Nix Quickstart Guide](https://zero-to-nix.com/start/install) for a flake-based `nix` installation.

2. Setup `dotnix` repo

```bash
$ mkdir -p ~/.config
$ cd ~/.config
$ git clone git@github.com:hkailahi/dotnix.git
```

3. Apply system configurations

```bash
$ cd ~/.config/dotnix/
$ ./bin/update-system.sh
```

## How I Started

This is the path I took for developing this repo following https://julomeiu.is/tidying-your-home-with-nix/.

1. Install `nix`

Follow the [Zero-to-Nix Quickstart Guide](https://zero-to-nix.com/start/install) for a flake-compatible nix installation

2. Configure repo
Using `~/.config/dotnix` instead of `~/.config/nixpkgs`

```bash
$ mkdir -p ~/.config/dotnix
```

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

