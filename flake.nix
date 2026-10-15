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

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
