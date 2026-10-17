# Disconnects every OpenVPN3 session of the logged-in desktop user, retrying
# until none is left. Run by a systemd unit around suspend: a tunnel that stays
# up across suspend/resume tends to come back half-dead.
#
# Configuration (environment, set by the NixOS module):
#   OPENVPN3_SUSPEND_ATTEMPTS  number of disconnect rounds before giving up
#   OPENVPN3_SUSPEND_INTERVAL  seconds to wait between two rounds

: "${OPENVPN3_SUSPEND_ATTEMPTS:=20}"
: "${OPENVPN3_SUSPEND_INTERVAL:=3}"

# This service runs as root, but OpenVPN3 sessions are only visible to and
# manageable by the UID that started them (root has no implicit access, unlike
# config-acl's --public-access) - confirmed by journal logs showing "No
# sessions available" as root while a session was actually active. So the
# actual openvpn3 calls must run as the desktop user that owns the session,
# resolved dynamically so the module stays machine- and username-independent.
#
# seat0's ActiveSession is unreliable right at the suspend/resume transition
# (observed empty in the journal at both points, causing this to silently skip
# every time), so use the logged-in user list instead, which doesn't depend on
# VT/seat focus.
target_user=""
while read -r uid user _; do
  if [ "$uid" != "0" ] && [ -n "$user" ]; then
    target_user="$user"
    break
  fi
done < <(loginctl list-users --no-legend 2>/dev/null)
if [ -z "$target_user" ]; then
  echo "openvpn3-suspend-disconnect: could not resolve a logged-in desktop user, skipping" >&2
  exit 0
fi

run_as_user() {
  runuser -u "$target_user" -- openvpn3 "$@"
}

# Same parsing approach as the GNOME extension of this repo: sessions-list has
# no --json output; blocks are dashed-line separated, each with a
# "Config name:" line if a session is active for it.
session_names() {
  run_as_user sessions-list 2>/dev/null | grep -oP '^\s*Config name:\s*\K.+'
}

# `session-manage --disconnect` acks the request without waiting for the actual
# teardown: a session that's mid-(re)connect can ignore it and keep retrying
# for a long time (observed ~50s) before it actually drops. Keep re-issuing the
# disconnect and re-checking sessions-list until it's genuinely empty, instead
# of firing once and assuming it worked.
attempt=0
while [ "$attempt" -lt "$OPENVPN3_SUSPEND_ATTEMPTS" ]; do
  names="$(session_names)"
  [ -z "$names" ] && exit 0
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    echo "openvpn3-suspend-disconnect: disconnecting '$name' as $target_user (attempt $((attempt + 1)))" >&2
    run_as_user session-manage --config "$name" --disconnect || true
  done <<<"$names"
  sleep "$OPENVPN3_SUSPEND_INTERVAL"
  attempt=$((attempt + 1))
done
echo "openvpn3-suspend-disconnect: session(s) still present after retrying: $(session_names)" >&2
