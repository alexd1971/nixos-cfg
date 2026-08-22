{ pkgs, ... }:

let
  json = pkgs.formats.json { };

  # Match the Plymouth NixOS logo size and keep the login fields aligned to it.
  formWidth = 256;
  logoSize = formWidth;

  # GtkImage does not scale a PNG merely because width-request changes.
  # Render the scalable NixOS logo to the exact requested size at build time.
  nixosLogo = pkgs.runCommand "nixos-logo-${toString logoSize}.png" {
    nativeBuildInputs = [ pkgs.imagemagick ];
  } ''
    magick -background none \
      "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg" \
      -resize ${toString logoSize}x${toString logoSize} \
      "$out"
  '';

  colors = {
    background = "#2e3440";
    foreground = "#eceff4";
    secondary = "#d8dee9";
    surface = "rgba(59, 66, 82, 0.95)";
    border = "#4c566a";
    accent = "#88c0d0";
    primary = "#5e81ac";
    primaryHover = "#81a1c1";
    button = "#3f3f46";
    buttonHover = "#52525b";
    buttonBorder = "#52525b";
  };

  systemctl = "${pkgs.systemd}/bin/systemctl";
  sway = "${pkgs.sway}/bin/sway";
  swaymsg = "${pkgs.sway}/bin/swaymsg";

  nwgHelloConfig = json.generate "nwg-hello.json" {
    # Only Sway is available, so session selection stays hidden in the template.
    session_dirs = [ ];
    custom_sessions = [
      {
        name = "Sway";
        exec = sway;
      }
    ];

    monitor_nums = [ ];
    form_on_monitors = [ ];
    delay_secs = 0;

    cmd-sleep = "${systemctl} suspend";
    cmd-reboot = "${systemctl} reboot";
    cmd-poweroff = "${systemctl} poweroff";

    gtk-theme = "Nordic-bluish-accent";
    gtk-icon-theme = "Nordzy-dark";
    gtk-cursor-theme = "Adwaita";
    prefer-dark-theme = true;

    template-name = "nixos.glade";
    time-format = "%H:%M";
    date-format = "%A, %d %B";
    layer = "overlay";
    keyboard-mode = "on_demand";
    lang = "";

    avatar-show = false;
    avatar-size = 100;
    avatar-border-width = 1;
    avatar-border-color = colors.accent;
    avatar-corner-radius = 15;
    avatar-circle = false;

    env-vars = [ ];
  };

  nwgHelloCss = pkgs.writeText "nwg-hello.css" ''
    window {
      background: ${colors.background};
      color: ${colors.foreground};
    }

    #form-wrapper {
      background: transparent;
      border: none;
      box-shadow: none;
      padding: 0;
    }

    entry,
    #form-combo button,
    combobox button {
      background-color: ${colors.surface};
      border: 1px solid ${colors.border};
      border-radius: 12px;
      color: ${colors.foreground};
      min-width: 0;
      padding: 10px 12px;
    }

    entry:focus,
    #form-combo button:focus,
    combobox button:focus {
      border-color: ${colors.accent};
      box-shadow: 0 0 0 1px rgba(136, 192, 208, 0.65);
    }

    #form-combo,
    combobox {
      background: transparent;
      border: none;
      box-shadow: none;
      min-width: ${toString formWidth}px;
      padding: 0;
    }

    #password-entry {
      min-width: ${toString formWidth}px;
    }

    #form-combo arrow,
    combobox arrow {
      color: ${colors.secondary};
    }

    button {
      background: ${colors.button};
      border: 1px solid ${colors.buttonBorder};
      border-radius: 12px;
      color: ${colors.foreground};
      padding: 10px 12px;
    }

    button:hover {
      background: ${colors.buttonHover};
    }

    button:active {
      background: ${colors.primary};
    }

    #login-button {
      background: ${colors.primary};
      border-color: ${colors.accent};
      color: ${colors.foreground};
      font-weight: 600;
      min-width: 80px;
    }

    #login-button:hover {
      background: ${colors.primaryHover};
      color: ${colors.background};
    }

    #welcome-label {
      color: ${colors.foreground};
      font-size: 32px;
      font-weight: 600;
    }

    #clock-label {
      color: ${colors.secondary};
      font-family: monospace;
      font-size: 28px;
    }

    #date-label,
    #form-label,
    checkbutton {
      color: ${colors.secondary};
    }

    #date-label,
    #form-label {
      font-size: 14px;
    }

    #password-entry {
      font-size: 16px;
    }
  '';

  nwgHelloTemplate = pkgs.writeText "nixos.glade" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <interface>
      <requires lib="gtk+" version="3.24"/>

      <object class="GtkWindow" id="main-window">
        <child>
          <object class="GtkBox" id="main-box">
            <property name="visible">True</property>
            <property name="hexpand">True</property>
            <property name="vexpand">True</property>
            <property name="orientation">vertical</property>

            <!-- Power controls. -->
            <child>
              <object class="GtkBox" id="top-actions">
                <property name="visible">True</property>
                <property name="halign">end</property>
                <property name="margin-top">24</property>
                <property name="margin-end">24</property>
                <property name="spacing">8</property>

                <child>
                  <object class="GtkButton" id="btn-sleep">
                    <property name="label" translatable="yes">Sleep</property>
                    <property name="visible">True</property>
                    <property name="can-focus">True</property>
                  </object>
                </child>

                <child>
                  <object class="GtkButton" id="btn-restart">
                    <property name="label" translatable="yes">Restart</property>
                    <property name="visible">True</property>
                    <property name="can-focus">True</property>
                  </object>
                </child>

                <child>
                  <object class="GtkButton" id="btn-poweroff">
                    <property name="label" translatable="yes">Poweroff</property>
                    <property name="visible">True</property>
                    <property name="can-focus">True</property>
                  </object>
                </child>
              </object>
            </child>

            <!-- Centered login form. -->
            <child>
              <object class="GtkBox" id="center-area">
                <property name="visible">True</property>
                <property name="orientation">vertical</property>
                <property name="halign">center</property>
                <property name="valign">center</property>

                <child>
                  <object class="GtkBox" id="form-wrapper">
                    <property name="visible">True</property>
                    <property name="halign">center</property>
                    <property name="orientation">vertical</property>
                    <property name="spacing">6</property>

                    <child>
                      <object class="GtkLabel" id="lbl-welcome">
                        <property name="visible">True</property>
                        <property name="margin-bottom">16</property>
                        <property name="label" translatable="yes">Welcome!</property>
                      </object>
                    </child>

                    <child>
                      <object class="GtkLabel" id="lbl-clock">
                        <property name="visible">True</property>
                        <property name="margin-bottom">8</property>
                        <property name="label">00:00</property>
                      </object>
                    </child>

                    <child>
                      <object class="GtkLabel" id="lbl-date">
                        <property name="visible">True</property>
                        <property name="margin-bottom">18</property>
                        <property name="label">Monday, 13 January</property>
                      </object>
                    </child>

                    <child>
                      <object class="GtkBox" id="fields-box">
                        <property name="visible">True</property>
                        <property name="width-request">${toString formWidth}</property>
                        <property name="halign">center</property>
                        <property name="orientation">vertical</property>
                        <property name="spacing">4</property>

                        <!-- Required by nwg-hello even when avatars are disabled. -->
                        <child>
                          <object class="GtkBox" id="avatar-wrapper">
                            <property name="visible">True</property>
                          </object>
                        </child>

                        <!-- Required IDs; hidden because Sway is the only session. -->
                        <child>
                          <object class="GtkLabel" id="lbl-session">
                            <property name="visible">False</property>
                            <property name="label" translatable="yes">Session:</property>
                          </object>
                        </child>

                        <child>
                          <object class="GtkComboBoxText" id="combo-session">
                            <property name="visible">False</property>
                          </object>
                        </child>

                        <child>
                          <object class="GtkLabel" id="lbl-user">
                            <property name="visible">True</property>
                            <property name="halign">start</property>
                            <property name="label" translatable="yes">User:</property>
                          </object>
                        </child>

                        <child>
                          <object class="GtkComboBoxText" id="combo-user">
                            <property name="visible">True</property>
                            <property name="width-request">${toString formWidth}</property>
                            <property name="halign">fill</property>
                            <property name="hexpand">True</property>
                          </object>
                        </child>

                        <child>
                          <object class="GtkLabel" id="lbl-password">
                            <property name="visible">True</property>
                            <property name="halign">start</property>
                            <property name="margin-top">6</property>
                            <property name="label" translatable="yes">Password:</property>
                          </object>
                        </child>

                        <child>
                          <object class="GtkEntry" id="entry-password">
                            <property name="visible">True</property>
                            <property name="can-focus">True</property>
                            <property name="width-request">${toString formWidth}</property>
                            <property name="halign">fill</property>
                            <property name="hexpand">True</property>
                            <!-- Keep the entry's natural character width from overriding the request. -->
                            <property name="width-chars">1</property>
                            <property name="max-width-chars">1</property>
                          </object>
                        </child>

                        <child>
                          <object class="GtkCheckButton" id="cb-show-password">
                            <property name="label" translatable="yes">Show password</property>
                            <property name="visible">True</property>
                            <property name="can-focus">True</property>
                            <property name="draw-indicator">True</property>
                          </object>
                        </child>

                        <!-- Keep Login physically next to the fields. -->
                        <child>
                          <object class="GtkButton" id="btn-login">
                            <property name="label" translatable="yes">Login</property>
                            <property name="visible">True</property>
                            <property name="can-focus">True</property>
                            <property name="receives-default">True</property>
                            <property name="halign">center</property>
                            <property name="margin-top">2</property>
                          </object>
                        </child>

                        <child>
                          <object class="GtkLabel" id="lbl-message">
                            <property name="visible">True</property>
                            <property name="label"></property>
                          </object>
                        </child>
                      </object>
                    </child>
                  </object>
                </child>
              </object>
              <packing>
                <property name="expand">True</property>
                <property name="fill">True</property>
              </packing>
            </child>

            <!-- This file is already rendered to exactly logoSize x logoSize. -->
            <child>
              <object class="GtkImage" id="nixos-logo">
                <property name="visible">True</property>
                <property name="halign">center</property>
                <property name="margin-bottom">16</property>
                <property name="file">${nixosLogo}</property>
              </object>
            </child>
          </object>
        </child>
      </object>
    </interface>
  '';

  # Run nwg-hello inside the greeter compositor and always terminate that
  # compositor when the greeter exits (successfully or otherwise).
  nwgHelloRunner = pkgs.writeShellScript "nwg-hello-runner" ''
    ${pkgs.nwg-hello}/bin/nwg-hello \
      -c /etc/nwg-hello/nwg-hello.json \
      -s /etc/nwg-hello/nwg-hello.css
    status=$?

    printf '\033[2J\033[H'
    ${swaymsg} exit >/dev/null 2>&1 || true
    exit "$status"
  '';

  greeterSwayConfig = pkgs.writeText "greeter-sway.conf" ''
    font pango:DejaVu Sans 12
    seat * xcursor_theme Adwaita 30

    exec ${nwgHelloRunner}

    input "type:touchpad" {
      tap enabled
      natural_scroll enabled
    }

    input "type:keyboard" {
      xkb_layout us,ru
      xkb_options grp:win_space_toggle
    }
  '';
