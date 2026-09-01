{ ... }:

{
  # User-facing Wayland applications configured through Home Manager.
  programs.foot = {
    enable = true;
    settings.main = {
      font = "DejaVu Sans Mono:size=14";
    };
  };

  wayland.windowManager.sway = {
    enable = true;

    config = {
      # Keep the same keyboard/touchpad defaults in the user session and greeter.
      bindkeysToCode = true;
      modifier = "Mod4";
      terminal = "foot";
      menu = "walker";
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
          border = "#88c0d0";
          background = "#2e3440";
          text = "#eceff4";
          indicator = "#81a1c1";
          childBorder = "#88c0d0";
        };
        focusedInactive = {
          border = "#4c566a";
          background = "#2e3440";
          text = "#d8dee9";
          indicator = "#434c5e";
          childBorder = "#4c566a";
        };
        unfocused = {
          border = "#3b4252";
          background = "#2e3440";
          text = "#d8dee9";
          indicator = "#3b4252";
          childBorder = "#3b4252";
        };
        urgent = {
          border = "#bf616a";
          background = "#3b4252";
          text = "#eceff4";
          indicator = "#bf616a";
          childBorder = "#bf616a";
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
          "${modifier}+d" = "exec walker";
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
