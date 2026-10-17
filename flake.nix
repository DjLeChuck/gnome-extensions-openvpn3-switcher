{
  description = "OpenVPN3 Switcher - GNOME Shell extension to pick the active OpenVPN 3 session";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          openvpn3-switcher = pkgs.callPackage ./package.nix { };
        in
        {
          inherit openvpn3-switcher;
          default = openvpn3-switcher;
        }
      );

      overlays.default = final: _prev: {
        gnomeExtensions-openvpn3-switcher = final.callPackage ./package.nix { };
      };

      nixosModules.default = ./nixos-module.nix;

      # Evaluates a minimal NixOS configuration with the module enabled and
      # builds its script, which also runs shellcheck on it.
      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          eval = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              self.nixosModules.default
              {
                programs.openvpn3.enable = true;
                services.openvpn3-suspend-disconnect.enable = true;
                boot.loader.grub.enable = false;
                fileSystems."/" = {
                  device = "none";
                  fsType = "tmpfs";
                };
                system.stateVersion = "26.05";
              }
            ];
          };
          exec = eval.config.systemd.services.openvpn3-suspend-disconnect.serviceConfig.ExecStart;
        in
        {
          suspend-disconnect-module = pkgs.runCommand "openvpn3-suspend-disconnect-module-check" { } ''
            test -x ${exec}
            touch $out
          '';
        }
      );

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
