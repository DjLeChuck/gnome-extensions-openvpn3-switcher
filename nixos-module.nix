{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.openvpn3-suspend-disconnect;

  script = pkgs.writeShellApplication {
    name = "openvpn3-suspend-disconnect";
    runtimeInputs = [
      cfg.package
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.systemd
      pkgs.util-linux
    ];
    # Same as the original script: only `set -u`. `set -e`/`pipefail` would
    # abort on the expected non-zero exits (grep with no match, a disconnect
    # that fails and is retried on the next round).
    bashOptions = [ "nounset" ];
    text = ''
      export OPENVPN3_SUSPEND_ATTEMPTS=${toString cfg.attempts}
      export OPENVPN3_SUSPEND_INTERVAL=${toString cfg.retryInterval}

      ${builtins.readFile ./suspend-disconnect.sh}
    '';
  };
in
{
  options.services.openvpn3-suspend-disconnect = {
    enable = lib.mkEnableOption "disconnecting OpenVPN3 sessions before the machine suspends";

    package = lib.mkOption {
      type = lib.types.package;
      default = config.programs.openvpn3.package;
      defaultText = lib.literalExpression "config.programs.openvpn3.package";
      description = "The openvpn3 package providing the CLI used to list and disconnect sessions.";
    };

    attempts = lib.mkOption {
      type = lib.types.ints.positive;
      default = 20;
      description = ''
        How many times to re-issue the disconnect and re-check the session list.
        A session that is mid-(re)connect can ignore a disconnect request for a
        long time, so a single attempt is not enough.
      '';
    };

    retryInterval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3;
      description = "Seconds to wait between two attempts.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.openvpn3-suspend-disconnect = {
      description = "Disconnect any active OpenVPN3 session around suspend/resume";
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      unitConfig.StopWhenUnneeded = true;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # Headroom above the script's own retry loop, so systemd doesn't kill
        # it mid-retry.
        TimeoutSec = "${toString (cfg.attempts * cfg.retryInterval + 60)}s";
        ExecStart = "${script}/bin/openvpn3-suspend-disconnect";
        ExecStop = "${script}/bin/openvpn3-suspend-disconnect";
      };
    };
  };
}
