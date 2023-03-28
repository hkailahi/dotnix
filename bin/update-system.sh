#!/bin/sh

pushd ~/.config/dotnix
nix flake update
popd
