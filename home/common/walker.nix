{ ... }:

{
  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      force_keyboard_focus = true;
      close_when_open = true;
      single_click_activation = true;
      hide_action_hints = true;
      hide_action_hints_dmenu = true;

      theme = "adaptive";

      shell = {
        layer = "overlay";
        exclusive_zone = -1;
        anchor_top = true;
        anchor_bottom = true;
        anchor_left = true;
        anchor_right = true;
      };

      placeholders = {
        default = {
          input = "Search";
          list = "";
        };
        desktopapplications = {
          input = "Applications";
          list = "";
        };
        dmenu = {
          input = "Choose";
          list = "";
        };
      };

      providers = {
        default = [
          "desktopapplications"
          "calc"
        ];
        empty = [ ];
        max_results = 40;
        ignore_preview = [ ];
      };
    };

    themes.adaptive = {
      style = builtins.readFile ./walker/style.css;
      layouts.layout = builtins.readFile ./walker/layout.xml;
    };

    elephant.providers = [
      "desktopapplications"
      "providerlist"
      "runner"
      "calc"
      "files"
    ];
  };
}
