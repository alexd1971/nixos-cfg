{ pkgs, ... }:

{
  # Cover Latin, Cyrillic, metric-compatible fonts, and emoji out of the box.
  fonts.packages = with pkgs; [
    dejavu_fonts
    liberation_ttf
    noto-fonts
    noto-fonts-color-emoji
  ];
}
