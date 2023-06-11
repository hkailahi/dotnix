# dotnix

Declarative system configuration used on my 2019 Intel Macbook Pro.
```bash
$ nix-info -m && date
 - system: `"x86_64-darwin"`
 - host os: `Darwin 22.5.0, macOS 10.16`
 - multi-user?: `yes`
 - sandbox: `no`
 - version: `nix-env (Nix) 2.15.1`
 - nixpkgs: `/nix/store/jlbslziyjj8clk62y4pr7fc23amm5npp-source`

Sat Jun 10 21:15:00 PDT 2023
```

- [dotnix](#dotnix)
  - [Learn](#learn)
    - [System Configuration with Nix](#system-configuration-with-nix)
    - [Understanding `dotnix`](#understanding-dotnix)
  - [Do](#do)
    - [Installation](#installation)
    - [Modifying the System Configuration](#modifying-the-system-configuration)
    - [Updating the System Configuration](#updating-the-system-configuration)
  - [Learn and Do](#learn-and-do)
    - [How I Started](#how-i-started)

## Learn

### System Configuration with Nix

NixOS allows users to define the entire system configuration in a declarative manner using the Nix expression language. This includes specifying packages, services, users, and other system settings. The declarative nature of NixOS ensures that the system configuration is version-controlled, reproducible, and easy to share. It also simplifies system administration by providing a single source of truth for the entire system state.

Outside of NixOS, declarative system configuration can be achieved on MacOS through various Nix-based tools like `home-manager` and `nix-darwin`. The following tools work with both standard and `flake`-based approaches:

| System Configuration | Platforms | Configuration File | Configuration Options | Notes |
|------|---------|-------|-------|-------|
| [NixOS](https://nixos.org/manual/nix/stable/) | NixOS | `configuration.nix` | Available in [Manual](https://nixos.org/manual/nixos/stable/options.html) or [NixOS Options Search](https://search.nixos.org/options) | |
| [Home-Manager](https://nix-community.github.io/home-manager/) | NixOS, Linux, MacOS | `home.nix` | [`accounts`, `home`, `launchd`, `nix`, `programs`, `services`, `systemd`, `targets.darwin`, `wayland`, `xdg`, `xsession`](https://mipmip.github.io/home-manager-option-search/) | Can also be configured as [NixOS module](https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module) or [`nix-darwin` module](https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module) |
| [Nix-Darwin](https://daiderd.com/nix-darwin/) | MacOS | `darwin-configuration.nix` | [`enviroment`, `homebrew`, `launchd`, `networking`, `nix`, `programs`, `services`, `system`, `users`](https://daiderd.com/nix-darwin/manual/index.html#sec-options)  |

### Understanding `dotnix`

| File | Purpose | Notes |
|------|---------|-------|
| `home.nix` | My system configuration via [`home-manager`](https://github.com/nix-community/home-manager) including: <br />• apps (1Password, Firefox, VSCode)<br />• dev settings (`.git`, `.bashrc`)<br />• CLI tools (`bat`, `fzf`, `jq`)<br />...and more |• [Home-Manager Manual](https://nix-community.github.io/home-manager/index.html) - tool for declaratively managing system configuration, dotfiles, etc<br />• [Home-Manager Options](https://nix-community.github.io/home-manager/options.html) & [Options Search](https://mipmip.github.io/home-manager-option-search/) - pre-defined configurations available with `home-manager`<br />• [NixPkgs](https://search.nixos.org/packages) - package repository + binary cache with 100k+ available packages |
| `flake.nix` | Takes Nix expressions as input, then output things like package definitions, development environments, or, as is the case here, system configurations.<br /><br />For this specific repository, we can think of it as wrapping `home.nix` in order to provide it pinned dependencies and manage the outputs. | • [Zero to Nix Glossary](https://zero-to-nix.com/concepts/flakes)<br />• [xeiaso's Nix Flake Guides](https://xeiaso.net/blog/series/nix-flakes) |
| `flake.lock` | Pins dependencies used in flake inputs | |
| `bin/apply-system.sh` | Script to apply system configuration | Simple `home-manager switch...` invocation |
| `bin/update-system.sh` | Script to update dependencies | Simple `nix flake update` invocation |

---

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

## Do

### Installation

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
$ ./bin/apply-system.sh
```

### Modifying the System Configuration

1. Modify configuration files

For example, add a new package to install in `home.nix` or move to a newer release of `nixpkgs` in `flake.nix`.

2. Apply system configurations

```bash
$ cd ~/.config/dotnix/
$ ./bin/apply-system.sh
```


### Updating the System Configuration

1. Update dependencies in `flake.lock`

```bash
$ cd ~/.config/dotnix/
$ ./bin/update-system.sh
```

2. Apply system configurations

```bash
$ cd ~/.config/dotnix/
$ ./bin/apply-system.sh
```

## Learn and Do

### How I Started

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

