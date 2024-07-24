{ config, pkgs, javaVersion, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dimas";
  home.homeDirectory = "/users/dimas";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  nixpkgs.overlays = [
    (final: prev: rec {
      jdk = prev."jdk${toString javaVersion}";
    })
  ];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    leiningen
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs = {
    home-manager.enable = true; # Let Home Manager install and manage itself.
    bat.enable = true;
    bottom.enable = true;
    direnv = {
      enable = true;
      enableBashIntegration = true; # see note on other shells below
      nix-direnv.enable = true;
    };
    eza.enable = true;
    fd.enable = true;
    fzf.enable = true;
    git.enable = true;
    man.enable = true;
    mise.enable = true;
    ripgrep.enable = true;
    ssh.enable = true;
    tealdeer.enable = true;
    tmux.enable = true;
    zellij.enable = true;
  };
}