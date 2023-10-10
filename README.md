# armcord-hm

A home-manager module for ArmCord that allows you to set ArmCord options, Vencord options and your token from within your config.

How to use?

1. Add it to your flake inputs

```nix
# ...
  inputs.armcord-hm = {
    url = "github:n3oney/armcord-hm";
    inputs.nixpkgs.follows = "nixpkgs";
  };
# ...
```

2. Import the Home Manager module

```nix
# ...
  imports = [ inputs.armcord-hm.homeManagerModules.default ];
# ...
```

3. Enable it and configure!

```nix

# ...
  programs.armcord = {
    enable = true;
    # optional, will sign you in with this token every time
    # Agenix recommended, your user needs to have access to this file.
    tokenFile = "/some/file/with/plaintext_token";
    # attrset of armcord settings, saved in $XDG_CONFIG_HOME/ArmCord/storage/settings.json
    armcordSettings = {
      # here's mine:
      alternativePaste = false;
      armcordCSP = true;
      automaticPatches = false;
      channel = "canary";
      disableAutogain = true;
      minimizeToTray = true;
      multiInstance = false;
      performanceMode = "performance";
      skipSplash = true;
      spellcheck = true;
      startMinimized = false;
      tray = true;
      trayIcon = "default";
      useLegacyCapturer = false;
      windowStyle = "transparent";
    };
    # attrset of vencord settings, saved in app's LocalStorage on every launch.
    vencordSettings = {
      # There's too many options available, and I haven't listed them anywhere. Please refer to https://github.com/n3oney/nixus/blob/a214ced4ed7951d9e57bc325c9f15f2def7a7aaa/modules/programs/discord/discord.nix
    };
  };
# ...

```
