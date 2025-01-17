# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  #test

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #flatpak support
  services.flatpak.enable = true;

  #zsh
  programs.zsh.enable = true;
    users.users.staravora = {
    shell = pkgs.zsh;  # This makes Zsh your default shell system-wide
    # ... other user settings
  };


  #Hyprland
  #programs.hyprland.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  #Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #Neovim conf

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          lazy-nvim          # instead of 'lazy'
          neo-tree-nvim      # instead of 'neo-tree'
          onedark-nvim       # instead of 'onedark'
        ];
        opt = [ ];
      };
    };
  };
  
  ### Gaming Optimizations ###

  # First, define the package overrides at the top level
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

  # Then, enable Steam
  programs.steam = {
    enable = true;
  }; 

   #Enable OpenGL
  hardware.graphics.enable = true;

   # Specify AMD drivers
  #services.xserver.videoDrivers = [ "amdgpu" ];

  # Additional settings for AMD GPUs
  # Enable early KMS (Kernel Mode Setting) for better boot performance
  #boot.kernelParams = [ "amdgpu.exp_hw_support=1" ]; # This might be necessary for newer GPUs or specific features



  # Configure NVIDIA settings
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Most users do not need to change this
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # Enable the NVIDIA settings menu
    nvidiaSettings = true;
    # Enable modesetting for all chips (legacy and modern)
    modesetting.enable = true;
    # Optionally, enable power management
    powerManagement.enable = false;
    # Optionally, enable nvidia-persistenced for better performance
    # nvidia.persistenced = true;
  };

    # Configure PRIME for hybrid graphics 
    hardware.nvidia.prime = {
      offload.enable = true;
      # Bus ID of the NVIDIA GPU
      nvidiaBusId = "PCI:1:0:0";
      # Bus ID of the AMD GPU
      amdgpuBusId = "PCI:5:0:0";
  };


  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  #enable virtualisation
  virtualisation.vmware.guest.enable = true;
  virtualisation.vmware.host.enable = true;

  #enable vpn
  services.mullvad-vpn.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.staravora = {
    isNormalUser = true;
    description = "staravora";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    git
    cmake
    gnumake
    python3Full
    gcc
    clang
    zsh
    oh-my-zsh
    fastfetch
    btop
    nvtopPackages.full
    flatpak
    gparted
    vlc
    gwenview
    cava
    lollypop
    isoimagewriter
    libreoffice
    cmatrix
    brave
    chromium
    kitty
    ghostty
    gnome-tweaks
    gnome-menus
    #gnome-extension-manager
    steam
    discord
    lutris
    prismlauncher
    obs-studio
    kdenlive
    mullvad-vpn
    vmware-workstation
    qbittorrent
    wine
    winetricks
    protontricks
    protonup-qt
   #proton-ge-bin
    mangohud
    goverlay
    pcsx2
    rpcs3
    shadps4
  ];


  #gnome-extension-manager is broken, install through flatpak

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
