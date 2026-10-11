#!/bin/bash
# Packs ONE system's patched binary into its own self-installing script, with the fork-guard baked in.
#   bash pack.sh <system>        e.g. bash pack.sh arkos4clone
# Reads es-fcamod-sounds/systems/<system>/{emulationstation,system.env}, fills SYSNAME/FINGERPRINT into
# install-template.sh, appends the binary, and writes "Enable Steam Deck UI Fixes (<system>).sh" to ../tools.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
SYS="${1:?usage: pack.sh <system>}"
D="$HERE/systems/$SYS"
[ -f "$D/emulationstation" ] && [ -f "$D/system.env" ] || { echo "missing $D/emulationstation or system.env"; exit 1; }
SYSNAME=; FINGERPRINT=; FINGERPRINT2=; EXCLUDE=; . "$D/system.env"
[ -n "$FINGERPRINT" ] || { echo "system.env has no FINGERPRINT"; exit 1; }
# the binary must actually contain its own fingerprint(s) (catches a wrong/stale build)
LC_ALL=C grep -a -q -F "$FINGERPRINT" "$D/emulationstation" || { echo "binary lacks fingerprint '$FINGERPRINT' -- wrong build?"; exit 1; }
[ -z "$FINGERPRINT2" ] || LC_ALL=C grep -a -q -F "$FINGERPRINT2" "$D/emulationstation" || { echo "binary lacks fingerprint2 '$FINGERPRINT2' -- wrong build?"; exit 1; }
# and must NOT contain its own exclude marker (would mean a mislabeled build)
[ -z "$EXCLUDE" ] || ! LC_ALL=C grep -a -q -F "$EXCLUDE" "$D/emulationstation" || { echo "binary contains EXCLUDE '$EXCLUDE' -- mislabeled build?"; exit 1; }

OUT="$HERE/../tools/Enable Steam Deck UI Fixes ($SYSNAME).sh"   # named after the system as users know it
mkdir -p "$HERE/../tools"
sed -e "s/@SYSNAME@/$SYSNAME/g" -e "s/@FINGERPRINT@/$FINGERPRINT/g" -e "s/@FINGERPRINT2@/$FINGERPRINT2/g" -e "s/@EXCLUDE@/$EXCLUDE/g" "$HERE/install-template.sh" > /tmp/inst.$$
{ cat /tmp/inst.$$; base64 "$D/emulationstation"; } > "$OUT"
rm -f /tmp/inst.$$
cp "$HERE/Disable Steam Deck UI Fixes.sh" "$HERE/../tools/"
ls -la "$OUT"
