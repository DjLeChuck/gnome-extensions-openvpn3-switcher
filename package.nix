{
  lib,
  stdenvNoCC,
  gettext,
}:

let
  uuid = "openvpn3-switcher@djlechuck";
  domain = "openvpn3-switcher";
in
stdenvNoCC.mkDerivation {
  pname = "gnome-shell-extension-openvpn3-switcher";
  version = "1.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./metadata.json
      ./extension.js
      ./po
    ];
  };

  nativeBuildInputs = [ gettext ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    targetDir=$out/share/gnome-shell/extensions/${uuid}
    mkdir -p "$targetDir"
    install -Dm444 metadata.json "$targetDir/metadata.json"
    install -Dm444 extension.js  "$targetDir/extension.js"

    for po in po/*.po; do
      lang=$(basename "$po" .po)
      mkdir -p "$targetDir/locale/$lang/LC_MESSAGES"
      msgfmt "$po" -o "$targetDir/locale/$lang/LC_MESSAGES/${domain}.mo"
    done

    runHook postInstall
  '';

  passthru.extensionUuid = uuid;

  meta = {
    description = "GNOME Shell extension to pick the active OpenVPN 3 session from the top bar";
    homepage = "https://github.com/DjLeChuck/gnome-extensions-openvpn3-switcher";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
