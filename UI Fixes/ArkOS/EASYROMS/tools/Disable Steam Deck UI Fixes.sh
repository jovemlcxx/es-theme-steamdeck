#!/bin/bash
# Undoes "Enable Steam Deck UI Fixes.sh": puts the original EmulationStation binary back and removes the loading-screen logo.
ES=/usr/bin/emulationstation/emulationstation
BAK=$ES.orig-xmbsounds
[ -w /dev/tty1 ] && exec > >(tee /dev/tty1) 2>&1

if [ ! -f "$BAK" ]; then
  echo "No backup found at $BAK - nothing to restore."
  sleep 6
  exit 1
fi
sudo rm -f /home/ark/.emulationstation/resources/splash.svg
sudo rmdir /home/ark/.emulationstation/resources 2>/dev/null
sudo cp -p "$BAK" "$ES.new" && sudo mv -f "$ES.new" "$ES" && sudo rm -f "$BAK" && sync
echo "Original EmulationStation restored. Restarting..."
sleep 3
sudo systemctl restart emulationstation
