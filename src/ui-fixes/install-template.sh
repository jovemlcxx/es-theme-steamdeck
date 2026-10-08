#!/bin/bash
# Steam Deck UI Fixes for EmulationStation (arkos4clone) - TEST BUILD: the extra theme sounds and the carousel opacity
# Adds theme sounds the stock frontend never plays: select, back (to system view),
# favorite and quicksysselect, and the carousel's unselectedOpacity theme property. Built WITHOUT the built-in scraper (ScreenScraper/TheGamesDB).
# Copy to /roms/tools/ and run from Options > Tools. Undo with "Disable Steam Deck UI Fixes.sh".
ES=/usr/bin/emulationstation/emulationstation
BAK=$ES.orig-xmbsounds
[ -w /dev/tty1 ] && exec > >(tee /dev/tty1) 2>&1

fail() { echo "ERROR: $*"; echo "Nothing was changed."; sleep 8; exit 1; }

[ "$(uname -m)" = "aarch64" ] || fail "only 64-bit (aarch64) systems are supported"
[ -f "$ES" ] || fail "EmulationStation not found at $ES"

TMP=$(mktemp)
sed -n '/^__PAYLOAD__$/,$p' "$0" | tail -n +2 | base64 -d > "$TMP" || fail "corrupted package"
chmod +x "$TMP"
MISSING=$(ldd "$TMP" 2>&1 | grep "not found")
[ -z "$MISSING" ] || { rm -f "$TMP"; fail "this system lacks libraries the new build needs: $MISSING"; }

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

echo "Installed. Original kept at $BAK"
echo "Restarting EmulationStation..."
sleep 3
sudo systemctl restart emulationstation
exit 0
__PAYLOAD__
