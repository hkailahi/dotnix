#/!/bash

# Modify default registry.json (https://github.com/NixOS/flake-registry) to fit home-manager `nix.registry` option format
# Adapted from https://stackoverflow.com/a/42428341
cat registry.json | jq '.flakes | map( { (.from.id|tostring): . } ) | add' >> nix-readable-registry.json

# -bash-3.2$ ls -l /etc/nix/registry.json
# lrwxr-xr-x  1 root  wheel  29 Mar 27 21:20 /etc/nix/registry.json -> /etc/static/nix/registry.json
# cp ~/.config/dotnix/etc-nix/registry.json /etc/static/nix/