{ config, pkgs, inputs, ... }:


{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "staravora";
  home.homeDirectory = "/home/staravora";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

    programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {      # Changed from ohMyZsh to oh-my-zsh
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "python"
        "helm"
        "kubectl"
      ];
      theme = "agnoster";
    };
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -l";
      dot = "cd .dotfiles";
      rebuild = "sudo nixos-rebuild switch --flake .";
      conf = "nvim configuration.nix";
      upgrade = "sudo nixos-rebuild switch --flake . --upgrade";
      garbage = "sudo nix-collect-garbage -d";
    };
  };   

    programs.ghostty = {
      enable = true;
      settings = {
        theme = "Aurora";
        background-opacity = "0.85";
        background-blur-radius = "20";
      };
    };
  

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # Adds the 'hello' command to your environment. It prints a friendly
    # "Hello, world!" when run.
    pkgs.hello


  #];

  ] ++ (with pkgs.gnomeExtensions; [
    arcmenu
    blur-my-shell
    caffeine
    dash-to-dock
    extension-list
    mpris-label
    open-bar
    top-bar-organizer
  ]);

  programs.gnome-shell = {
    enable = true;
  };

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')

  

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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/staravora/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };
  

  #Backup user configs
  #home.file.".config/nvim/init.lua".source = ./init.lua;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
