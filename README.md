# OpenVPN3 Switcher

A GNOME Shell extension that adds a VPN indicator to the top bar to pick,
connect and disconnect [OpenVPN 3](https://github.com/OpenVPN/openvpn3-linux)
sessions without opening a terminal.

## Features

- Lists every imported `openvpn3` configuration and lets you start one with a
  single click (one active session at a time).
- Panel icon reflects the state: connected, pending, disconnected.
- Opens the SSO / web authentication URL automatically in your browser.
- Desktop notifications on connect, disconnect and connection failure.
- Refreshes its state after the machine resumes from suspend.
- Translations: English, French (see [Contributing](#contributing)).

## Requirements

- GNOME Shell 50 (see `shell-version` in `metadata.json`)
- The `openvpn3` CLI available in the shell's `PATH`, with at least one
  configuration imported (`openvpn3 config-import`)

## Installation

### Nix flake

Add the flake as an input and install the package:

```nix
# flake.nix
inputs.openvpn3-switcher = {
  url = "github:DjLeChuck/gnome-extensions-openvpn3-switcher";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```nix
# NixOS configuration
environment.systemPackages = [
  inputs.openvpn3-switcher.packages.${pkgs.stdenv.hostPlatform.system}.default
];

# home-manager: enable it in GNOME
dconf.settings."org/gnome/shell".enabled-extensions = [
  inputs.openvpn3-switcher.packages.${pkgs.stdenv.hostPlatform.system}.default.extensionUuid
];
```

### Manual

```sh
git clone https://github.com/DjLeChuck/gnome-extensions-openvpn3-switcher
cd gnome-extensions-openvpn3-switcher
make install   # needs gettext (msgfmt)
```

Log out and back in (Wayland), then:

```sh
gnome-extensions enable openvpn3-switcher@djlechuck
```

## Contributing

Translations live in `po/<lang>.po`; copy `po/fr.po`, translate the `msgstr`
entries and open a pull request. Strings are wrapped with `_()` in
`extension.js`.

## License

[MIT](LICENSE)
