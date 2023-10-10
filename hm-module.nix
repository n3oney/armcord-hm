self: {
  config,
  pkgs,
  lib,
  hm,
  ...
}: let
  cfg = config.programs.armcord;
  json = pkgs.formats.json {};

  leveldb-cli = self.packages.${pkgs.system}.leveldb-cli;

  defaultPackage = pkgs.armcord;
in {
  meta.maintainers = [lib.maintainers.n3oney];

  options.programs.armcord = with lib; {
    enable = mkEnableOption "armcord";

    package = mkOption {
      type = with types; nullOr package;
      default = defaultPackage;
      defaultText = literalExpression "pkgs.armcord";
      description = mdDoc "ArmCord package to use. Defaults to armcord from nixpkgs.";
    };

    armcordSettings = mkOption {
      default = {};
      type = types.submodule {
        freeformType = json.type;
        options = {
          alternativePaste = mkEnableOption "If you're on Gnome or just simply can't paste images copied from other messages, enable this.";
          armcordCSP = mkEnableOption "Client mods and themes depend on this." // {default = true;};
          automaticPatches = mkEnableOption "Automatic patches distributed if a release turns out to have bugs.";
          channel = mkOption {
            default = "stable";
            type = types.enum ["stable" "canary" "ptb"];
          };
          customCssBundle = mkOption {
            type = types.str;
            default = "https://armcord.app/placeholder.css";
          };
          customJsBundle = mkOption {
            type = types.str;
            default = "https://armcord.app/placeholder.js";
          };
          customIcon = mkOption {
            type = types.path;
            default = "${cfg.package}/opt/ArmCord/resources/app.asar/assets/desktop.png";
          };
          disableAutogain = mkEnableOption "Disables autogain.";
          dynamicIcon = mkEnableOption "Shows unread messages on ArmCord's icon instead of it's tray.";
          minimizeToTray = mkEnableOption "Allow minimizing ArmCord to tray.";
        };
      };
      description = mdDoc "ArmCord's settings.";
    };

    vencordSettings = mkOption {
      type = json.type;
      default = {};
      defaultText = literalExpression "{}";
      description = mdDoc "Vencord's settings.";
    };

    tokenFile = mkOption {
      type = with types; nullOr path;
      default = null;
      defaultText = literalExpression "null";
      description = mdDoc "File path containing token of your Discord account";
    };
  };

  config = lib.mkIf cfg.enable (let
    channel =
      if cfg.armcordSettings.channel == "stable"
      then ""
      else "${cfg.armcordSettings.channel}.";
  in {
    home.packages = [
      (pkgs.runCommand "armcord-hm" {} ''
        mkdir $out
        ln -s ${cfg.package}/* $out
        rm $out/bin
        mkdir $out/bin
        for bin in ${cfg.package}/bin/*; do
         wrapped_bin=$out/bin/$(basename $bin)
         echo "#!${pkgs.bash}/bin/bash
           # set Vencord settings
           DBPATH=\"\''${XDG_CONFIG_HOME:-\$HOME/.config}/ArmCord/Local Storage/leveldb\" ${leveldb-cli}/bin/leveldb-cli put \"_https://${channel}discord.com\0\x01VencordSettings\" \"\$(printf '\\001${lib.escape ["\""] (builtins.toJSON cfg.vencordSettings)}')\"
           ${
          if cfg.tokenFile != null
          then ''DBPATH=\"\''${XDG_CONFIG_HOME:-\$HOME/.config}/ArmCord/Local Storage/leveldb\" ${leveldb-cli}/bin/leveldb-cli put \"_https://${channel}discord.com\0\x01token\" \"\$(printf '\\001')\\\"\$(cat '${lib.escape ["\""] cfg.tokenFile}')\\\"\"''
          else ""
        }
           exec $bin \$@
         " > $wrapped_bin
         chmod +x $wrapped_bin
        done
      '')
    ];

    xdg.configFile."ArmCord/storage/settings.json".text = builtins.toJSON (cfg.armcordSettings
      // {
        doneSetup = true;
        mods = "vencord";
        keybinds = [];
      });
  });
}
