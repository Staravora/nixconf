#    _________ __                                               
#   /   _____//  |______ ____________ ___  __________________   
#   \_____  \\   __\__  \\_  __ \__  \\  \/ /  _ \_  __ \__  \  
#   /        \|  |  / __ \|  | \// __ \\   (  <_> )  | \// __ \_
#  /_______  /|__| (____  /__|  (____  /\_/ \____/|__|  (____  /
#          \/           \/           \/                      \/                                               
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ inputs, config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
  ];

  ### System Configuration ###
  system.stateVersion = "24.11"; # Do not change unless you know what you are doing
  
  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  ### Boot Configuration ###
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest; # Latest mainline kernel
    # Alternative kernels (uncomment to use):
    #kernelPackages = pkgs.linuxPackages_xanmod_latest; # Latest Xanmod kernel 
    #kernelPackages = pkgs.linuxPackages_zen; # Zen kernel
    kernelParams = [ "amdgpu.exp_hw_support=1" ];
  };

  ### Networking ###
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant
    # proxy settings if needed:
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  ### Localization ###
  time.timeZone = "Asia/Bangkok";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  ### Desktop Environment ###
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    videoDrivers = [ "amdgpu"];

    # SDDM Config
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "sugar-dark";
    };
  };

  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
 
  ### Graphics and GPU ###
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      amdvlk
    ];
  };
  
  # Nvidia configuration (currently commented out)
  # hardware.nvidia = {
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  #   nvidiaSettings = true;
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  # };

  # Hybrid Graphics Configuration
  # hardware.nvidia.prime = {
  #   offload.enable = true;
  #   nvidiaBusId = "PCI:1:0:0";
  #   amdgpuBusId = "PCI:5:0:0";
  # };
  
  ### Audio ###
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    # jack.enable = true;  # Uncomment for JACK support
  };
  services.pulseaudio.enable = false;
  
  ### Power Management ###
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };
  
  ### Thunar File Manager ###
  programs.thunar.enable = true;
  programs.xfconf.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  ### User Configuration ###
  users.users.staravora = {
    isNormalUser = true;
    description = "staravora";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      # thunderbird
    ];
  };

  ### Program Configuration ###
  programs = {
    zsh.enable = true;
    firefox.enable = true;
    steam.enable = true;
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            lazy-nvim
            neo-tree-nvim
            onedark-nvim
          ];
          opt = [ ];
        };
      };
    };
  };

  ### System Services ###
  services = {
    printing.enable = true;
    flatpak.enable = true;
    mullvad-vpn.enable = true;
  };

  ### Virtualization ###
  virtualisation.vmware.guest.enable = true;
  virtualisation.vmware.host.enable = true;
  
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  ### Gaming Configuration ###
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
    };
  };

  ### Hardware Support ###
  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;
  };

  ### Performance Optimizations ###
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;                # Reduce swap usage
    "vm.vfs_cache_pressure" = 50;        # Cache more directory/inode objects
    "net.core.rmem_max" = 2500000;       # Increase network buffer sizes
    "net.core.wmem_max" = 2500000;
  };

  ### Storage Optimizations ###
  services.fstrim.enable = true;  # For SSDs

  ### System Maintenance ###
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-old";
    persistent = true;
  };
  boot.loader.systemd-boot.configurationLimit = 30;  # Keep 30 generations
  nix.settings.auto-optimise-store = true;          # Optimize nix store
  nix.settings.keep-outputs = true;                 # Keep build dependencies
  nix.settings.keep-derivations = true;             # Keep build instructions

  ### Security ###
  security.sudo.wheelNeedsPassword = true;
  security.polkit.enable = true;

  ### Firewall ###
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];  # Common web ports
    allowedUDPPorts = [ ];
  };

  ### Shell Enhancement ###
  programs.direnv.enable = true;  # Directory-specific environments
  programs.starship.enable = true;  # Better shell prompt

  ### System Packages ###
  environment.systemPackages = with pkgs; [
    # Hyprland Specific
    waybar
    dunst
    rofi-wayland
    swww # for wallpapers
    swaylock-effects
    wlogout
    grimblast # screenshots
    slurp
    wl-clipboard
    brightnessctl
    pamixer # audio control
    networkmanagerapplet
    blueman
    pywal

    # Development Tools
    vim
    neovim
    git
    cmake
    gnumake
    python3Full
    gcc
    clang
    fzf

    # System Utilities
    wget
    smartmontools
    gparted
    btop
    nvtopPackages.full
    fastfetch
    nitch
    home-manager
    sddm-chili-theme
    hyprlock

    # Shell and Terminal
    zsh
    oh-my-zsh
    kitty
    ghostty

    # Multimedia
    vlc
    gwenview
    cava
    lollypop
    kdenlive
    obs-studio

    # Internet and Communication
    brave
    chromium
    discord
    qbittorrent
    mullvad-vpn

    # Gaming
    steam
    lutris
    prismlauncher
    wine
    winetricks
    protontricks
    protonup-qt
    mangohud
    goverlay
    vulkan-tools    # Vulkan utilities and debugging tools
    vulkan-headers  # Development headers for Vulkan
    vulkan-loader   # Vulkan ICD loader
    vulkan-validation-layers  # Vulkan validation layers

    # Emulation
    pcsx2
    rpcs3
    shadps4

    # Office and Productivity
    libreoffice
    isoimagewriter

    # Virtualization
    vmware-workstation

    # Miscellaneous
    flatpak
    cmatrix
  ];
}
