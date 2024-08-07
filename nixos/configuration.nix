{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  spicetify-nix = inputs.spicetify-nix;
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;

  inputImage = /home/hedonicadapter/Pictures/wallpapers/Frame21.png;
  brightness = 0;
  contrast = 0;
  fillColor = "black";
  saturation = 100;

  removeHash = hex: builtins.substring 1 (builtins.stringLength hex - 1) hex;

  colorsRGB = builtins.mapAttrs (name: value: removeHash value) outputs.colors;
in {
  # You can import other NixOS modules here
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.stylix.nixosModules.stylix
    inputs.nur.nixosModules.nur
    spicetify-nix.nixosModules.default
    inputs.xremap-flake.nixosModules.default

    ./maintenance.nix
    ./hardware-configuration.nix
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs outputs;};
    users = {hedonicadapter = import ../home-manager/home.nix;};
    backupFileExtension = "backup";
  };

  nixpkgs = {
    overlays = [
      # Add overlays from flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      permittedInsecurePackages = [
        "electron-25.9.0" # ONLY for obsidian at the moment
      ];
      allowUnfree = true;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      # Opinionated: disable global registry
      flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  environment.systemPackages = with pkgs; [
    bibata-cursors-translucent
    fluent-icon-theme

    onlyoffice-bin
    jetbrains.rider
    wine
    winetricks
    gcc
    python311Packages.cmake
    nodejs_22
    microsoft-edge-dev
    xorg.xmodmap
    git
    nix-output-monitor

    neofetch
    imagemagick # for neofetch
    polkit_gnome
    gnumake # for lenovo-legion
    linuxHeaders # for lenovo-legion
    dmidecode # for lenovo-legion
    lm_sensors # for lenovo-legion
    lenovo-legion
    wev # event viewer
    atac
    zoxide
    ripgrep
    fd
    swappy
    easyeffects
    brightnessctl
    pulseaudio
    playerctl
    spotify
    (pkgs.discord-canary.override {
      withOpenASAR = true;
      withVencord = true;
    })
    # discord-canary # run once as vanilla if openasar error
    betterdiscordctl
    acpi

    inputs.swww.packages.${pkgs.system}.swww
    bc
    wlsunset
    wl-clipboard
    cliphist
    wl-clip-persist
    teams-for-linux
    vscode
    obsidian

    font-manager

    fsearch
  ];

  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.text;
    colorScheme = "custom";

    # color definition for custom color scheme. (rosepine)
    customColorScheme = {
      text = colorsRGB.blush;
      subtext = colorsRGB.white;
      sidebar-text = colorsRGB.vanilla_pear;
      main = "#00000005";
      sidebar = colorsRGB.grey;
      player = colorsRGB.black;
      card = colorsRGB.orange;
      shadow = colorsRGB.burgundy;
      selected-row = colorsRGB.blue;
      button = colorsRGB.cyan;
      button-active = colorsRGB.blue;
      button-disabled = colorsRGB.grey;
      tab-active = colorsRGB.blush;
      notification = colorsRGB.green;
      notification-error = colorsRGB.red;
      misc = colorsRGB.white_dim;
    };
    injectCss = true;

    enabledCustomApps = with spicePkgs.apps; [reddit marketplace];
    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      keyboardShortcut
      powerBar
      shuffle # shuffle+
      skipStats
      autoVolume
      adblock
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    TERM = "kitty";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = ["gtk"];
      hyprland.default = ["gtk" "hyprland"];
    };
  };

  stylix = {
    enable = true;
    image = pkgs.runCommand "dimmed-background.png" {} ''
      ${pkgs.imagemagick}/bin/convert "${inputImage}" -brightness-contrast ${
        toString brightness
      },${toString contrast} -modulate 100,${
        toString saturation
      } -fill ${fillColor} $out
    '';
    polarity = "dark";
    base16Scheme = {
      base00 = outputs.colors.black;
      base01 = outputs.colors.grey;
      base02 = outputs.colors.orange_dim;
      base03 = outputs.colors.white_dim;
      base04 = outputs.colors.beige;
      base05 = outputs.colors.white;
      base06 = outputs.colors.cyan;
      base07 = outputs.colors.red;
      base08 = outputs.colors.blush;
      base09 = outputs.colors.burgundy;
      base0A = outputs.colors.cyan;
      base0B = outputs.colors.green;
      base0C = outputs.colors.yellow;
      base0D = outputs.colors.beige;
      base0E = outputs.colors.vanilla_pear;
      base0F = outputs.colors.orange_bright;
    };
    # base16Scheme = { gruvbox
    #   base00 = "#292828";
    #   base01 = "#32302f";
    #   base02 = "#504945";
    #   base03 = "#665c54";
    #   base04 = "#bdae93";
    #   base05 = "#ddc7a1";
    #   base06 = "#ebdbb2";
    #   base07 = "#fbf1c7";
    #   base08 = "#ea6962";
    #   base09 = "#e78a4e";
    #   base0A = "#d8a657";
    #   base0B = "#a9b665";
    #   base0C = "#89b482";
    #   base0D = "#7daea3";
    #   base0E = "#d3869b";
    #   base0F = "#bd6f3e";
    # };
    # base16Scheme = { melange
    #   base00 = "#292522";
    #   base01 = "#34302C";
    #   base02 = "#403A36";
    #   base03 = "#867462";
    #   base04 = "#C1A78E";
    #   base05 = "#ECE1D7";
    #   base06 = "#D47766";
    #   base07 = "#EBC06D";
    #   base08 = "#85B695";
    #   base09 = "#89B3B6";
    #   base0A = "#A3A9CE";
    #   base0B = "#CF9BC2";
    #   base0C = "#BD8183";
    #   base0D = "#E49B5D";
    #   base0E = "#78997A";
    #   base0F = "#7B9695";
    # };
    # base16Scheme = { cupcake
    #   base00 = "#FBF1F2";
    #   base01 = "#8B8198";
    #   base02 = "#BFB9C6";
    #   base03 = "#585062";
    #   base04 = "#DCB16C";
    #   base05 = "#8B8198";
    #   base06 = "#7297B9";
    #   base07 = "#FBF1F2";
    #   base08 = "#D57E85";
    #   base09 = "#DCB16C";
    #   base0A = "#A3B367";
    #   base0B = "#69A9A7";
    #   base0C = "#69A9A7";
    #   base0D = "#7297B9";
    #   base0E = "#BB99B4";
    #   base0F = "#D57E85";
    # };
    targets = {
      chromium.enable = true;
      gnome.enable = true;
      gtk.enable = true;
    };

    fonts = {
      serif = {
        package = pkgs.merriweather;
        name = "Merriweather";
      };

      sansSerif = {
        package = pkgs.public-sans;
        name = "Public Sans";
      };

      monospace = {
        package = pkgs.cartograph-cf;
        name = "CartographCF Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      sizes.applications = 9;
      sizes.desktop = 9;
      sizes.popups = 9;
      sizes.terminal = 9;
    };
  };

  security.polkit.enable = true;

  # formerly hardware.opengl
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot = {
    extraModulePackages = [config.boot.kernelPackages.lenovo-legion-module];
    kernelPackages = pkgs.linuxPackages_zen;
    # plymouth = {
    #   enable = true;
    #   theme = "abstract_ring";
    #   themePackages = [
    #     (pkgs.adi1090x-plymouth-themes.override {
    #       selected_themes = [ "abstract_ring" ];
    #     })
    #   ];
    # };

    # silent boot options below
    loader.grub.timeoutStyle = false;
    # consoleLogLevel = 0;
    # initrd.verbose = false;
    # kernelParams = [
    # "quiet"
    # "splash"
    # "boot.shell_on_fail"
    # "i915.fastboot=1"
    # "loglevel=3"
    # "rd.systemd.show_status=false"
    # "rd.udev.log_level=3"
    # "udev.log_priority=3"
    # ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot = {
        enable = true;
        editor = true;
        configurationLimit = 100;
      };
    };
  };

  # hardware.fancontrol = {
  #   enable = true;
  #   config = ''
  #     # Configuration file generated by pwmconfig
  #     INTERVAL=10
  #     DEVPATH=hwmon3=devices/virtual/thermal/thermal_zone2 hwmon4=devices/platform/f71882fg.656
  #     DEVNAME=hwmon3=soc_dts1 hwmon4=f71869a
  #     FCTEMPS=hwmon4/device/pwm1=hwmon3/temp1_input
  #     FCFANS=hwmon4/device/pwm1=hwmon4/device/fan1_input
  #     MINTEMP=hwmon4/device/pwm1=35
  #     MAXTEMP=hwmon4/device/pwm1=65
  #     MINSTART=hwmon4/device/pwm1=150
  #     MINSTOP=hwmon4/device/pwm1=0
  #   '';
  # };
  hardware.nvidia = {
    modesetting.enable = true; # Modesetting is required.

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    # powerManagement.finegrained = true;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    nvidiaSettings = true;

    prime = {
      # offload = {
      #   enable = true;
      #   enableOffloadCmd = true;
      # };
      sync.enable = true;
      intelBusId = "PCI:00:02:0";
      nvidiaBusId = "PCI:01:00:0";
    };

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod.enabled = "ibus"; # for emoji input
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };
  console.keyMap = "sv-latin1";

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  virtualisation.docker.daemon.settings = {
    data-root = "~/Documents/coding/docker";
  };

  networking.hostName = "nixos";

  users.users = {
    hedonicadapter = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [];
      extraGroups = ["networkmanager" "wheel" "docker"];
    };
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';

  # List services that you want to enable:
  services.xremap = {
    config = {
      modmap = [
        {
          name = "Global";
          remap = {"CapsLock" = "Esc";};
          remap = {"Esc" = "CapsLock";};
        }
      ];
    };
  };
  services.logind = {lidSwitch = "ignore";};
  # bluetooth
  hardware.bluetooth.enable = true;
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "se";
    xkb.variant = "";
  };
  services.printing.enable = true;
  services.thermald.enable = true;
  services.fwupd.enable = true; # Firmware updator
  services.upower.enable = true; # battery

  services.system76-scheduler.enable = true;

  services.undervolt = {
    enable = true;
    # useTimer = true;
    verbose = true;
    uncoreOffset = -75;
    turbo = 0;
    tempAc = 70;
    tempBat = 65;
    temp = 70;
    p2.window = 0.002;
    p2.limit = 90;
    p1.window = 28;
    p1.limit = 45;
    gpuOffset = -50;
    coreOffset = -50;
    analogioOffset = -50;
  };
  services.power-profiles-daemon.enable = false;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
        preference = "power";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

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
  system.stateVersion = "23.11"; # Did you read the comment?
}
