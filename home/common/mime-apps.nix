{
  xdg.mimeApps = {
    enable = true;

    associations.added = {
      "x-scheme-handler/slack" = [ "slack.desktop" ];
    };

    defaultApplications = {
      "inode/directory" = [ "yazi.desktop" ];
      "x-scheme-handler/slack" = [ "slack.desktop" ];
    };
  };
}
