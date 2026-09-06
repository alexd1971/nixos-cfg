{ pkgs, ... }:

{
  services.udiskie.settings.program_options.file_manager = "${pkgs.thunar}/bin/thunar";

  xdg.configFile."Thunar/uca.xml".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <actions>
    <action>
      <icon>view-preview</icon>
      <name>Preview with Sushi</name>
      <submenu></submenu>
      <unique-id>2026090500000000-1</unique-id>
      <command>${pkgs.sushi}/bin/sushi %f</command>
      <description>Preview selected file with Sushi</description>
      <range>*</range>
      <patterns>*</patterns>
      <other-files/>
      <text-files/>
      <image-files/>
      <audio-files/>
      <video-files/>
    </action>
    </actions>
  '';
  xdg.configFile."Thunar/accels.scm".text = ''
    (gtk_accel_path "<Actions>/ThunarActions/uca-action-2026090500000000-1" "space")
  '';
}
