{ pkgs, ... }:

let
  yaziFileManager = pkgs.writeShellApplication {
    name = "yazi-file-manager";
    text = ''
      target="''${1:-$PWD}"
      exec ${pkgs.foot}/bin/foot -e ${pkgs.yazi}/bin/yazi "$target"
    '';
  };
in
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
    "Mod4+e" = "exec ${yaziFileManager}/bin/yazi-file-manager";
  };

  xdg.desktopEntries.yazi = {
    name = "Yazi";
    genericName = "File Manager";
    comment = "Terminal file manager";
    exec = "${yaziFileManager}/bin/yazi-file-manager %U";
    icon = "system-file-manager";
    categories = [
      "System"
      "FileManager"
    ];
    mimeType = [ "inode/directory" ];
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "yazi.desktop";
    };
  };

  services.udiskie.settings.program_options.file_manager = "${yaziFileManager}/bin/yazi-file-manager";

  home.packages = with pkgs; [
    yaziFileManager

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
