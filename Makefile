init:
	nix run home-manager/release-24.05 -- init --switch ~/dotfiles/cloudlab

switch:
	home-manager switch --flake ~/dotfiles/cloudlab

clean:
	nix-collect-garbage

reload:
	nix-direnv-reload