{ ... }:

{
  programs.foot.enable = true;
  programs.waybar.enable = true;
  programs.wofi.enable = true;

  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4";
      terminal = "foot";
      menu = "wofi --show drun";

      input."type:touchpad" = {
        tap = "enabled";
        natural_scroll = "enabled";
      };

      input."type:keyboard" = {
        xkb_layout = "us,ru";
        xkb_options = "grp:win_space_toggle";
      };

      bars = [
        {
          command = "waybar";
        }
      ];

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
          switchToWorkspace =
            ws:
            {
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
