{ config, ... }:

let
  defaultLayout = builtins.readFile "${config.programs.walker.package.src}/resources/themes/default/layout.xml";
  defaultStyle = builtins.readFile "${config.programs.walker.package.src}/resources/themes/default/style.css";
  adaptiveLayout =
    builtins.replaceStrings
      [
        ''<property name="height-request">570</property>''
        ''<property name="min-content-width">500</property>''
        ''<property name="valign">center</property>''
      ]
      [
        ""
        ""
        ''
          <property name="valign">start</property>
          <property name="margin-top">96</property>''
      ]
      defaultLayout;
  adaptiveStyle = ''
    ${defaultStyle}

    .input {
      font-size: 22px;
      padding: 14px 16px;
    }
  '';
in
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

    themes.default = {
      style = adaptiveStyle;
      layouts.layout = adaptiveLayout;
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
