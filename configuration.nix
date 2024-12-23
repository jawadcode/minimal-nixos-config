{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.tpm2.enable = false;

  hardware.enableAllFirmware = true;
  hardware.graphics.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  systemd.tpm2.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;

      AMDGPU_ABM_LEVEL_ON_AC = 0;
      AMDGPU_ABM_LEVEL_ON_BAT = 3;
    };
  };
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  networking.hostName = "shitbox";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  console.keyMap = "uk";

  users.users.qak = {
    isNormalUser = true;
    description = "Jawad Ahmed";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.fish;
    packages = [];
  };

  environment.systemPackages = with pkgs; [
    file
    man
    man-pages
    man-pages-posix
    ntfs3g
    usbutils
  ];

  environment.variables = {
    MOZ_ENABLE_WAYLAND = 1;
    MOZ_USE_XINPUT2 = 1;
    NIXOS_OZONE_WL = 1;
  };

  documentation = {
    dev.enable = true;
    man = {
      man-db.enable = false;
      mandoc.enable = true;
    };
  };

  programs.fish = {
    enable = true;
    useBabelfish = true;
    shellAbbrs.tree = "lsd --tree";
    interactiveShellInit = ''
      fish_vi_key_bindings
      source (/etc/profiles/per-user/qak/bin/starship init fish --print-full-init | psub)
    '';
    shellInit = "nix-your-shell fish | source";
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
    };
    sessionPackages = [pkgs.sway];
    defaultSession = "sway";
  };

  programs.sway = {
    enable = true;
    package = null;
    wrapperFeatures.base = false;
  };

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
  };

  services.gnome.gnome-keyring.enable = true;
  services.openssh.enable = true;

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];
    gc = {
      dates = "weekly";
      automatic = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
