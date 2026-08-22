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
      theme = "default";

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
          list = "No results";
        };
        desktopapplications = {
          input = "Applications";
          list = "No applications";
        };
        dmenu = {
          input = "Choose";
          list = "No options";
        };
      };

      providers = {
        default = [
          "desktopapplications"
          "calc"
        ];
        empty = [ "desktopapplications" ];
        max_results = 40;
        ignore_preview = [ ];
      };
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
