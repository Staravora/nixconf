
#    .dBBBBP  dBBBBBBP dBBBBBb   dBBBBBb dBBBBBb  dBP dP  dBBBBP dBBBBBb dBBBBBb 
#    BP                     BB       dBP      BB         dB'.BP      dBP      BB 
#    `BBBBb    dBP      dBP BB   dBBBBK'  dBP BB dB .BP dB'.BP   dBBBBK'  dBP BB 
#       dBP   dBP      dBP  BB  dBP  BB  dBP  BB BB.BP dB'.BP   dBP  BB  dBP  BB 
#  dBBBBP'   dBP      dBBBBBBB dBP  dB' dBBBBBBB BBBP dBBBBP   dBP  dB' dBBBBBBB 
#                                                                                
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
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
    # GPU Drivers
    videoDrivers = [ "amdgpu" ];
    # For NVIDIA, uncomment these:
    # videoDrivers = [ "nvidia" ];
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
    # hyprland.enable = true;  # Uncomment to enable Hyprland
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
  boot.loader.systemd-boot.configurationLimit = 10;  # Keep 10 generations
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

    # Shell and Terminal
    zsh
    oh-my-zsh
    kitty
    ghostty

    # Desktop Environment
    gnome-tweaks
    gnome-menus
    # gnome-extension-manager # Install through flatpak instead

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
