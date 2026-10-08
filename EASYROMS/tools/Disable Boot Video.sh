#!/bin/bash
# Disable Boot Video: undoes "Enable Boot Video.sh" on every supported system. Your boot.mp4 stays in the boot partition.
[ -w /dev/tty1 ] && exec > >(tee /dev/tty1) 2>&1

# Batocera / Knulli
if [ -d /userdata/system ] && command -v batocera-settings-get >/dev/null 2>&1; then
  rm -f /userdata/splash/boot.mp4
  echo "Boot video removed from the Batocera/Knulli splash."
  sleep 5; exit 0
fi
# EmuELEC
if [ -d /storage/.config/emuelec ]; then
  rm -f /storage/roms/splash/intro.mp4
  . /etc/profile 2>/dev/null
  command -v set_ee_setting >/dev/null 2>&1 && set_ee_setting ee_bootvideo.enabled 0
  echo "Boot video removed from the EmuELEC intro."
  sleep 5; exit 0
fi

# systemd family
sudo systemctl disable bootvideo.service >/dev/null 2>&1
sudo rm -f /etc/systemd/system/bootvideo.service /usr/local/bin/bootvideo.sh /usr/local/bin/bootvideo-fb.py \
  /etc/systemd/system/multi-user.target.wants/bootvideo.service
sudo rm -f /etc/systemd/system/welcome-message.service.d/bootvideo.conf
sudo rmdir /etc/systemd/system/welcome-message.service.d 2>/dev/null
for ini in /boot/boot.ini /flash/boot.ini; do
  [ -f "$ini" ] && grep -q ' vt\.color=0x00' "$ini" && sudo sed -i -e '/^setenv bootargs "/ s/ vt\.color=0x00 vt\.global_cursor_default=0//' -e '/^setenv bootargs "/ s/ vt\.color=0x00//' "$ini"
done
sudo systemctl daemon-reload
sync
echo "Boot video disabled. The boot terminals are back."
sleep 5
exit 0
