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
  # Shared panel for every Sway desktop user.
  programs.waybar = {
    enable = true;

    style = ''
      * {
        font-family: "DejaVu Sans", "Symbols Nerd Font Mono", sans-serif;
        font-size: 16px;
      }

      window#waybar {
        background: rgba(46, 52, 64, 0.96);
        color: #d8dee9;
        min-height: 36px;
      }

      #workspaces button {
        color: #d8dee9;
        padding: 0 10px;
      }

      #workspaces button.focused,
      #workspaces button.active {
        color: #eceff4;
        background: #5e81ac;
        border-radius: 8px;
      }

      #network {
        color: #8fbcbb;
      }

      #pulseaudio {
        color: #b48ead;
      }

      #cpu {
        color: #ebcb8b;
      }

      #memory {
        color: #a3be8c;
      }

      #clock {
        color: #88c0d0;
      }

      #custom-keyboard,
      #custom-launcher,
      #custom-power {
        color: #81a1c1;
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
        on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        on-click-right = "${pkgs.networkmanager_dmenu}/bin/networkmanager_dmenu";
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
        on-click = "${pkgs.gsimplecal}/bin/gsimplecal";
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

  # Launcher settings used by the network module on right click.
  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = ${pkgs.wofi}/bin/wofi --dmenu --insensitive --prompt Networks
    compact = False
    highlight = True
    highlight_fg = #eceff4
    highlight_bg = #5e81ac
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
}
