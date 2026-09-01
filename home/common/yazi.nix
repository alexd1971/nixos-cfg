{ pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    plugins = {
      mount = pkgs.yaziPlugins.mount;
    };

    settings = {
      mgr = {
        show_hidden = true;
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "size";
        show_symlink = true;
      };
    };

    keymap.mgr.prepend_keymap = [
      {
        on = [ "M" ];
        run = "plugin mount";
        desc = "Open mount manager";
      }
    ];
  };

  wayland.windowManager.sway.config.keybindings = {
    "Mod4+e" = "exec ${pkgs.foot}/bin/foot -e ${pkgs.yazi}/bin/yazi";
  };

  xdg.desktopEntries.yazi = {
    name = "Yazi";
    genericName = "File Manager";
    comment = "Terminal file manager";
    exec = "${pkgs.foot}/bin/foot -e ${pkgs.yazi}/bin/yazi";
    icon = "system-file-manager";
    terminal = false;
    categories = [
      "System"
      "FileManager"
    ];
  };

  home.packages = with pkgs; [
    # Archive helpers used by Yazi open/extract actions.
    ouch
    p7zip
    unzip

    # Preview helpers for common document, media, and text formats.
    ffmpegthumbnailer
    jq
    poppler-utils
  ];
}
