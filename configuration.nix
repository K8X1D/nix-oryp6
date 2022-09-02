# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # cachix for CUDA
      ./cachix.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Edmonton";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.utf8";

  # Enable i3-gaps
  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      plasma5.enable = true;
    };
    displayManager = {
      defaultSession = "none+i3";
      sddm.enable = true;
    };
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
        #i3blocks #if you are planning on using i3blocks over i3status
        polybar
        feh # wallpapers
        picom
        redshift
        alacritty # terminal
      ];
    };
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "ca";
    xkbOptions = "ctrl:nocaps";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "cf";

  # Enable CUPS to print documents.
  services.printing.enable = true;


  # Intel
  #  services.xserver.videoDrivers = [ "modesetting" ];
  #  services.xserver.useGlamor = true;

  # Nvidia
  services.xserver.videoDrivers = [ "nvidia" ];

  #  hardware.nvidia.modesetting.enable = true;
  #  services.xserver.videoDrivers = [ "nvidia" ];
  #  hardware.nvidia.prime = {
  #	  offload.enable = true;
  #
  ## bus is nvidia
  #	  nvidiaBusId = "PCI:1:0:0";
  #
  ## bus is intel
  #	  intelBusId = "PCI:0:2:0";
  #  };
  #
  #  hardware.nvidia = {
  #	  powerManagement = {
  #		  enable = true;
  #		  finegrained = true;
  #	  };
  #	  nvidiaPersistenced = true;
  #  };

  hardware.opengl.enable = true;
  hardware.nvidia = {
      modesetting.enable = true;
      prime = {
          offload.enable = true;
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
      };
      powerManagement = {
          enable = true;
          finegrained = true;
      };
      nvidiaPersistenced = true;
  };

  # Enable system76 hardware support
  hardware.system76.enableAll = true;
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
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
  users.users.k8x1d = {
    isNormalUser = true;
    description = "Kevin Kaiser";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      kate
      #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # browser
    pkgs.brave
    # word processor
    pkgs.libreoffice
    # IDE
    ((emacsPackagesFor emacs28NativeComp).emacsWithPackages (epkgs: [ epkgs.vterm
                                                                      epkgs.markdown-preview-mode
                                                                      epkgs.emacsql-sqlite
                                                                    ]))
    pkgs.fd
    pkgs.ripgrep
    pkgs.cmake
    pkgs.gnumake
    pkgs.nodePackages.npm
    pkgs.xclip
    pkgs.shellcheck
    pkgs.glslang
    pkgs.sbcl
    pkgs.nixfmt
    pkgs.scrot
    pkgs.graphviz
    pkgs.pipenv
    pkgs.ispell

    (let
      my-python-packages = python-packages: with python-packages; [
        isort
        nose
        pytest
        pandas
        yt-dlp
        #other python packages you want
      ];
      python-with-my-packages = python3.withPackages my-python-packages;
    in
      python-with-my-packages)



    #pkgs.python310
    #pkgs.python310Packages.isort
    #pkgs.pipenv
    #pkgs.python310Packages.nose
    #pkgs.python310Packages.pytest


    pkgs.vscode

    # Editor
    pkgs.neovim
    # sound support
    pkgs.pulseaudio
    pkgs.pavucontrol

    # code
    pkgs.julia-bin
    pkgs.R

    # apps
    pkgs.discord
    pkgs.caprine-bin
    pkgs.signal-desktop
    pkgs.zoom-us
    pkgs.slack

    # customize apparences
    pkgs.lxappearance

    # fonts
    pkgs.julia-mono
    pkgs.dejavu_fonts


    # utilities
    pkgs.gimp
    pkgs.htop
    pkgs.pass
    pkgs.pinentry-curses
    pkgs.gnupg
    pkgs.ffmpeg

    # CUDA
    #pkgs.linuxKernel.packages.linux_5_15.nvidia_x11 # fix for https://discourse.nixos.org/t/fixup-phase-cant-find-libcuda-so-1-build-abort-how-to-provide-dummy-libcuda-so-1/9541
    pkgs.cudaPackages.cudatoolkit

    #  wget
    # git
    pkgs.git
  ];

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
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?


  # Extra Files Systems
  fileSystems."/shared" =
    { device = "/dev/disk/by-uuid/7eb6c440-b26d-48d9-b8e9-bce47a46dfa1";
      fsType = "ext4";
    };

  fileSystems."/extension" =
    { device = "/dev/disk/by-uuid/d3900119-e611-4e5a-887c-cd1dbf3711b4";
      fsType = "ext4";
    };


}
