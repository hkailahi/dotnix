# Flox - Experience Report - 6/23


- [Flox - Experience Report - 6/23](#flox---experience-report---623)
  - [Main Takeaways and Feedback](#main-takeaways-and-feedback)
  - [Experience Report](#experience-report)
    - [Background](#background)
    - [Begin](#begin)
    - [Install flox](#install-flox)
    - [flox in 5 minutes](#flox-in-5-minutes)
    - [Tutorials](#tutorials)
      - [Project Environments](#project-environments)
      - [Managed Environments](#managed-environments)
      - [Build Container Images](#build-container-images)
      - [Custom Packages](#custom-packages)
      - [Publish Custom Packages](#publish-custom-packages)
    - [Integrations](#integrations)
      - [direnv](#direnv)
    - [Cookbook](#cookbook)
      - [Validate Identical dev/prod Environments](#validate-identical-devprod-environments)
      - [Managed Environments](#managed-environments-1)
      - [Language Guides: Python](#language-guides-python)
  - [Uninstall flox](#uninstall-flox)

## Main Takeaways and Feedback

I'd feel comfortable recommending `flox` to colleagues looking to get into Nix. While I'd have to evaluate it further before recommending use on a team project, I think it would be worth taking that look. I'm already a fan of Nix, and any tool that would let me use it professionally without needing a *Nix Expert™️* on the team is compelling.

Things I'd want to know:
- How does `flox` hold up when you stray from the happy path?
  - Ex. Non-actionable `--show-trace` CLI suggestion on failure
- What's the business model? Does it seem sustainable? What does the enterprise plan offer?
- Are there examples of teams using `flox` in production?

The beta docs are pretty good but there are some bits that didn't work for me. I got through the installation and a couple tutorials before running out of steam. The cookbooks and concepts seemed solid from my quick skim. I regret jumping straight into the Docs page before reading the Product page since that would have better motivated the examples.

## Experience Report

I will add suggestions and note whether I feel weakly or strongly about them.

### Background

I'm vaguely aware of what `flox` is. I've skimmed several blog posts on floxdev.com relating to Nix proper in the past.

My skill level with Nix is probably closer to beginner than intermediate. I already have Nix set up on my Mac and want to either keep my current environment untouched (current profile, etc) or use be able to easily revert back to it. If I didn't already have a nix setup, I suspect I'd want the opposite.

I think `flox` is supposed to be some sort of package + environment manager built on Nix but beginner-friendly. I'm interested to see if it's something I could recommend to colleagues that I wouldn't recommend Nix too (or maybe for myself?).


### Begin

Trying out `flox` on my mac. I'm already have Nix + HM setup that I initially setup with the determinate system's nix-installer - https://github.com/hkailahi/dotnix

<details>

```bash
$ nix-info -m && date
 - system: `"x86_64-darwin"`
 - host os: `Darwin 22.5.0, macOS 10.16`
 - multi-user?: `yes`
 - sandbox: `no`
 - version: `nix-env (Nix) 2.15.1`
 - nixpkgs: `/nix/store/hmdjvalbmsb9x9wir7xq8y623abjl55w-source`
Fri Jun 30 09:58:00 PDT 2023
```

Starting from https://floxdev.com/docs/ and working way down the left nav.

```bash
$ lynx -listonly -nonumbers -dump https://floxdev.com/docs/ | grep -E "tutorials|cookbook|concepts" | sort | uniq
https://floxdev.com/docs/concepts/catalog/
https://floxdev.com/docs/concepts/environments/
https://floxdev.com/docs/concepts/flox-plus-nix/
https://floxdev.com/docs/concepts/generations/
https://floxdev.com/docs/concepts/package-arguments/
https://floxdev.com/docs/concepts/stabilities/
https://floxdev.com/docs/cookbook/language-guides/python/
https://floxdev.com/docs/cookbook/language-guides/rust/
https://floxdev.com/docs/cookbook/managed-environments/
https://floxdev.com/docs/cookbook/validate-identical/
https://floxdev.com/docs/tutorials/build-container-images/
https://floxdev.com/docs/tutorials/custom-packages/
https://floxdev.com/docs/tutorials/managed-environments/
https://floxdev.com/docs/tutorials/projects/
https://floxdev.com/docs/tutorials/publish-custom-packages/
```
</details>

### [Install flox](https://floxdev.com/docs/install-flox/)

Since I already have a Nix setup, the first thought that came to mind is whether setting up `flox` out will mess with my current profile or settings. I know that's the goal but I'm already happy with my Nix setup.

I checked nixpkgs for `flox` to see if I could grab it and stuff it in my system config. No dice.

Now looking at the `Nix/NixOS` setup. I've had problems with my `{/etc/nix, ~/.config}/nix.conf` before that I never really looked into but got working. Hopefully I don't run into issues adding the flox substituter. I'm assuming `_FLOX_PUBLIC_KEYS()` will interpolate keys and I don't have to get them myself? Anyways, no problems executing:

<details>

```diff
     "extra-trusted-substituters" = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
+       "https://cache.floxdev.com"
+    ];
+    "extra-trusted-public-keys" = [
+      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
+      "_FLOX_PUBLIC_KEYS()"
     ];
-    "extra-trusted-public-keys" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
   };
```

```bash
$ home-manager switch --flake .#hkailahi
warning: Git tree '/Users/hkailahi/.config/dotnix' is dirty
Starting Home Manager activation
Activating checkFilesChanged
Activating checkLaunchAgents
Activating checkLinkTargets
Activating writeBoundary
Activating copyFonts
Activating installPackages
replacing old 'home-manager-path'
installing 'home-manager-path'
Activating linkGeneration
Cleaning up orphan links from /Users/hkailahi
Creating profile generation 60
Creating home file links in /Users/hkailahi
Activating onFilesChange
Activating setupLaunchAgents
~/.config/dotnix
```
</details>

Now that that's done, I'm going to skip the `nix profile install --impure` and try to add `flox` as a flake. I see that there's a [`flake.nix`](https://github.com/flox/flox/blob/main/flake.nix) in the main repo, so I'll start with that.

<details>

```diff
inputs = {
  ...
+    flox = {
+      url = "github:flox/flox";
+    };
   };
```

```bash
~/.config/dotnix ~/.config/dotnix
warning: Git tree '/Users/hkailahi/.config/dotnix' is dirty
warning: updating lock file '/Users/hkailahi/.config/dotnix/flake.lock':
• Added input 'flox':
    'github:flox/flox/35e79112dab96895f43fa9b34d1149471b5f138e' (2023-06-30)
• Added input 'flox/crane':
    'github:ipetkov/crane/116b32c30b5ff28e49f4fcbeeb1bbe3544593204' (2023-06-21)
• Added input 'flox/crane/flake-compat':
    'github:edolstra/flake-compat/35bb57c0c8d8b62bbfd284272c928ceb64ddbde9' (2023-01-17)
• Added input 'flox/crane/flake-utils':
    'github:numtide/flake-utils/a1720a10a6cfe8234c0e93907ffe81be440f4cef' (2023-05-31)
• Added input 'flox/crane/flake-utils/systems':
    'github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e' (2023-04-09)
• Added input 'flox/crane/nixpkgs':
    'github:NixOS/nixpkgs/c6ffce3d5df7b4c588ce80a0c6e2d2348a611707' (2023-06-02)
• Added input 'flox/crane/rust-overlay':
    'github:oxalica/rust-overlay/c535b4f3327910c96dcf21851bbdd074d0760290' (2023-06-03)
• Added input 'flox/crane/rust-overlay/flake-utils':
    follows 'flox/crane/flake-utils'
• Added input 'flox/crane/rust-overlay/nixpkgs':
    follows 'flox/crane/nixpkgs'
• Added input 'flox/floco':
    'github:aakropotkin/floco/e1231f054258f7d62652109725881767765b1efb' (2023-05-16)
• Added input 'flox/floco/nixpkgs':
    'github:NixOS/nixpkgs/cfb43ad7b941d9c3606fb35d91228da7ebddbfc5' (2023-01-20)
• Added input 'flox/flox-floxpkgs':
    'github:flox/floxpkgs/1a3a66ba4303de673a673816ab9a4c874cddfa25' (2023-06-28)
• Added input 'flox/flox-floxpkgs/builtfilter':
    'github:flox/builtfilter/f29903b144bb20e5be80f55d3fafa323c28a2cb0' (2023-05-12)
• Added input 'flox/flox-floxpkgs/builtfilter/flox-floxpkgs':
    follows 'flox/flox-floxpkgs'
• Added input 'flox/flox-floxpkgs/capacitor':
    'github:flox/capacitor/0694a193660db2cb1a7a6e04949478b25f81d802' (2023-02-05)
• Added input 'flox/flox-floxpkgs/capacitor/nixpkgs':
    'github:flox/nixpkgs/7084250df3d7f9735087d3234407f3c1fc2400e3' (2023-05-22)
• Added input 'flox/flox-floxpkgs/capacitor/nixpkgs-lib':
    'github:nix-community/nixpkgs.lib/b3ec8fb525fc0c8f08eff5ef93c684b4c6d0e777' (2023-06-25)
• Added input 'flox/flox-floxpkgs/etc-profiles':
    'github:flox/etc-profiles/341861cecc742fc749a5d915e6a16c538bfc5861' (2023-06-28)
• Added input 'flox/flox-floxpkgs/etc-profiles/flox-floxpkgs':
    follows 'flox/flox-floxpkgs'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib':
    'github:flox/ld-floxlib/b868e931d035c93a9a325a65bc312f15441d9d15' (2023-06-28)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs':
    'github:flox/floxpkgs/d12b0310b8fefe279589fd771d194bca0f560f08' (2023-06-15)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/builtfilter':
    'github:flox/builtfilter/f29903b144bb20e5be80f55d3fafa323c28a2cb0' (2023-05-12)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/builtfilter/flox-floxpkgs':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/capacitor':
    'github:flox/capacitor/0694a193660db2cb1a7a6e04949478b25f81d802' (2023-02-05)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/capacitor/nixpkgs':
    'github:flox/nixpkgs/7084250df3d7f9735087d3234407f3c1fc2400e3' (2023-05-22)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/capacitor/nixpkgs-lib':
    'github:nix-community/nixpkgs.lib/a08e40a9bc625b7ee428bd7b64cdcff516023c5d' (2023-06-11)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox':
    'git+ssh://git@github.com/flox/flox?ref=latest&rev=1ab9bb637a4871c9a8cf9ceaefa1f5b9d8bc8234' (2023-06-15)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane':
    'github:ipetkov/crane/75f7d715f8088f741be9981405f6444e2d49efdd' (2023-06-13)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/flake-compat':
    'github:edolstra/flake-compat/35bb57c0c8d8b62bbfd284272c928ceb64ddbde9' (2023-01-17)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/flake-utils':
    'github:numtide/flake-utils/a1720a10a6cfe8234c0e93907ffe81be440f4cef' (2023-05-31)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/flake-utils/systems':
    'github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e' (2023-04-09)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/nixpkgs':
    'github:NixOS/nixpkgs/c6ffce3d5df7b4c588ce80a0c6e2d2348a611707' (2023-06-02)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/rust-overlay':
    'github:oxalica/rust-overlay/c535b4f3327910c96dcf21851bbdd074d0760290' (2023-06-03)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/rust-overlay/flake-utils':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/flake-utils'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/rust-overlay/nixpkgs':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/nixpkgs'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/floco':
    'github:aakropotkin/floco/e1231f054258f7d62652109725881767765b1efb' (2023-05-16)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/floco/nixpkgs':
    'github:NixOS/nixpkgs/cfb43ad7b941d9c3606fb35d91228da7ebddbfc5' (2023-01-20)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/flox-floxpkgs':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks':
    'github:cachix/pre-commit-hooks.nix/5b6b54d3f722aa95cbf4ddbe35390a0af8c0015a' (2023-06-13)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/flake-compat':
    'github:edolstra/flake-compat/35bb57c0c8d8b62bbfd284272c928ceb64ddbde9' (2023-01-17)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/flake-utils':
    'github:numtide/flake-utils/a1720a10a6cfe8234c0e93907ffe81be440f4cef' (2023-05-31)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/flake-utils/systems':
    'github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e' (2023-04-09)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/gitignore':
    'github:hercules-ci/gitignore.nix/a20de23b925fd8264fd7fad6454652e142fd7f73' (2022-08-14)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/gitignore/nixpkgs':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/nixpkgs'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/nixpkgs':
    'github:NixOS/nixpkgs/a53a3bec10deef6e1cc1caba5bc60f53b959b1e8' (2023-06-04)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/nixpkgs-stable':
    'github:NixOS/nixpkgs/c37ca420157f4abc31e26f436c1145f8951ff373' (2023-06-03)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs':
    'github:flox/nixpkgs-flox/48e8d0cfdc7bc98e9bf4d65a67ea324b3d952ea7' (2023-06-14)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/capacitor':
    'github:flox/capacitor/0694a193660db2cb1a7a6e04949478b25f81d802' (2023-02-05)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/capacitor/nixpkgs':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/capacitor/nixpkgs-lib':
    'github:nix-community/nixpkgs.lib/a08e40a9bc625b7ee428bd7b64cdcff516023c5d' (2023-06-11)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/flox':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/flox-floxpkgs':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs-stable'
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs-stable':
    'github:flox/nixpkgs/7084250df3d7f9735087d3234407f3c1fc2400e3' (2023-05-22)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs-staging':
    'github:flox/nixpkgs/7084250df3d7f9735087d3234407f3c1fc2400e3' (2023-05-22)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs-unstable':
    'github:flox/nixpkgs/7084250df3d7f9735087d3234407f3c1fc2400e3' (2023-05-22)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__aarch64-darwin':
    'github:flox/nixpkgs-flox/7800311cb0d5c8970021f9f6691115feb0be7c04' (2023-06-14)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__aarch64-linux':
    'github:flox/nixpkgs-flox/234e8b5adf58fe3b1b6a33680f0a6ba8d8b639d0' (2023-06-14)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__i686-linux':
    'github:flox/nixpkgs-flox/cd8107202cd66d4047d2f1decb29cf03ad6195cd' (2023-06-14)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__x86_64-darwin':
    'github:flox/nixpkgs-flox/21a6177aae1307aaabc94cacff8f729495fa9df0' (2023-06-14)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__x86_64-linux':
    'github:flox/nixpkgs-flox/209643b52be208bca6eae3a8df22a2e9ea8c175f' (2023-06-14)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/tracelinks':
    'git+ssh://git@github.com/flox/tracelinks?ref=main&rev=e05561bdd0ed9d10c66e35a1d8e66defab949534' (2023-05-12)
• Added input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/tracelinks/flox-floxpkgs':
    follows 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs'
• Added input 'flox/flox-floxpkgs/flox':
    'git+ssh://git@github.com/flox/flox?ref=latest&rev=1ab9bb637a4871c9a8cf9ceaefa1f5b9d8bc8234' (2023-06-15)
• Added input 'flox/flox-floxpkgs/flox/crane':
    'github:ipetkov/crane/75f7d715f8088f741be9981405f6444e2d49efdd' (2023-06-13)
• Added input 'flox/flox-floxpkgs/flox/crane/flake-compat':
    'github:edolstra/flake-compat/35bb57c0c8d8b62bbfd284272c928ceb64ddbde9' (2023-01-17)
• Added input 'flox/flox-floxpkgs/flox/crane/flake-utils':
    'github:numtide/flake-utils/a1720a10a6cfe8234c0e93907ffe81be440f4cef' (2023-05-31)
• Added input 'flox/flox-floxpkgs/flox/crane/flake-utils/systems':
    'github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e' (2023-04-09)
• Added input 'flox/flox-floxpkgs/flox/crane/nixpkgs':
    'github:NixOS/nixpkgs/c6ffce3d5df7b4c588ce80a0c6e2d2348a611707' (2023-06-02)
• Added input 'flox/flox-floxpkgs/flox/crane/rust-overlay':
    'github:oxalica/rust-overlay/c535b4f3327910c96dcf21851bbdd074d0760290' (2023-06-03)
• Added input 'flox/flox-floxpkgs/flox/crane/rust-overlay/flake-utils':
    follows 'flox/flox-floxpkgs/flox/crane/flake-utils'
• Added input 'flox/flox-floxpkgs/flox/crane/rust-overlay/nixpkgs':
    follows 'flox/flox-floxpkgs/flox/crane/nixpkgs'
• Added input 'flox/flox-floxpkgs/flox/floco':
    'github:aakropotkin/floco/e1231f054258f7d62652109725881767765b1efb' (2023-05-16)
• Added input 'flox/flox-floxpkgs/flox/floco/nixpkgs':
    'github:NixOS/nixpkgs/cfb43ad7b941d9c3606fb35d91228da7ebddbfc5' (2023-01-20)
• Added input 'flox/flox-floxpkgs/flox/flox-floxpkgs':
    follows 'flox/flox-floxpkgs'
• Added input 'flox/flox-floxpkgs/flox/shellHooks':
    'github:cachix/pre-commit-hooks.nix/5b6b54d3f722aa95cbf4ddbe35390a0af8c0015a' (2023-06-13)
• Added input 'flox/flox-floxpkgs/flox/shellHooks/flake-compat':
    'github:edolstra/flake-compat/35bb57c0c8d8b62bbfd284272c928ceb64ddbde9' (2023-01-17)
• Added input 'flox/flox-floxpkgs/flox/shellHooks/flake-utils':
    'github:numtide/flake-utils/a1720a10a6cfe8234c0e93907ffe81be440f4cef' (2023-05-31)
• Added input 'flox/flox-floxpkgs/flox/shellHooks/flake-utils/systems':
    'github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e' (2023-04-09)
• Added input 'flox/flox-floxpkgs/flox/shellHooks/gitignore':
    'github:hercules-ci/gitignore.nix/a20de23b925fd8264fd7fad6454652e142fd7f73' (2022-08-14)
• Added input 'flox/flox-floxpkgs/flox/shellHooks/gitignore/nixpkgs':
    follows 'flox/flox-floxpkgs/flox/shellHooks/nixpkgs'
• Added input 'flox/flox-floxpkgs/flox/shellHooks/nixpkgs':
    'github:NixOS/nixpkgs/a53a3bec10deef6e1cc1caba5bc60f53b959b1e8' (2023-06-04)
• Added input 'flox/flox-floxpkgs/flox/shellHooks/nixpkgs-stable':
    'github:NixOS/nixpkgs/c37ca420157f4abc31e26f436c1145f8951ff373' (2023-06-03)
• Added input 'flox/flox-floxpkgs/nixpkgs':
    'github:flox/nixpkgs-flox/7ef6e4b3523b3d4d0d6ba5bd6c945671fa965c99' (2023-06-26)
• Added input 'flox/flox-floxpkgs/nixpkgs/capacitor':
    'github:flox/capacitor/0694a193660db2cb1a7a6e04949478b25f81d802' (2023-02-05)
• Added input 'flox/flox-floxpkgs/nixpkgs/capacitor/nixpkgs':
    follows 'flox/flox-floxpkgs/nixpkgs/nixpkgs'
• Added input 'flox/flox-floxpkgs/nixpkgs/capacitor/nixpkgs-lib':
    'github:nix-community/nixpkgs.lib/b3ec8fb525fc0c8f08eff5ef93c684b4c6d0e777' (2023-06-25)
• Added input 'flox/flox-floxpkgs/nixpkgs/flox':
    follows 'flox/flox-floxpkgs/flox'
• Added input 'flox/flox-floxpkgs/nixpkgs/flox-floxpkgs':
    follows 'flox/flox-floxpkgs'
• Added input 'flox/flox-floxpkgs/nixpkgs/nixpkgs':
    follows 'flox/flox-floxpkgs/nixpkgs/nixpkgs-stable'
• Added input 'flox/flox-floxpkgs/nixpkgs/nixpkgs-stable':
    'github:flox/nixpkgs/7084250df3d7f9735087d3234407f3c1fc2400e3' (2023-05-22)
• Added input 'flox/flox-floxpkgs/nixpkgs/nixpkgs-staging':
    'github:flox/nixpkgs/f742512ccc99e6ac457d6d4ddce78f283c4bbfde' (2023-06-25)
• Added input 'flox/flox-floxpkgs/nixpkgs/nixpkgs-unstable':
    'github:flox/nixpkgs/1c9db9710cb23d60570ad4d7ab829c2d34403de3' (2023-06-25)
• Added input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__aarch64-darwin':
    'github:flox/nixpkgs-flox/026a271a78fa569989010b6ebdba66381870cde7' (2023-06-26)
• Added input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__aarch64-linux':
    'github:flox/nixpkgs-flox/67623a9ab10d435557920e9a598ba8d7632fe48c' (2023-06-26)
• Added input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__i686-linux':
    'github:flox/nixpkgs-flox/bab1f9dcf3ebd32e7fd09daa71300c1e0e52cb9d' (2023-06-26)
• Added input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__x86_64-darwin':
    'github:flox/nixpkgs-flox/9322182bb1d53541954eabe274e041b3bedbbb57' (2023-06-26)
• Added input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__x86_64-linux':
    'github:flox/nixpkgs-flox/ff93610b257d149a5c5cf2ee2b9b90f9ed92b587' (2023-06-26)
• Added input 'flox/flox-floxpkgs/tracelinks':
    'git+ssh://git@github.com/flox/tracelinks?ref=main&rev=e05561bdd0ed9d10c66e35a1d8e66defab949534' (2023-05-12)
• Added input 'flox/flox-floxpkgs/tracelinks/flox-floxpkgs':
    follows 'flox/flox-floxpkgs'
• Added input 'flox/shellHooks':
    'github:cachix/pre-commit-hooks.nix/1fa438eee82f35bdd4bc30a9aacd7648d757b388' (2023-06-26)
• Added input 'flox/shellHooks/flake-compat':
    'github:edolstra/flake-compat/35bb57c0c8d8b62bbfd284272c928ceb64ddbde9' (2023-01-17)
• Added input 'flox/shellHooks/flake-utils':
    'github:numtide/flake-utils/a1720a10a6cfe8234c0e93907ffe81be440f4cef' (2023-05-31)
• Added input 'flox/shellHooks/flake-utils/systems':
    'github:nix-systems/default/da67096a3b9bf56a91d16901293e51ba5b49a27e' (2023-04-09)
• Added input 'flox/shellHooks/gitignore':
    'github:hercules-ci/gitignore.nix/a20de23b925fd8264fd7fad6454652e142fd7f73' (2022-08-14)
• Added input 'flox/shellHooks/gitignore/nixpkgs':
    follows 'flox/shellHooks/nixpkgs'
• Added input 'flox/shellHooks/nixpkgs':
    'github:NixOS/nixpkgs/a53a3bec10deef6e1cc1caba5bc60f53b959b1e8' (2023-06-04)
• Added input 'flox/shellHooks/nixpkgs-stable':
    'github:NixOS/nixpkgs/c37ca420157f4abc31e26f436c1145f8951ff373' (2023-06-03)
warning: Git tree '/Users/hkailahi/.config/dotnix' is dirty
Starting Home Manager activation
Activating checkFilesChanged
Activating checkLaunchAgents
Activating checkLinkTargets
Activating writeBoundary
Activating copyFonts
Activating installPackages
replacing old 'home-manager-path'
installing 'home-manager-path'
Activating linkGeneration
Cleaning up orphan links from /Users/hkailahi
No change so reusing latest profile generation 60
Creating home file links in /Users/hkailahi
Activating onFilesChange
Activating setupLaunchAgents
~/.config/dotnix
```
</details>

Looks like that downloaded a bunch of stuff, but wasn't enough to make `flox` available:
```bash
$ flox --version
-bash: flox: command not found
```

I tried restarting my `nix-daemon`  as described in `Nix/Generic`, followed by re-applying my system config. Still no `flox`.

Oh whoops I guess I should have read "Install with existing Nix installation" section first but looks like my assumption to follow `Nix/NixOS` section was fine. And that section covers my concerns.

Suggestions:
- (Weak) Renaming with something like `Nix/Generic` -> `Nix` and `Nix/NixOS` -> `Nix/NixOS (Declarative)` to make it more clear to me
- (Weak) Adding small warning about needing to re-install Nix to recover previous declarative Nix setup to `Nix (Declarative)` section in addition it

Back to installation. Maybe my flake is wrong? I [searched on Github](https://github.com/search?utf8=%E2%9C%93&q=inputs.flox.url&type=code) for `inputs.flox.url` and saw the following:

```nix:flake.nix
inputs.flox.url = "git+ssh://git@github.com/flox/flox?ref=latest";
inputs.flox.inputs.flox-floxpkgs.follows = "";
```

Trying that didn't fix it:

<details>

```diff
+    flox.url = "git+ssh://git@github.com/flox/flox?ref=latest";
+    flox.inputs.flox-floxpkgs.follows = "";
   };
```

```bash
$ ./bin/apply-system.sh
~/.config/dotnix ~/.config/dotnix
warning: Git tree '/Users/hkailahi/.config/dotnix' is dirty
warning: updating lock file '/Users/hkailahi/.config/dotnix/flake.lock':
• Updated input 'flox':
    'github:flox/flox/35e79112dab96895f43fa9b34d1149471b5f138e' (2023-06-30)
  → 'git+ssh://git@github.com/flox/flox?ref=latest&rev=f19cb5f907f077d4ebe54a497c9f20b90586f0da' (2023-06-29)
• Updated input 'flox/flox-floxpkgs':
    'github:flox/floxpkgs/1a3a66ba4303de673a673816ab9a4c874cddfa25' (2023-06-28)
  → follows ''
• Removed input 'flox/flox-floxpkgs/builtfilter'
• Removed input 'flox/flox-floxpkgs/builtfilter/flox-floxpkgs'
• Removed input 'flox/flox-floxpkgs/capacitor'
• Removed input 'flox/flox-floxpkgs/capacitor/nixpkgs'
• Removed input 'flox/flox-floxpkgs/capacitor/nixpkgs-lib'
• Removed input 'flox/flox-floxpkgs/etc-profiles'
• Removed input 'flox/flox-floxpkgs/etc-profiles/flox-floxpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/builtfilter'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/builtfilter/flox-floxpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/capacitor'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/capacitor/nixpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/capacitor/nixpkgs-lib'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/flake-compat'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/flake-utils'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/flake-utils/systems'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/nixpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/rust-overlay'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/rust-overlay/flake-utils'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/crane/rust-overlay/nixpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/floco'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/floco/nixpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/flox-floxpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/flake-compat'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/flake-utils'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/flake-utils/systems'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/gitignore'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/gitignore/nixpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/nixpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/flox/shellHooks/nixpkgs-stable'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/capacitor'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/capacitor/nixpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/capacitor/nixpkgs-lib'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/flox'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/flox-floxpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs-stable'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs-staging'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs-unstable'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__aarch64-darwin'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__aarch64-linux'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__i686-linux'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__x86_64-darwin'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/nixpkgs/nixpkgs__flox__x86_64-linux'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/tracelinks'
• Removed input 'flox/flox-floxpkgs/etc-profiles/ld-floxlib/flox-floxpkgs/tracelinks/flox-floxpkgs'
• Removed input 'flox/flox-floxpkgs/flox'
• Removed input 'flox/flox-floxpkgs/flox/crane'
• Removed input 'flox/flox-floxpkgs/flox/crane/flake-compat'
• Removed input 'flox/flox-floxpkgs/flox/crane/flake-utils'
• Removed input 'flox/flox-floxpkgs/flox/crane/flake-utils/systems'
• Removed input 'flox/flox-floxpkgs/flox/crane/nixpkgs'
• Removed input 'flox/flox-floxpkgs/flox/crane/rust-overlay'
• Removed input 'flox/flox-floxpkgs/flox/crane/rust-overlay/flake-utils'
• Removed input 'flox/flox-floxpkgs/flox/crane/rust-overlay/nixpkgs'
• Removed input 'flox/flox-floxpkgs/flox/floco'
• Removed input 'flox/flox-floxpkgs/flox/floco/nixpkgs'
• Removed input 'flox/flox-floxpkgs/flox/flox-floxpkgs'
• Removed input 'flox/flox-floxpkgs/flox/shellHooks'
• Removed input 'flox/flox-floxpkgs/flox/shellHooks/flake-compat'
• Removed input 'flox/flox-floxpkgs/flox/shellHooks/flake-utils'
• Removed input 'flox/flox-floxpkgs/flox/shellHooks/flake-utils/systems'
• Removed input 'flox/flox-floxpkgs/flox/shellHooks/gitignore'
• Removed input 'flox/flox-floxpkgs/flox/shellHooks/gitignore/nixpkgs'
• Removed input 'flox/flox-floxpkgs/flox/shellHooks/nixpkgs'
• Removed input 'flox/flox-floxpkgs/flox/shellHooks/nixpkgs-stable'
• Removed input 'flox/flox-floxpkgs/nixpkgs'
• Removed input 'flox/flox-floxpkgs/nixpkgs/capacitor'
• Removed input 'flox/flox-floxpkgs/nixpkgs/capacitor/nixpkgs'
• Removed input 'flox/flox-floxpkgs/nixpkgs/capacitor/nixpkgs-lib'
• Removed input 'flox/flox-floxpkgs/nixpkgs/flox'
• Removed input 'flox/flox-floxpkgs/nixpkgs/flox-floxpkgs'
• Removed input 'flox/flox-floxpkgs/nixpkgs/nixpkgs'
• Removed input 'flox/flox-floxpkgs/nixpkgs/nixpkgs-stable'
• Removed input 'flox/flox-floxpkgs/nixpkgs/nixpkgs-staging'
• Removed input 'flox/flox-floxpkgs/nixpkgs/nixpkgs-unstable'
• Removed input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__aarch64-darwin'
• Removed input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__aarch64-linux'
• Removed input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__i686-linux'
• Removed input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__x86_64-darwin'
• Removed input 'flox/flox-floxpkgs/nixpkgs/nixpkgs__flox__x86_64-linux'
• Removed input 'flox/flox-floxpkgs/tracelinks'
• Removed input 'flox/flox-floxpkgs/tracelinks/flox-floxpkgs'
warning: Git tree '/Users/hkailahi/.config/dotnix' is dirty
Starting Home Manager activation
Activating checkFilesChanged
Activating checkLaunchAgents
Activating checkLinkTargets
Activating writeBoundary
Activating copyFonts
Activating installPackages
replacing old 'home-manager-path'
installing 'home-manager-path'
Activating linkGeneration
Cleaning up orphan links from /Users/hkailahi
No change so reusing latest profile generation 60
Creating home file links in /Users/hkailahi
Activating onFilesChange
Activating setupLaunchAgents
~/.config/dotnix
-bash-3.2$ flox --version
-bash: flox: command not found
```
</details>

Bummer. Ok I'll try actually following the steps and doing a `nix profile install`. I'm fairly confident I can do a reinstall. Since I was managing my nix settings in `home.nix` instead of the `nix.conf`, I might need to revisit adding the substituter. Though, as mentioned above, I haven't had much luck changes to my `nix.conf` file actually getting picked up by nix for whatever reason.

Suggestions:
- (Moderate) Directions make it seem like both personal profile _and_ default profile installation should be done. Is that intended? I assume not and will just do the former.

<details>

```bash
$ nix --version
nix (Nix) 2.15.1
```

Doing personal profile install:
```bash
$ nix profile install --impure \
>   --experimental-features "nix-command flakes" \
>   --accept-flake-config \
>   'github:flox/floxpkgs#flox.fromCatalog'
warning: ignoring untrusted substituter 'https://cache.floxdev.com'
error: interrupted by the user
```

`Ctrl-C`'d. Looks like I do need to add that substituter.
```diff
+    extra-trusted-substituters = https://cache.floxdev.com ...
+    extra-trusted-public-keys = flox-store-public-0:8c/B+kjIaQ+BloCmNkRUKwaVPFWkriSAd0JJvuDu4F0= ...
```

```bash
$ sudo launchctl stop org.nixos.nix-daemon
$ sudo launchctl start org.nixos.nix-daemon
```

Trying install again:
```bash
$ nix profile install --impure \
>       --experimental-features "nix-command flakes" \
>       --accept-flake-config \
>       'github:flox/floxpkgs#flox.fromCatalog'
$ flox --version
Version: 0.2.3-r530
```
</details>

Install done. Things look good 👍

### [flox in 5 minutes](https://floxdev.com/docs/)

Cloning and building:

<details>

```bash
$ git clone https://github.com/flox-examples/rust-env-demo.git
Cloning into 'rust-env-demo'...
remote: Enumerating objects: 52, done.
remote: Counting objects: 100% (52/52), done.
remote: Compressing objects: 100% (29/29), done.
remote: Total 52 (delta 9), reused 42 (delta 3), pack-reused 0
Receiving objects: 100% (52/52), 10.08 KiB | 3.36 MiB/s, done.
Resolving deltas: 100% (9/9), done.
$ cd rust-env-demo/
```

```bash
$ flox develop
Updating "/Users/hkailahi/.config/flox/gitconfig"
flox collects basic usage metrics in order to improve the user experience.

    flox includes a record of the subcommand invoked along with a unique token.
    It does not collect any personal information.

    Example metric for this invocation:

    {
      "empty_flags": [],
      "flox_version": "0.2.3-r530",
      "os": null,
      "os_family": "Mac OS",
      "os_family_release": "22.5.0",
      "os_version": null,
      "subcommand": "[subcommand]",
      "timestamp": "2023-06-30 18:32:17.291973 +00:00:00",
      "uuid": "3195cd8a-43e7-45c0-b76a-a03bebaa37b9"
    }

    The collection of metrics can be disabled in the following ways:

      environment: FLOX_DISABLE_METRICS=true
        user-wide: flox config --set-bool disable_metrics true
      system-wide: update /etc/flox.toml as described in flox(1)


Updating "/Users/hkailahi/.config/flox/nix.conf"
warning: remote HEAD refers to nonexistent ref, unable to checkout
Select package for 'flox develop'

HINT: avoid selecting a package next time with:
$ flox develop -A rust-env

...
```

It's been hanging for bit but I assume it's doing configurations?

Ok there it goes:
```bash

warning: not writing modified lock file of flake 'git+file:///Users/hkailahi/scratch/rust-env-demo':
• Updated input 'flox-floxpkgs/nixpkgs/nixpkgs':
    follows 'flox-floxpkgs/nixpkgs/nixpkgs-stable'
  → 'github:flox/nixpkgs/7084250df3d7f9735087d3234407f3c1fc2400e3' (2023-05-22)
```
</details>

Interesting. I see that I'm now inside some sort of nix shell.

Suggestions:
- (Moderate) Some kind of loading indicator or "Downloading blah.." message HINT step so that I know it's making progress and don't Ctrl-C out

Running:
<details>

```bash
(nix:nix-shell-env)040bash-5.2$ cargo run
    Updating crates.io index
  Downloaded pkg-config v0.3.27
  Downloaded cc v1.0.79
  Downloaded socket2 v0.4.9
  Downloaded curl v0.4.44
  Downloaded libc v0.2.144
  Downloaded libz-sys v1.1.9
  Downloaded curl-sys v0.4.62+curl-8.1.0
  Downloaded libnghttp2-sys v0.1.7+1.45.0
  Downloaded 8 crates (11.0 MB) in 6.18s (largest was `libnghttp2-sys` at 4.5 MB)
   Compiling cc v1.0.79
   Compiling pkg-config v0.3.27
   Compiling libc v0.2.144
   Compiling curl v0.4.44
   Compiling libz-sys v1.1.9
   Compiling libnghttp2-sys v0.1.7+1.45.0
   Compiling curl-sys v0.4.62+curl-8.1.0
   Compiling socket2 v0.4.9
   Compiling rust-env-demo v0.1.0 (/Users/hkailahi/scratch/rust-env-demo)
    Finished dev [unoptimized + debuginfo] target(s) in 2m 15s
     Running `target/debug/rust-env-demo`
<!doctype html>
<html lang="en-US">
  <head>
    <meta charset="utf-8">
    <title>
            Rust Programming Language
        </title>
...

(nix:nix-shell-env)040bash-5.2$ cargo clippy
    Checking libc v0.2.144
    Checking libnghttp2-sys v0.1.7+1.45.0
    Checking libz-sys v1.1.9
    Checking socket2 v0.4.9
    Checking curl-sys v0.4.62+curl-8.1.0
    Checking curl v0.4.44
    Checking rust-env-demo v0.1.0 (/Users/hkailahi/scratch/rust-env-demo)
    Finished dev [unoptimized + debuginfo] target(s) in 1.50s
(nix:nix-shell-env)040bash-5.2$
(nix:nix-shell-env)040bash-5.2$ just profile
   Compiling cc v1.0.79
   Compiling pkg-config v0.3.27
   Compiling libc v0.2.144
   Compiling curl v0.4.44
   Compiling libz-sys v1.1.9
   Compiling libnghttp2-sys v0.1.7+1.45.0
   Compiling curl-sys v0.4.62+curl-8.1.0
   Compiling socket2 v0.4.9
   Compiling rust-env-demo v0.1.0 (/Users/hkailahi/scratch/rust-env-demo)
    Finished release [optimized + debuginfo] target(s) in 8.41s
automatically selected target rust-env-demo in package rust-env-demo as it is the only valid target
    Finished release [optimized + debuginfo] target(s) in 0.03s
Password:
sudo: a password is required
failed to sample program

(nix:nix-shell-env)040bash-5.2$ exit
exit
```

Ctrl-C'd out of sudo step. Everything seems good 👍
</details>

Demo works! Normally I would've just followed along without downloading the `flox` or cloning the repo.

Suggestions:
- (Weak) Step asking me for my password was unexpected
- (Weak) Now I'm wondering if there's a similiar demo project for `python` or other languages. That said this all made sense without me having to know rust or much about its ecosystem.

### Tutorials
#### [Project Environments](https://floxdev.com/docs/tutorials/projects/)

Initializing sample project:
<details>

```bash
$ mkdir example-project && cd example-project
$ flox init --template project
ERROR: You must be inside of a Git repository to initialize a project

    To provide the best possible experience, projects must be under version control.
    Please initialize a project in an existing repo or create one using 'git init'.
```

Slightly different than the docs which ask whether I want git repo initialized for me.

```bash
$ git init
hint: Using 'master' as the name for the initial branch. This default branch name
hint: is subject to change. To configure the initial branch name to use in all
hint: of your new repositories, which will suppress this warning, call:
hint:
hint: 	git config --global init.defaultBranch <name>
hint:
hint: Names commonly chosen instead of 'master' are 'main', 'trunk' and
hint: 'development'. The just-created branch can be renamed via this command:
hint:
hint: 	git branch -m <name>
Initialized empty Git repository in /Users/hkailahi/scratch/example-project/.git/
$ git config --global init.defaultBranch main
$ git init
Reinitialized existing Git repository in /Users/hkailahi/scratch/example-project/.git/
```

```bash
$ flox init --template project
Found git repo: /Users/hkailahi/scratch/example-project
> Enter package name example-project
[INFO] [flox_rust_sdk::models::project] moved: /Users/hkailahi/scratch/example-project/shells/__PACKAGE_NAME__ -> /Users/hkailahi/scratch/example-project/shells/example-project
Run 'flox develop' to enter the project environment.
```

```bash
$ flox develop
warning: not writing modified lock file of flake 'git+file:///Users/hkailahi/scratch/example-project':
• Updated input 'flox-floxpkgs/nixpkgs/nixpkgs':
    follows 'flox-floxpkgs/nixpkgs/nixpkgs-stable'
  → 'github:flox/nixpkgs/7084250df3d7f9735087d3234407f3c1fc2400e3' (2023-05-22)
GNU Make 4.4.1
Built for x86_64-apple-darwin22.1.0
Copyright (C) 1988-2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Run make to build this project
(nix:nix-shell-env)040bash-5.2$
```
</details>

Using project environment:
<details>

```bash
# within `flox develop` shell
(nix:nix-shell-env)040bash-5.2$ flox nix search nixpkgs openssl
* legacyPackages.x86_64-darwin.chickenPackages_5.chickenEggs.openssl (2.2.4)
  Bindings to the OpenSSL SSL/TLS library
trace: warning: qt5 now uses makeScopeWithSplicing which does not have "overrideScope'", use "overrideScope".

* legacyPackages.x86_64-darwin.lua51Packages.lua-resty-openssl (0.8.17-1)
  No summary

* legacyPackages.x86_64-darwin.lua51Packages.luaossl (20220711-0)
  Most comprehensive OpenSSL module in the Lua universe.

* legacyPackages.x86_64-darwin.lua51Packages.luasec (1.2.0-1)
  A binding for OpenSSL library to provide TLS/SSL communication over LuaSocket.

* legacyPackages.x86_64-darwin.lua52Packages.lua-resty-openssl (0.8.17-1)
  No summary

* legacyPackages.x86_64-darwin.lua52Packages.luaossl (20220711-0)
  Most comprehensive OpenSSL module in the Lua universe.

* legacyPackages.x86_64-darwin.lua52Packages.luasec (1.2.0-1)
  A binding for OpenSSL library to provide TLS/SSL communication over LuaSocket.

* legacyPackages.x86_64-darwin.lua53Packages.lua-resty-openssl (0.8.17-1)
  No summary

* legacyPackages.x86_64-darwin.lua53Packages.luaossl (20220711-0)
  Most comprehensive OpenSSL module in the Lua universe.

* legacyPackages.x86_64-darwin.lua53Packages.luasec (1.2.0-1)
  A binding for OpenSSL library to provide TLS/SSL communication over LuaSocket.

* legacyPackages.x86_64-darwin.lua54Packages.lua-resty-openssl (0.8.17-1)
  No summary

* legacyPackages.x86_64-darwin.lua54Packages.luaossl (20220711-0)
  Most comprehensive OpenSSL module in the Lua universe.

* legacyPackages.x86_64-darwin.lua54Packages.luasec (1.2.0-1)
  A binding for OpenSSL library to provide TLS/SSL communication over LuaSocket.

* legacyPackages.x86_64-darwin.luaPackages.lua-resty-openssl (0.8.17-1)
  No summary

* legacyPackages.x86_64-darwin.luaPackages.luaossl (20220711-0)
  Most comprehensive OpenSSL module in the Lua universe.

* legacyPackages.x86_64-darwin.luaPackages.luasec (1.2.0-1)
  A binding for OpenSSL library to provide TLS/SSL communication over LuaSocket.

* legacyPackages.x86_64-darwin.luajitPackages.lua-resty-openssl (0.8.17-1)
  No summary

* legacyPackages.x86_64-darwin.luajitPackages.luaossl (20220711-0)
  Most comprehensive OpenSSL module in the Lua universe.

* legacyPackages.x86_64-darwin.luajitPackages.luasec (1.2.0-1)
  A binding for OpenSSL library to provide TLS/SSL communication over LuaSocket.

* legacyPackages.x86_64-darwin.ocamlPackages.lwt_ssl (1.2.0)
  OpenSSL binding with concurrent I/O

* legacyPackages.x86_64-darwin.openconnect_openssl (9.12)
  VPN Client for Cisco's AnyConnect SSL VPN

* legacyPackages.x86_64-darwin.openssl (3.0.9)
  A cryptographic library that implements the SSL and TLS protocols

* legacyPackages.x86_64-darwin.openssl_1_1 (1.1.1u)
  A cryptographic library that implements the SSL and TLS protocols

* legacyPackages.x86_64-darwin.openssl_3 (3.0.9)
  A cryptographic library that implements the SSL and TLS protocols

* legacyPackages.x86_64-darwin.openssl_3_0 (3.0.9)
  A cryptographic library that implements the SSL and TLS protocols

* legacyPackages.x86_64-darwin.openssl_legacy (3.0.9)
  A cryptographic library that implements the SSL and TLS protocols

* legacyPackages.x86_64-darwin.osslsigncode (2.5)
  OpenSSL based Authenticode signing for PE/MSI/Java CAB files

* legacyPackages.x86_64-darwin.perl534Packages.CryptOpenSSLAES (0.02)
  Perl wrapper around OpenSSL's AES library

* legacyPackages.x86_64-darwin.perl534Packages.CryptOpenSSLBignum (0.09)
  OpenSSL's multiprecision integer arithmetic

* legacyPackages.x86_64-darwin.perl534Packages.CryptOpenSSLGuess (0.15)
  Guess OpenSSL include path

* legacyPackages.x86_64-darwin.perl534Packages.CryptOpenSSLRSA (0.33)
  RSA encoding and decoding, using the openSSL libraries

* legacyPackages.x86_64-darwin.perl534Packages.CryptOpenSSLRandom (0.15)
  OpenSSL/LibreSSL pseudo-random number generator access

* legacyPackages.x86_64-darwin.perl534Packages.CryptOpenSSLX509 (1.914)
  Perl extension to OpenSSL's X509 API

* legacyPackages.x86_64-darwin.perl534Packages.CryptSSLeay (0.73_06)
  OpenSSL support for LWP

* legacyPackages.x86_64-darwin.perl534Packages.NetSSLeay (1.92)
  Perl bindings for OpenSSL and LibreSSL

* legacyPackages.x86_64-darwin.perl536Packages.CryptOpenSSLAES (0.02)
  Perl wrapper around OpenSSL's AES library

* legacyPackages.x86_64-darwin.perl536Packages.CryptOpenSSLBignum (0.09)
  OpenSSL's multiprecision integer arithmetic

* legacyPackages.x86_64-darwin.perl536Packages.CryptOpenSSLGuess (0.15)
  Guess OpenSSL include path

* legacyPackages.x86_64-darwin.perl536Packages.CryptOpenSSLRSA (0.33)
  RSA encoding and decoding, using the openSSL libraries

* legacyPackages.x86_64-darwin.perl536Packages.CryptOpenSSLRandom (0.15)
  OpenSSL/LibreSSL pseudo-random number generator access

* legacyPackages.x86_64-darwin.perl536Packages.CryptOpenSSLX509 (1.914)
  Perl extension to OpenSSL's X509 API

* legacyPackages.x86_64-darwin.perl536Packages.CryptSSLeay (0.73_06)
  OpenSSL support for LWP

* legacyPackages.x86_64-darwin.perl536Packages.NetSSLeay (1.92)
  Perl bindings for OpenSSL and LibreSSL

* legacyPackages.x86_64-darwin.perlPackages.CryptOpenSSLAES (0.02)
  Perl wrapper around OpenSSL's AES library

* legacyPackages.x86_64-darwin.perlPackages.CryptOpenSSLBignum (0.09)
  OpenSSL's multiprecision integer arithmetic

* legacyPackages.x86_64-darwin.perlPackages.CryptOpenSSLGuess (0.15)
  Guess OpenSSL include path

* legacyPackages.x86_64-darwin.perlPackages.CryptOpenSSLRSA (0.33)
  RSA encoding and decoding, using the openSSL libraries

* legacyPackages.x86_64-darwin.perlPackages.CryptOpenSSLRandom (0.15)
  OpenSSL/LibreSSL pseudo-random number generator access

* legacyPackages.x86_64-darwin.perlPackages.CryptOpenSSLX509 (1.914)
  Perl extension to OpenSSL's X509 API

* legacyPackages.x86_64-darwin.perlPackages.CryptSSLeay (0.73_06)
  OpenSSL support for LWP

* legacyPackages.x86_64-darwin.perlPackages.NetSSLeay (1.92)
  Perl bindings for OpenSSL and LibreSSL

* legacyPackages.x86_64-darwin.php81Extensions.openssl (8.1.20)
  PHP upstream extension: openssl

* legacyPackages.x86_64-darwin.php81Extensions.openssl-legacy (8.1.20)
  PHP upstream extension: openssl-legacy

* legacyPackages.x86_64-darwin.php82Extensions.openssl (8.2.7)
  PHP upstream extension: openssl

* legacyPackages.x86_64-darwin.php82Extensions.openssl-legacy (8.2.7)
  PHP upstream extension: openssl-legacy

* legacyPackages.x86_64-darwin.php83Extensions.openssl (8.3.0alpha2)
  PHP upstream extension: openssl

* legacyPackages.x86_64-darwin.php83Extensions.openssl-legacy (8.3.0alpha2)
  PHP upstream extension: openssl-legacy

* legacyPackages.x86_64-darwin.python310Packages.aioopenssl (0.6.0)
  TLS-capable transport using OpenSSL for asyncio

* legacyPackages.x86_64-darwin.python310Packages.certipy (0.1.3)
  wrapper for pyOpenSSL

* legacyPackages.x86_64-darwin.python310Packages.ndg-httpsclient (0.5.1)
  Provide enhanced HTTPS support for httplib and urllib2 using PyOpenSSL

* legacyPackages.x86_64-darwin.python310Packages.pyopenssl (23.1.1)
  Python wrapper around the OpenSSL library

* legacyPackages.x86_64-darwin.python310Packages.service-identity (21.1.0)
  Service identity verification for pyOpenSSL

* legacyPackages.x86_64-darwin.python310Packages.types-pyopenssl (23.2.0.0)
  Typing stubs for pyopenssl

* legacyPackages.x86_64-darwin.python311Packages.aioopenssl (0.6.0)
  TLS-capable transport using OpenSSL for asyncio

* legacyPackages.x86_64-darwin.python311Packages.certipy (0.1.3)
  wrapper for pyOpenSSL

* legacyPackages.x86_64-darwin.python311Packages.ndg-httpsclient (0.5.1)
  Provide enhanced HTTPS support for httplib and urllib2 using PyOpenSSL

* legacyPackages.x86_64-darwin.python311Packages.pyopenssl (23.1.1)
  Python wrapper around the OpenSSL library

* legacyPackages.x86_64-darwin.python311Packages.service-identity (21.1.0)
  Service identity verification for pyOpenSSL

* legacyPackages.x86_64-darwin.python311Packages.types-pyopenssl (23.2.0.0)
  Typing stubs for pyopenssl

* legacyPackages.x86_64-darwin.rubyPackages.openssl (3.1.0)

* legacyPackages.x86_64-darwin.rubyPackages_2_7.openssl (3.1.0)

* legacyPackages.x86_64-darwin.rubyPackages_3_0.openssl (3.1.0)

* legacyPackages.x86_64-darwin.rubyPackages_3_1.openssl (3.1.0)

* legacyPackages.x86_64-darwin.rubyPackages_3_2.openssl (3.1.0)

* legacyPackages.x86_64-darwin.sgx-ssl (2.16_1.1.1l)
  Cryptographic library for Intel SGX enclave applications based on OpenSSL

* legacyPackages.x86_64-darwin.tcltls (1.7.22)
  An OpenSSL / RSA-bsafe Tcl extension

$ exit
```
</details>

That was a lot.

Adding `openssl` to `default.nix`

<details>

```diff
 {
   gnumake,
   mkShell,
+  openssl,
   stdenv,
   zlib,
 }:
@@ -11,6 +12,7 @@
 mkShell {
   # Compilers and libraries go here
   buildInputs = [
+    openssl
     stdenv.cc
     zlib
   ];
```

```bash
$ flox develop
warning: not writing modified lock file of flake 'git+file:///Users/hkailahi/scratch/example-project':
• Updated input 'flox-floxpkgs/nixpkgs/nixpkgs':
    follows 'flox-floxpkgs/nixpkgs/nixpkgs-stable'
  → 'github:flox/nixpkgs/7084250df3d7f9735087d3234407f3c1fc2400e3' (2023-05-22)
GNU Make 4.4.1
Built for x86_64-apple-darwin22.1.0
Copyright (C) 1988-2023 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Run make to build this project
(nix:nix-shell-env)040bash-5.2$ which make
/nix/store/illvvpvgxw8sprvksnzgilc5r4mm6g30-gnumake-4.4.1/bin/make
```
</details>

Looks good. The tutorial made sense and covers the primary use case I'd want.

Suggestions:
- (Moderate) Add `git init` to documented steps and point out why its necessary
- (Weak) Say to rerun `flox init --template project` in failure message after `git init`
- (Moderate) Refine query in `flox nix search` step
- (Moderate) Pull `$ # add openssl to default.nix` out of middle of code block and say it plainly.
- (Weak) Use `diff` format for code blocks instead of `git diff`
- (Moderate) Motivate the tutorial by summarizing the final "Sharing the enviroment" up front.
  - > "Clone repo, run `flox develop`, and everyone will have a matching environment!"

#### [Managed Environments](https://floxdev.com/docs/tutorials/managed-environments/)

<details>

```bash
$ flox create -e managed-env
warning: remote HEAD refers to nonexistent ref, unable to checkout
created environment managed-env (x86_64-darwin)

$ flox subscribe flox-examples github:flox-examples/floxpkgs/master
warning: input 'nixpkgs' has an override for a non-existent input 'floxpkgs'
warning: input 'nixpkgs/flox' has an override for a non-existent input 'nixpkgs-flox'
warning: remote HEAD refers to nonexistent ref, unable to checkout
subscribed channel 'flox-examples'

$ flox install -e managed-env flox-examples.demo-dnd-server caddy procps curl jq
warning: remote HEAD refers to nonexistent ref, unable to checkout
warning: input 'nixpkgs' has an override for a non-existent input 'floxpkgs'
warning: input 'nixpkgs/flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'nixpkgs' has an override for a non-existent input 'floxpkgs'
warning: input 'nixpkgs/flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
error: path '/nix/store/gb3ci5v66qvkr1rahj3nax0zbckl8r1l-demo-dnd-server-0.0.0' does not exist and cannot be created
(use '--show-trace' to show detailed location information)

ERROR: failed to install packages: flake:flox-examples#evalCatalog.x86_64-darwin.stable.demo-dnd-server flake:nixpkgs-flox#evalCatalog.x86_64-darwin.stable.caddy flake:nixpkgs-flox#evalCatalog.x86_64-darwin.stable.procps flake:nixpkgs-flox#evalCatalog.x86_64-darwin.stable.curl flake:nixpkgs-flox#evalCatalog.x86_64-darwin.stable.jq
```

Looks like `flox-examples.demo-dnd-server` install failed. The rest was fine.
```bash
$ flox install -e managed-env caddy procps curl jq
warning: remote HEAD refers to nonexistent ref, unable to checkout
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
Installed 'caddy', 'procps', 'curl', 'jq' package(s) into 'managed-env' environment.
```

Revisiting `flox-examples.demo-dnd-server` with the `--show-trace` for more info as suggested gave an error.

```bash
$ flox install -e managed-env flox-examples.demo-dnd-server --show-trace
ERROR: No such flag: `--show-trace`, did you mean `--system`?

    install a package into an environment

    Usage: [-s SYSTEM] [-e ENV] <PACKAGES>...

    Available options:
      Environment Options
        -s, --system <SYSTEM>

        -e, --environment <ENV>
        -h, --help               Prints help information
```
</details>

I wasn't able to get this working. I only skimmed after installing stuff into my `managed-env` and the all the functionality described made sense.

Suggestions:
- (Strong) `flox-examples.demo-dnd-server` install failed
- (Strong) Underlying `--show-trace` from Nix is misleading since you can't use it with `flox` in an obvious way

#### [Build Container Images](https://floxdev.com/docs/tutorials/build-container-images/)

<details>

```bash
$ flox install hello
warning: remote HEAD refers to nonexistent ref, unable to checkout
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
warning: input 'flox' has an override for a non-existent input 'nixpkgs-flox'
Installed 'hello' package(s) into 'default' environment.

$ flox containerize | docker load
-bash: docker: command not found
Building container...
Done.
No 'fromImage' provided
Creating layer 1 from paths: ['/nix/store/sxwkpd5cl8nkfkr98q51b5mh4rwqqlk6-libcxxabi-11.1.0']

^CException in thread Thread-1 (producer):
Traceback (most recent call last)...
```

Ah right, I don't have `docker` accessible with my original system config gone. It would be nice to have nice provide docker/podman/etc provided.
</details>

Skimmed and made sense. This is a use case I'd want so it's nice to have a tutorial.

Suggestions:
- (Weak) Provide docker/podman/etc setup

#### [Custom Packages](https://floxdev.com/docs/tutorials/custom-packages/)

Skipped.

#### [Publish Custom Packages](https://floxdev.com/docs/tutorials/publish-custom-packages/)

Skipped.

### Integrations

#### [direnv](https://floxdev.com/docs/integrations/direnv/)

Skipped.

### Cookbook

Nit: Isn't plural like other sections

#### [Validate Identical dev/prod Environments](https://floxdev.com/docs/cookbook/validate-identical/)

Skipped.

#### [Managed Environments](https://floxdev.com/docs/cookbook/managed-environments/)

Skipped.

#### [Language Guides: Python](https://floxdev.com/docs/cookbook/language-guides/python/)

Skipped.

## [Uninstall flox](https://floxdev.com/docs/install-flox/#uninstall-flox)

Uninstalling now and reverting to my original setup. If this goes smoothly I'll try out `flox` further in the future.

```bash
$ nix profile remove \
    .*flox.fromCatalog \
    --experimental-features "nix-command flakes"
```

```bash
$ cd /Users/hkailahi/.config/dotnix
$ home-manager switch --flake .#hkailahi
warning: Git tree '/Users/hkailahi/.config/dotnix' is dirty
Starting Home Manager activation
Activating checkFilesChanged
Activating checkLaunchAgents
Activating checkLinkTargets
Activating writeBoundary
Activating copyFonts
Activating installPackages
nix profile remove /nix/store/0ghxq6l71v5r3mrw9kcbkn642lfzgix9-home-manager-path
removing 'home-manager-path'
Activating linkGeneration
Cleaning up orphan links from /Users/hkailahi
No change so reusing latest profile generation 60
Creating home file links in /Users/hkailahi
Activating onFilesChange
Activating setupLaunchAgents

$ bat --version
bat 0.23.0
$ nix profile list
0 - - /nix/store/0ghxq6l71v5r3mrw9kcbkn642lfzgix9-home-manager-path
```

Sweet! That was easy.
