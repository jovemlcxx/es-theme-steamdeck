#!/bin/bash
# Packs out/emulationstation (sounds + carousel opacity patches) into a single self-installing "Enable Steam Deck UI Fixes.sh"
# and copies it, with "Disable Steam Deck UI Fixes.sh", to ../tools (console-ready folder).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
OUT="$HERE/Enable Steam Deck UI Fixes.sh"
{ cat "$HERE/install-template.sh"; base64 "$HERE/out/emulationstation"; } > "$OUT"
mkdir -p "$HERE/../tools"
cp "$OUT" "$HERE/Disable Steam Deck UI Fixes.sh" "$HERE/../tools/"
ls -la "$OUT"
