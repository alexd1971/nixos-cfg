{ config, pkgs, ... }:

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
        background: #18181b;
        color: #f4f4f5;
      }

      #input {
        margin: 8px;
        padding: 8px;
        border-radius: 8px;
        background: #27272a;
        color: #f4f4f5;
      }

      #entry {
        padding: 8px;
      }

      #entry:selected {
        background: #3f3f46;
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
        background: rgba(24, 24, 27, 0.96);
        color: #f4f4f5;
        min-height: 36px;
      }

      #workspaces button {
        color: #a1a1aa;
        padding: 0 10px;
      }

      #workspaces button.focused,
      #workspaces button.active {
        color: #ffffff;
        background: #3f3f46;
      }

      #clock,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #tray,
      #custom-power {
        padding: 0 8px;
      }

      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #custom-power {
        font-family: "Symbols Nerd Font Mono", "DejaVu Sans", sans-serif;
      }
    '';

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 40;

      modules-left = [
        "sway/workspaces"
        "sway/mode"
      ];

      modules-center = [ "sway/window" ];

      modules-right = [
        "network"
        "pulseaudio"
        "cpu"
        "memory"
        "clock"
        "tray"
        "custom/power"
      ];

      network = {
        format-wifi = "  {signalStrength}%";
        format-ethernet = "  {ipaddr}/{cidr}";
        format-disconnected = "";
        tooltip = false;
      };

      pulseaudio = {
        format = "  {volume}%";
        format-muted = "";
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
          border = "#7dd3fc";
          background = "#18181b";
          text = "#f4f4f5";
          indicator = "#38bdf8";
          childBorder = "#7dd3fc";
        };
        focusedInactive = {
          border = "#52525b";
          background = "#18181b";
          text = "#d4d4d8";
          indicator = "#3f3f46";
          childBorder = "#52525b";
        };
        unfocused = {
          border = "#3f3f46";
          background = "#18181b";
          text = "#a1a1aa";
          indicator = "#27272a";
          childBorder = "#3f3f46";
        };
        urgent = {
          border = "#ef4444";
          background = "#7f1d1d";
          text = "#ffffff";
          indicator = "#ef4444";
          childBorder = "#ef4444";
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
