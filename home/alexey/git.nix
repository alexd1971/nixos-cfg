{
  # Minimal identity for local commits; replace the email when publishing changes.
  programs.git = {
    enable = true;
    settings.user.name = "alexey";
    settings.user.email = "alexey@localhost";
  };
}
