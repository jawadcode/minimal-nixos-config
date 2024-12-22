{pkgs, ...}: let
  getExe = pkgs.lib.meta.getExe;
  getExe' = pkgs.lib.meta.getExe';
in {
  home = {
    username = "qak";
    homeDirectory = "/home/qak";
    stateVersion = "24.05";
    file = {
      ".config/starship.toml".source = ./starship.toml;
    };
    packages = with pkgs; [
      # Apps
      discord
      imv
      nemo
      papers
      qalculate-gtk
      vlc

      # Sway Utilities
      brightnessctl
      glib
      gnome-characters
      playerctl
      sway-contrib.grimshot
      swaybg
      wl-clipboard
      yaru-theme

      # CLI Programs
      bat
      btop
      curl
      fd
      lsd
      ripgrep
      tokei
      unzip
      wget
      xorg.xlsclients
      zellij

      # Programming Stuff
      alejandra
      nil
      pyright
      python312Packages.python

      # Fonts
      font-awesome
      ibm-plex
      (iosevka-bin.override {variant = "SS07";})
      (callPackage ./iosevka-term-ss07-nerd-font.nix {})
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      roboto
    ];
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "nemo.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "text/html" = "firefox.desktop";
        "image/gif" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/png" = "imv.desktop";
        "video/avi" = "vlc.desktop";
        "video/mp4" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "text/plain" = "emacsclient.desktop";
        "application/x-shellscript" = "emacs.desktop";
        "application/pdf" = "org.gnome.Papers.desktop";
        "image/tiff" = "org.gnome.Papers.desktop";
        "application/postscript" = "org.gnome.Papers.desktop";
        "application/x-dvi" = "org.gnome.Papers.desktop";
      };
    };
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  wayland.windowManager.sway = {
    enable = true;
    checkConfig = true;
    config = let
      terminal = "${getExe pkgs.wezterm} start";
      menu = "${getExe pkgs.nwg-drawer} -fm ${getExe pkgs.nemo} -term '${terminal}'";
    in {
      modifier = "Mod4";
      focus = {
        followMouse = true;
        mouseWarping = true;
      };
      bars = [];
      fonts = {
        names = ["sans-serif"];
        style = "Regular";
        size = 12.0;
      };
      gaps.inner = 5;
      inherit menu;
      keybindings = let
        wpctl = getExe' pkgs.wireplumber "wpctl";
        brightctl = getExe pkgs.brightnessctl;
        playerctl = getExe pkgs.playerctl;
        grimshot = getExe pkgs.sway-contrib.grimshot;
        id = "@DEFAULT_AUDIO_SINK@";
      in
        pkgs.lib.mkOptionDefault {
          XF86AudioRaiseVolume = "exec ${wpctl} set-volume ${id} 5%+";
          XF86AudioLowerVolume = "exec ${wpctl} set-volume ${id} 5%-";
          XF86AudioMute = "exec ${wpctl} set-mute ${id} toggle";

          XF86MonBrightnessUp = "exec ${brightctl} set 5%+";
          XF86MonBrightnessDown = "exec ${brightctl} set 5%-";

          XF86AudioPlay = "exec ${playerctl} play-pause";
          XF86AudioNext = "exec ${playerctl} next";
          XF86AudioPrev = "exec ${playerctl} previous";

          XF86Search = "exec ${menu}";

          "Mod4+C" = "exec ${getExe pkgs.qalculate-gtk}";
          "Mod4+Ctrl+C" = "exec ${getExe pkgs.gnome-characters}";

          "Print" = "exec ${grimshot} savecopy area";
          "Shift+Print" = "exec ${grimshot} savecopy window";
          "Ctrl+Print" = "exec ${grimshot} savecopy output";
          "Mod4+Print" = "exec ${grimshot} savecopy screen";
        };
      input = {
        "1:1:AT_Translated_Set_2_keyboard" = {xkb_layout = "gb";};
        "2:14:ETPS/2_Elantech_Touchpad" = {
          natural_scroll = "enabled";
          tap = "enabled";
        };
      };
      output = let
        monitor = resolution: {
          inherit resolution;
          bg = "${pkgs.sway}/share/backgrounds/sway/Sway_Wallpaper_Blue_${resolution}.png fill";
        };
      in {
        eDP-1 = monitor "1366x768" // {position = "0,0";};
      };
      floating = {
        border = 0;
        criteria = [{class = "qalculate-gtk";}];
      };
      startup = [
        {command = "${getExe pkgs.nwg-drawer} -r";}
        {command = "${getExe' pkgs.glib "gsettings"} set org.gnome.desktop.interface color-scheme prefer-dark";}
      ];
      inherit terminal;
      window = {
        titlebar = false;
        border = 1;
      };
      defaultWorkspace = "workspace number 1";
    };
    extraConfig = ''
      bindswitch lid:on output eDP-1 disable
      bindswitch lid:off output eDP-1 enable

      bindgesture swipe:3:right workspace prev
      bindgesture swipe:3:left workspace next

    '';
    wrapperFeatures.gtk = true;
    xwayland = true;
  };

  programs.swaylock.enable = true;

  services.swayidle = let
    swaylock = getExe pkgs.swaylock;
    swaymsg = getExe' pkgs.sway "swaymsg";
  in {
    enable = true;
    events = [
      {
        event = "after-resume";
        command = "${swaymsg} 'output * power on'";
      }
      {
        event = "before-sleep";
        command = "${swaylock} -f -c 000000";
      }
    ];
    extraArgs = [
      "timeout"
      "600"
      "${swaylock} -f -c 000000"
      "timeout"
      "1200"
      "${swaymsg} 'output * power off'"
    ];
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = let
      "sway/mode" = {
        format = ''<span style="italic">{}</span>'';
      };
      # I have no idea what this is lol
      "sway/scratchpad" = {
        format = "{icon} {count}";
        show-empty = false;
        format-icons = ["" ""];
        tooltip = true;
        tooltip-format = "{app} = {title}";
      };
    in [
      {
        layer = "top";
        output = ["eDP-1" "DP-1"];
        position = "top";
        height = 32;
        spacing = 4;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "sway/scratchpad"
        ];
        modules-center = ["sway/window"];
        modules-right = [
          "idle_inhibitor"
          "pulseaudio"
          "cpu"
          "temperature"
          "battery"
          "tray"
          "clock"
        ];
        inherit "sway/mode";
        inherit "sway/scratchpad";
        "tray" = {spacing = 10;};
        "clock" = {
          tooltip-format = ''            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          format-alt = ''{:%Y-%m-%d}'';
        };
        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = "";
            deactivated = "";
          };
        };
        "cpu" = {
          format = "{usage}% ";
          tooltip = false;
        };
        "temperature" = {
          hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
          input-filename = "temp2_input";
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = ["" "" ""];
        };
        "battery" = {
          states = {
            good = 95;
            warning = 20;
            critical = 10;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = ["" "" "" "" ""];
        };
        "pulseaudio" = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = ["" "" ""];
          };
          on-click = "pavucontrol";
        };
      }
    ];
    style = ''
      window {
        font-family: sans-serif, "Font Awesome 6 Free";
        font-size: 16px;
      }

      /* Purposely garish, cope */
      window#waybar {
        background-color: rgba(36, 36, 36, 0.7);
        border-bottom: 3px solid rgb(64, 64, 64);
        color: #E0E0E0;
        transition-property: background-color;
        transition-duration: .5s;
      }

      window#waybar.hidden {
        opacity: 0.2;
      }

      button {
        box-shadow: inset 0 -3px transparent;
        border: none;
        border-radius: 0;
      }

      button:hover {
        background: inherit;
        box-shadow: inset 0 -3px #ffffff;
      }

      #pulseaudio:hover {
        background-color: #a37800;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #ffffff;
      }

      #workspaces button:hover {
        background: rgba(0, 0, 0, 0.2);
      }

      #workspaces button.focused {
        background-color: #64727D;
        box-shadow: inset 0 -3px #ffffff;
      }

      #workspaces button.urgent {
        background-color: #eb4d4b;
      }

      #mode {
        background-color: #64727D;
        box-shadow: inset 0 -3px #ffffff;
      }

      #scratchpad,
      #mode,
      #idle_inhibitor,
      #pulseaudio,
      #cpu,
      /* #memory, */
      #temperature,
      #battery,
      #tray,
      #clock {
        padding: 0 10px;
        margin: 3px 0;
        color: #E0E0E0;
      }

      #window,
      #workspaces {
        margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left>widget:first-child>#workspaces {
        margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right>widget:last-child>#workspaces {
        margin-right: 0;
      }

      #clock {
        background-color: #2980b9;
        margin-right: 3px;
      }

      #battery {
        background-color: #ffffff;
        color: #202020;
      }

      #battery.charging,
      #battery.plugged {
        color: #ffffff;
        background-color: #26A65B;
      }

      @keyframes blink {
        to {
          background-color: #ffffff;
          color: #202020;
        }
      }

      /* Using steps() instead of linear as a timing function to limit cpu usage */
      #battery.critical:not(.charging) {
        background-color: #f53c3c;
        color: #ffffff;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: steps(12);
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      label:focus {
        background-color: #202020;
      }

      #idle_inhibitor {
        background-color: #2d3436;
      }

      #idle_inhibitor.activated {
        background-color: #ecf0f1;
        color: #2d3436;
      }

      #pulseaudio {
        background-color: #f1c40f;
        color: #202020;
      }

      #cpu {
        background-color: #2ecc71;
        color: #202020;
      }

      /* #memory {
          background-color: #9b59b6;
      } */

      #disk {
        background-color: #964B00;
      }

      #network {
        background-color: #2980b9;
      }

      #network.disconnected {
        background-color: #f53c3c;
      }

      #pulseaudio.muted {
        background-color: #90b1b1;
        color: #2a5c45;
      }

      #temperature {
        background-color: #d0730b;
      }

      #temperature.critical {
        background-color: #eb4d4b;
      }

      #tray {
        background-color: #64727D;
      }

      #tray>.passive {
        -gtk-icon-effect: dim;
      }

      #tray>.needs-attention {
        -gtk-icon-effect: highlight;
        background-color: #eb4d4b;
      }

      #scratchpad {
        background: rgba(0, 0, 0, 0.2);
      }

      #scratchpad.empty {
        background-color: transparent;
      }

      #privacy {
        padding: 0;
      }

      #privacy-item {
        padding: 0 5px;
        color: white;
      }

      #privacy-item.screenshare {
        background-color: #cf5700;
      }

      #privacy-item.audio-in {
        background-color: #1ca000;
      }

      #privacy-item.audio-out {
        background-color: #0069d4;
      }
    '';
  };

  services.mako = {
    enable = true;
    anchor = "top-center";
    font = "sans-serif 12";
    defaultTimeout = 5000;
  };

  gtk = let
    theme = {
      package = pkgs.yaru-theme;
      name = "Yaru-blue-dark";
    };
  in {
    enable = true;
    font = {
      name = "sans-serif";
      size = 12.0;
    };
    iconTheme = theme;
    theme = theme;
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  programs.starship.enable = true;

  programs.git = let
    email = "jawad.w.ahmed@gmail.com";
  in {
    enable = true;
    package = pkgs.gitFull;
    userEmail = email;
    userName = "jawadcode";
    extraConfig = {
      init.defaultBranch = "master";
      author = {
        name = "Jawad W. Ahmed";
        email = email;
      };
      credential.helper = "${pkgs.gitFull}/bin/git-credential-libsecret";
    };
  };

  programs.nix-your-shell.enable = true;

  programs.nix-index.enable = true;

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = ["Roboto"];
      serif = ["IBM Plex Serif"];
      monospace = ["Iosevka Term SS07"];
      emoji = ["Noto Color Emoji"];
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        front_end = "WebGpu",
        color_scheme = "Apple System Colors";
        font = wezterm.font_with_fallback({ "Iosevka Term SS07", "Noto Color Emoji" }),
        font_size = 13.5,
        hide_tab_bar_if_only_one_tab = true,
      }
    '';
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs30-pgtk;
    client.enable = true;
    defaultEditor = true;
    startWithUserSession = "graphical";
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "dark_plus";
      editor = {
        bufferline = "always";
        lsp.display-inlay-hints = true;
      };
      keys.normal = {
        "S-tab" = "goto_next_buffer";
        "A-tab" = "goto_previous_buffer";
      };
    };
    languages = {
      language = [
        {
          name = "python";
          language-servers = ["pyright"];
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = true;
        }
        {
          name = "nix";
          formatter.command = "alejandra";
          auto-format = true;
        }
      ];
    };
  };

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisplayBookmarksToolbar = "newtab";
      OfferToSaveLogins = false;
      HardwareAcceleration = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        Exceptions = [];
      };
      NoDefaultBookmarks = true;
      PormptForDownloadLocation = true;
      AutofillCreditCardEnabled = false;
    };
  };

  services.gnome-keyring.enable = true;

  programs.home-manager.enable = true;
}
