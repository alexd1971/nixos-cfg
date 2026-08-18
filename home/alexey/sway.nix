{ pkgs, ... }:

{
  programs.foot.enable = true;
  programs.waybar.enable = true;
  programs.wofi.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;

    config = {
      modifier = "Mod4";
      terminal = "foot";
      menu = "wofi --show drun";

      bars = [
        {
          command = "waybar";
        }
      ];

      keybindings =
        let
          modifier = "Mod4";
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
          "${modifier}+space" = "floating toggle";
        };
    };
  };
}
