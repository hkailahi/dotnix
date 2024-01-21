#!/bin/sh

pushd ~/.config/dotnix
# home-manager switch --flake .#hkailahi
darwin-rebuild switch --flake ~/.config/dotnix
popd
