# home/mystic/features/niri.nix
{
  pkgs,
  config,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    awww
    swaylock
    swayidle
    wlogout
    polkit_gnome
    brightnessctl # brightness keys
    playerctl # media keys
  ];

  # ── Niri config (KDL format) ────────────────────────────────────────────
  xdg.configFile."niri/config.kdl".text = ''
    input {
      keyboard {
        xkb { layout "us"; }
        repeat-delay 300
        repeat-rate 50
      }
      touchpad {
        tap
        natural-scroll
        accel-speed 0.2
      }
    }

    output "eDP-1" {
      scale 1.5
    }

    layout {
      gaps 12
      center-focused-column "never"

      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
        proportion 1.0
      }

      default-column-width { proportion 0.5; }

      focus-ring {
        width 2
        active-color "#89b4fa"    // Catppuccin blue — change to your taste
        inactive-color "#313244"
      }

      border {
        off
      }
    }

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    animations {
      slowdown 0.8
    }

    // ── Keybinds ──────────────────────────────────────────────────────────
    binds {
      // Launcher & terminal
      Mod+Return { spawn "ghostty"; }
      Mod+Space  { spawn "fuzzel"; }
      Mod+Q      { close-window; }

      // Locking
      Mod+L { spawn "swaylock" "-f" "-c" "000000"; }

      // Focus
      Mod+H { focus-column-left; }
      Mod+L { focus-column-right; }
      Mod+J { focus-window-down; }
      Mod+K { focus-window-up; }

      // Move
      Mod+Shift+H { move-column-left; }
      Mod+Shift+L { move-column-right; }
      Mod+Shift+J { move-window-down; }
      Mod+Shift+K { move-window-up; }

      // Workspaces
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+Shift+1 { move-window-to-workspace 1; }
      Mod+Shift+2 { move-window-to-workspace 2; }
      Mod+Shift+3 { move-window-to-workspace 3; }
      Mod+Shift+4 { move-window-to-workspace 4; }
      Mod+Shift+5 { move-window-to-workspace 5; }

      // Column sizing
      Mod+R { switch-preset-column-width; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }

      // Media & brightness
      XF86AudioRaiseVolume  { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
      XF86AudioLowerVolume  { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
      XF86AudioMute         { spawn "wpctl" "set-mute"   "@DEFAULT_AUDIO_SINK@" "toggle"; }
      XF86MonBrightnessUp   { spawn "brightnessctl" "set" "5%+"; }
      XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }
      XF86AudioPlay         { spawn "playerctl" "play-pause"; }
      XF86AudioNext         { spawn "playerctl" "next"; }
      XF86AudioPrev         { spawn "playerctl" "previous"; }

      // Screenshot
      Print       { screenshot; }
      Shift+Print { screenshot-screen; }
      Alt+Print   { screenshot-window; }

      // Session
      Mod+Shift+E { quit; }
    }

    // ── Startup ───────────────────────────────────────────────────────────
    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "swww-daemon"
    spawn-at-startup "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
    spawn-at-startup "swayidle" "-w"
      "timeout" "300" "swaylock -f -c 000000"
      "timeout" "600" "niri msg action power-off-monitors"
      "before-sleep" "swaylock -f -c 000000"
  '';

  # ── Waybar ──────────────────────────────────────────────────────────────
  programs.waybar = {
    enable = true;
    systemd.enable = false; # niri spawns it via spawn-at-startup above

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      spacing = 4;

      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "backlight"
        "battery"
        "bluetooth"
        "network"
        "tray"
      ];

      "niri/workspaces" = {
        format = "{index}";
      };

      "niri/window" = {
        max-length = 40;
      };

      clock = {
        format = " {:%H:%M}";
        format-alt = " {:%A, %B %d}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
      };

      network = {
        format-wifi = " {signalStrength}%";
        format-ethernet = " connected";
        format-disconnected = "󰤭 ";
        tooltip-format = "{essid} ({signalStrength}%) via {ifname}";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟";
        format-icons = {
          default = [
            ""
            ""
            ""
          ];
        };
        on-click = "pavucontrol";
      };

      backlight = {
        format = "{icon} {percent}%";
        format-icons = [
          "󰃞"
          "󰃟"
          "󰃠"
        ];
      };

      bluetooth = {
        format-on = "󰂯";
        format-off = "󰂲";
        format-connected = "󰂱 {device_alias}";
        on-click = "blueman-manager";
      };

      tray = {
        spacing = 8;
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: rgba(30, 30, 46, 0.9);
        color: #cdd6f4;
      }

      #workspaces button {
        padding: 0 8px;
        color: #6c7086;
        background: transparent;
      }

      #workspaces button.active {
        color: #89b4fa;
        border-bottom: 2px solid #89b4fa;
      }

      #clock, #battery, #network, #pulseaudio,
      #bluetooth, #backlight, #tray {
        padding: 0 10px;
        color: #cdd6f4;
      }

      #battery.warning  { color: #fab387; }
      #battery.critical { color: #f38ba8; }
    '';
  };

  # ── Fuzzel (launcher) ───────────────────────────────────────────────────
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=13";
        terminal = "ghostty -e";
        layer = "overlay";
        width = 35;
        lines = 8;
        horizontal-pad = 16;
        vertical-pad = 8;
        inner-pad = 4;
      };
      colors = {
        background = "1e1e2eff";
        text = "cdd6f4ff";
        match = "89b4faff";
        selection = "313244ff";
        selection-text = "cdd6f4ff";
        border = "89b4faff";
      };
      border = {
        width = 2;
        radius = 8;
      };
    };
  };

  # ── Mako (notifications) ────────────────────────────────────────────────
  services.mako = {
    enable = true;
    settings = {
      background-color = "#1e1e2e";
      text-color = "#cdd6f4";
      border-color = "#89b4fa";
      border-radius = 8;
      border-size = 2;
      padding = "10,14";
      width = 320;
      height = 100;
      default-timeout = 5000;
      font = "JetBrainsMono Nerd Font 12";
    };
  };
}