in
{
  # greetd needs a Wayland compositor around nwg-hello.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${sway} --config ${greeterSwayConfig}";
      user = "greeter";
    };
  };

  environment.etc = {
    "nwg-hello/nwg-hello.json".source = nwgHelloConfig;
    "nwg-hello/nwg-hello.css".source = nwgHelloCss;
    "nwg-hello/nixos.glade".source = nwgHelloTemplate;
  };

  systemd.tmpfiles.rules = [
    "d /var/cache/nwg-hello 0755 greeter greeter - -"
    "f /var/cache/nwg-hello/cache.json 0644 greeter greeter - {}"
  ];

  # Power actions exposed by this greeter: suspend, reboot and power off.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var loginActions = [
        "org.freedesktop.login1.power-off",
        "org.freedesktop.login1.power-off-ignore-inhibit",
        "org.freedesktop.login1.power-off-multiple-sessions",
        "org.freedesktop.login1.reboot",
        "org.freedesktop.login1.reboot-ignore-inhibit",
        "org.freedesktop.login1.reboot-multiple-sessions",
        "org.freedesktop.login1.suspend",
        "org.freedesktop.login1.suspend-ignore-inhibit",
        "org.freedesktop.login1.suspend-multiple-sessions"
      ];

      if (subject.user == "greeter" && loginActions.indexOf(action.id) >= 0) {
        return polkit.Result.YES;
      }
    });
  '';

  # GTK themes/icons must be visible through the system profile so that the
  # greeter user can resolve them by name.
  environment.systemPackages = [
    pkgs.nwg-hello
    pkgs.adwaita-icon-theme
    pkgs.nordic
    pkgs.nordzy-icon-theme
    pkgs.nixos-icons
  ];
}
