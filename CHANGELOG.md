# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-10-15

### Added

- NixOS module `nixosModules.default` (`services.openvpn3-suspend-disconnect`)
  disconnecting the logged-in user's OpenVPN 3 sessions before suspend.

## [1.0.0] - 2026-10-15

First public release.

### Added

- Top bar indicator listing the imported `openvpn3` configurations, to start
  or disconnect a session from the menu.
- Panel icon reflecting the connected, pending and disconnected states, with
  automatic refresh after SSO authentication.
- Automatic opening of the web authentication URL in the default browser.
- Desktop notifications on connect, disconnect and connection failure,
  staggered to avoid a GNOME Shell 50.2 notification bug.
- State polling (fast while pending, slow once connected).
- State refresh after the machine resumes from suspend.
- French translation.
- Nix flake (package and overlay), `Makefile` for manual installs, and CI.

[Unreleased]: https://github.com/DjLeChuck/gnome-extensions-openvpn3-switcher/compare/v1.1.0...HEAD

[1.1.0]: https://github.com/DjLeChuck/gnome-extensions-openvpn3-switcher/compare/v1.0.0...v1.1.0

[1.0.0]: https://github.com/DjLeChuck/gnome-extensions-openvpn3-switcher/releases/tag/v1.0.0
