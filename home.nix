{ config, pkgs, inputs, ... }:

{
  home.username = "staravora";
  home.homeDirectory = "/home/staravora";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Zsh config
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
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
    initExtra = ''
      # Check if interactive shell and not already running
      if [[ $- == *i* ]] && [[ $(pgrep -x "nitch" | wc -l) -eq 0 ]]; then
        nitch
      fi
    '';
  };

  # Ghostty config
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "Monokai Vivid";  #Aurora also good
      background-opacity = 0.85;
      background-blur-radius = 20;
    };
  };

  # Neovim config
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
      git
    ];
  };

  # Kitty config
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "Argonaut";
      font_size = 12;
      remember_window_size = "yes";
      initial_window_width = "1000";
      initial_window_height = "800";
      background_opacity = "0.85";
      enable_audio_bell = false;
    };
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
    };
    extraConfig = ''
      # Any additional raw configuration
    '';
  };

  # Packages
  home.packages = [
    pkgs.hello
    pkgs.ripgrep
    pkgs.fd
    pkgs.nodejs
    pkgs.gcc
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

  # Nvim config files
  home.file = {
    ".config/nvim" = {
      source = builtins.path {
        name = "nvim-config";
        path = ./nvim;
      };
      recursive = true;
    };
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
