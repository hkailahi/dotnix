# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Configure System (installs `darwin-rebuild`/`home-manager` for applying future updates)
nix run nix-darwin -- switch -I --darwin=darwin.nix --flake ~/.config/dotnix
