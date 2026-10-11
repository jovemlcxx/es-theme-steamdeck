#!/bin/bash
# Steam Deck UI Fixes for EmulationStation -- @SYSNAME@ build.
# Adds ONLY two things to this distro's own EmulationStation: the theme sounds it never plays
# (select, back, favorite, quicksysselect) and the <carousel> unselectedOpacity theme property.
# Everything else (menus, Wi-Fi, hardware settings) is this distro's own ES, untouched: the
# binary here was built from @SYSNAME@'s own ES source, so it is that frontend plus the two features.
#
# SAFETY: it refuses to run unless the ES already on the device is this same frontend (it must
# contain the fingerprint below). So this file can only ever replace its own distro's ES -- run the
# wrong one and it changes nothing. Copy to /roms/tools/ and run from Options > Tools.
# Undo with "Disable Steam Deck UI Fixes.sh".
SYSNAME="@SYSNAME@"
FINGERPRINT="@FINGERPRINT@"
FINGERPRINT2="@FINGERPRINT2@"  # if set, the current ES must ALSO contain this (two markers pin one frontend)
EXCLUDE="@EXCLUDE@"   # if set, refuse when the current ES contains it (a different, customized frontend)
ES=/usr/bin/emulationstation/emulationstation
BAK=$ES.orig-xmbsounds
[ -w /dev/tty1 ] && exec > >(tee /dev/tty1) 2>&1

fail() { echo "ERROR: $*"; echo "Nothing was changed."; sleep 8; exit 1; }

echo "----------------------------------------------------------------"
echo "  Steam Deck UI Fixes ($SYSNAME)"
echo ""
echo "  Updates EmulationStation with the theme's extras (opaque"
echo "  capsules and sounds). It makes a backup first and can be undone"
echo "  anytime with \"Disable Steam Deck UI Fixes.sh\". Installed by you,"
echo "  at your own choice and risk. Starting in a few seconds..."
echo "----------------------------------------------------------------"
sleep 5

[ "$(uname -m)" = "aarch64" ] || fail "only 64-bit (aarch64) systems are supported"
[ -f "$ES" ] || fail "EmulationStation not found at $ES"

# fork guard: the ES currently installed must be the same frontend this build is made for.
if ! LC_ALL=C grep -a -q -F "$FINGERPRINT" "$ES"; then
	fail "this is the $SYSNAME build, but the EmulationStation on this device is not $SYSNAME. Use the build that matches your system."
fi
if [ -n "$FINGERPRINT2" ] && ! LC_ALL=C grep -a -q -F "$FINGERPRINT2" "$ES"; then
	fail "this is the $SYSNAME build, but the EmulationStation on this device is not $SYSNAME. Use the build that matches your system."
fi
# exclusion guard: refuse on a different, more-customized frontend that shares the same marker
# (e.g. dArkOSen has extra Wi-Fi/BT managers a plain build would delete), so this never strips features.
if [ -n "$EXCLUDE" ] && LC_ALL=C grep -a -q -F "$EXCLUDE" "$ES"; then
	fail "this device's EmulationStation is a customized build (has '$EXCLUDE'); the $SYSNAME build would remove those features. Use the build that matches your system."
fi

TMP=$(mktemp)
sed -n '/^__PAYLOAD__$/,$p' "$0" | tail -n +2 | base64 -d > "$TMP" || fail "corrupted package"
chmod +x "$TMP"
MISSING=$(ldd "$TMP" 2>&1 | grep "not found")
[ -z "$MISSING" ] || { rm -f "$TMP"; fail "this system lacks libraries the new build needs: $MISSING"; }

# the patched build must itself be the same frontend (guards against a mismatched payload)
LC_ALL=C grep -a -q -F "$FINGERPRINT" "$TMP" || { rm -f "$TMP"; fail "internal: payload is not the $SYSNAME frontend"; }

[ -f "$BAK" ] || sudo cp -p "$ES" "$BAK" || fail "could not back up the original binary"
sudo cp "$TMP" "$ES.new" && sudo chmod 777 "$ES.new" && sudo mv -f "$ES.new" "$ES" || fail "could not install"
rm -f "$TMP"

# the loading-screen logo: ES draws :/splash.svg and looks in ~/.emulationstation/resources first, so this replaces it
# for the ark user without touching ES's own files ("Disable Steam Deck UI Fixes.sh" deletes it again)
SPL=/home/ark/.emulationstation/resources
sudo mkdir -p "$SPL" && sudo tee "$SPL/splash.svg" >/dev/null <<'SVG'
<svg xmlns="http://www.w3.org/2000/svg" width="240" height="270" viewBox="-80 -90 240 270"><path d="M40 6.5A38.5 38.5 0 0 1 40 83.5L40 74A29 29 0 0 0 40 16Z" fill="#fff"/><circle cx="40" cy="45" r="19.5" fill="#25a6fa"/></svg>
SVG
sudo chown -R ark:ark /home/ark/.emulationstation 2>/dev/null
sync

echo "Installed the $SYSNAME build. Original kept at $BAK"
echo "Restarting EmulationStation..."
sleep 3
sudo systemctl restart emulationstation
exit 0
__PAYLOAD__
