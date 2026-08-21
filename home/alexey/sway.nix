{ config, pkgs, ... }:

let
  keyboardLayout = pkgs.writeShellScript "waybar-keyboard-layout" ''
    layout=$(
      ${pkgs.sway}/bin/swaymsg -t get_inputs -r \
        | ${pkgs.jq}/bin/jq -r '[.[] | select(.type == "keyboard" and .xkb_active_layout_name != null)][0].xkb_active_layout_name // ""'
    )

    case "$layout" in
      *Russian*|*Русская*|*ru*)
        printf '🇷🇺\n'
        ;;
      *English*|*US*|*us*)
        printf '🇺🇸\n'
        ;;
      *)
        printf '⌨\n'
        ;;
    esac
  '';
in
{
  # User-facing Wayland applications configured through Home Manager.
  programs.foot = {
    enable = true;
    settings.main = {
      font = "DejaVu Sans Mono:size=14";
    };
  };
  programs.wofi = {
    enable = true;
    style = ''
      * {
        font-family: "DejaVu Sans", "Symbols Nerd Font Mono", sans-serif;
        font-size: 16px;
      }

      window {
        background: #303446;
        color: #c6d0f5;
      }

      #input {
        margin: 8px;
        padding: 8px;
        border-radius: 8px;
        background: #414559;
        color: #c6d0f5;
      }

      #entry {
        padding: 8px;
      }

      #entry:selected {
        background: #8caaee;
        color: #232634;
      }
    '';
  };

  programs.waybar = {
    enable = true;

    style = ''
      * {
        font-family: "DejaVu Sans", "Symbols Nerd Font Mono", sans-serif;
        font-size: 16px;
      }

      window#waybar {
        background: rgba(35, 38, 52, 0.96);
        color: #c6d0f5;
        min-height: 36px;
      }

      #workspaces button {
        color: #a5adce;
        padding: 0 10px;
      }

      #workspaces button.focused,
      #workspaces button.active {
        color: #232634;
        background: #8caaee;
        border-radius: 8px;
      }

      #network {
        color: #81c8be;
      }

      #pulseaudio {
        color: #ca9ee6;
      }

      #cpu {
        color: #e5c890;
      }

      #memory {
        color: #a6d189;
      }

      #clock {
        color: #babbf1;
      }

      #custom-keyboard,
      #custom-launcher,
      #custom-power {
        color: #8caaee;
      }

      #clock,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #custom-keyboard,
      #custom-launcher,
      #custom-power {
        padding: 0 8px;
      }

      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #custom-keyboard,
      #custom-launcher,
      #custom-power {
        font-family: "Symbols Nerd Font Mono", "Noto Color Emoji", "DejaVu Sans", sans-serif;
      }
    '';

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 40;

      modules-left = [
        "custom/launcher"
        "sway/workspaces"
        "sway/mode"
      ];

      modules-center = [ "sway/window" ];

      modules-right = [
        "network"
        "pulseaudio"
        "cpu"
        "memory"
        "custom/keyboard"
        "clock"
        "tray"
        "custom/power"
      ];

      "custom/launcher" = {
        format = "󰀻";
        tooltip = false;
        on-click = "${pkgs.wofi}/bin/wofi --show drun";
      };

      "custom/keyboard" = {
        exec = "${keyboardLayout}";
        interval = 1;
        on-click = "${pkgs.sway}/bin/swaymsg input type:keyboard xkb_switch_layout next";
        tooltip = false;
      };

      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "  {ipaddr}/{cidr}";
        format-disconnected = "";
        on-click = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
        on-click-right = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        tooltip = false;
      };

      pulseaudio = {
        format = "  {volume}%";
        format-muted = "";
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-scroll-up = "${pkgs.wireplumber}/bin/wpctl set-volume --limit 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
        on-scroll-down = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        tooltip = false;
      };

      cpu = {
        format = "  {usage}%";
        tooltip = false;
      };

      memory = {
        format = "󰍛  {percentage}%";
        tooltip = false;
      };

      clock = {
        format = "{:%a %d.%m %H:%M}";
        tooltip = false;
      };

      # Power menu keeps suspend/hibernate/shutdown reachable without a full desktop shell.
      "custom/power" = {
        format = "⏻ ";
        tooltip = false;

        menu = "on-click";

        # Use an absolute XDG path because Waybar does not expand $HOME here.
        menu-file = "${config.xdg.configHome}/waybar/power_menu.xml";

        menu-actions = {
          suspend = "${pkgs.systemd}/bin/systemctl suspend";
          hibernate = "${pkgs.systemd}/bin/systemctl hibernate";
          shutdown = "${pkgs.systemd}/bin/systemctl poweroff";
          reboot = "${pkgs.systemd}/bin/systemctl reboot";
        };
      };
    };
  };

  # GTK menu consumed by Waybar's custom power button.
  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = ${pkgs.wofi}/bin/wofi --dmenu --insensitive --prompt Networks
    compact = False
        highlight = True
    highlight_fg = #232634
    highlight_bg = #8caaee
    highlight_bold = True
    pinentry = ${pkgs.pinentry-gnome3}/bin/pinentry-gnome3
    wifi_chars = ▂▄▆█
    format = {name}  {sec}  {bars}
    list_saved = False
    prompt = Networks

    [pinentry]
    description = Network password
    prompt = Password:

    [editor]
    terminal = ${pkgs.foot}/bin/foot
    gui_if_available = True
    gui = ${pkgs.networkmanagerapplet}/bin/nm-connection-editor

    [nmdm]
    rescan_delay = 5
    show_notifications = True
  '';

  xdg.configFile."waybar/power_menu.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <interface>
      <object class="GtkMenu" id="menu">
        <child>
          <object class="GtkMenuItem" id="suspend">
            <property name="label">Suspend</property>
          </object>
        </child>

        <child>
          <object class="GtkMenuItem" id="hibernate">
            <property name="label">Hibernate</property>
          </object>
        </child>

        <child>
          <object class="GtkSeparatorMenuItem" id="delimiter1"/>
        </child>

        <child>
          <object class="GtkMenuItem" id="shutdown">
            <property name="label">Shutdown</property>
          </object>
        </child>

        <child>
          <object class="GtkMenuItem" id="reboot">
            <property name="label">Reboot</property>
          </object>
        </child>
      </object>
    </interface>
  '';

  wayland.windowManager.sway = {
    enable = true;

    config = {
      # Keep the same keyboard/touchpad defaults in the user session and greeter.
      modifier = "Mod4";
      terminal = "foot";
      menu = "wofi --show drun";
      fonts = {
        names = [ "DejaVu Sans" ];
        size = 13.0;
      };
      window = {
        titlebar = false;
        border = 2;
        hideEdgeBorders = "none";
      };
      gaps = {
        inner = 6;
        outer = 2;
      };

      colors = {
        focused = {
          border = "#8caaee";
          background = "#303446";
          text = "#c6d0f5";
          indicator = "#85c1dc";
          childBorder = "#8caaee";
        };
        focusedInactive = {
          border = "#626880";
          background = "#303446";
          text = "#c6d0f5";
          indicator = "#51576d";
          childBorder = "#626880";
        };
        unfocused = {
          border = "#51576d";
          background = "#232634";
          text = "#a5adce";
          indicator = "#414559";
          childBorder = "#51576d";
        };
        urgent = {
          border = "#e78284";
          background = "#303446";
          text = "#c6d0f5";
          indicator = "#e78284";
          childBorder = "#e78284";
        };
      };

      input."type:touchpad" = {
        tap = "enabled";
        natural_scroll = "enabled";
      };

      input."type:keyboard" = {
        xkb_layout = "us,ru";
        xkb_options = "grp:win_space_toggle";
      };

      bars = [ { command = "waybar"; } ];

      keybindings =
        let
          modifier = "Mod4";
          workspaces = [
            "1"
            "2"
            "3"
            "4"
            "5"
            "6"
            "7"
            "8"
            "9"
            "0"
          ];
          # Generate workspace bindings mechanically so switch and move stay in sync.
          switchToWorkspace = ws: {
            "${modifier}+${ws}" = "workspace number ${ws}";
            "${modifier}+Shift+${ws}" = "move container to workspace number ${ws}";
          };
        in
        {
          "${modifier}+Return" = "exec foot";
          "${modifier}+d" = "exec wofi --show drun";
          "${modifier}+Shift+q" = "kill";
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+e" = "exec swaymsg exit";

          "XF86AudioRaiseVolume" =
            "exec ${pkgs.wireplumber}/bin/wpctl set-volume --limit 1.5 @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = "exec ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set +10%";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";

          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";

          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";

          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+w" = "floating toggle";
        }
        // builtins.foldl' (acc: ws: acc // (switchToWorkspace ws)) { } workspaces;
    };
  };

}
