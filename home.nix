{ config, pkgs, inputs, ... }:

{
  home.username = "staravora";
  home.homeDirectory = "/home/staravora";
  home.stateVersion = "24.11";

  # Zsh config
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" "python" "helm" "kubectl" ];
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
      if [[ $- == *i* ]] && [[ $(pgrep -x "nitch" | wc -l) -eq 0 ]]; then
        nitch
      fi
    '';
  };

  # Programs configuration
  programs = {
    ghostty = {
      enable = true;
      settings = {
        theme = "Monokai Vivid";
        background-opacity = 0.85;
        background-blur-radius = 20;
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [ git ];
    };

    kitty = {
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
      extraConfig = '''';
    };
  };

  # Packages
  home.packages = with pkgs; [
    hello
    ripgrep
    fd
    nodejs
    gcc
    swww
    waybar
    dunst
    rofi-wayland
    wl-clipboard
    grimblast
    pywal
  ];

  # File configurations
  home.file = {
    ".config/nvim" = {
      source = builtins.path {
        name = "nvim-config";
        path = ./nvim;
      };
      recursive = true;
    };
    
    ".config/hypr/hyprland.conf".source = ./hypr/hyprland.conf;
    ".config/waybar/config".source = ./waybar/config;
    ".config/waybar/style.css".source = ./waybar/style.css;
    
    ".config/hypr/scripts/set-wallpaper" = {
      text = ''
        #!/bin/sh
        swww img ~/.config/hypr/wallpapers/wallpaper.jpg
      '';
      executable = true;
    };
    ".config/hypr/hyprlock.conf".text = ''
      background {
          monitor =
          path = screenshot   # Screenshot as background
          blur_passes = 3
          blur_size = 7
          noise = 0.0117
          contrast = 0.8916
          brightness = 0.8172
          vibrancy = 0.1696
          vibrancy_darkness = 0.0
      }

      input-field {
          monitor =
          size = 200, 50
          outline_thickness = 3
          dots_size = 0.33
          dots_spacing = 0.15
          dots_center = false
          outer_color = rgb(151515)
          inner_color = rgb(200, 200, 200)
          font_color = rgb(10, 10, 10)
          fade_on_empty = true
          placeholder_text = <i>Password...</i>
          hide_input = false
          position = 0, -20
          halign = center
          valign = center
      }

      label {
          monitor =
          text = Hi there, $USER!
          color = rgba(200, 200, 200, 1.0)
          font_size = 25
          font_family = JetBrains Mono Nerd Font
          position = 0, 80
          halign = center
          valign = center
      }
    ''; 
  };

  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Enable home-manager
  programs.home-manager.enable = true;
}
