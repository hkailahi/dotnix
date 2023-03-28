#!/bin/sh

pushd ~/.config/dotnix
home-manager switch --flake .#hkailahi
popd
