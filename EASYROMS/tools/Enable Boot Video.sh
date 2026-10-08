#!/bin/bash
# Enable Boot Video - plays boot.mp4 (put it in the boot partition: /boot or /flash) at every boot.
#
#  ArkOS, arkos4clone, darkos4clone, dArkOS (RE-R36, en), ArchR
#      a systemd service runs after the boot logo and before EmulationStation; the "Welcome to ..." text screen is
#      skipped while boot.mp4 exists and boot.ini gets vt.color=0x00 (console text black on black until the video
#      service has run), so no terminal shows. (ArchR: untested, players ffplay or mpv.)
#  Batocera, Knulli
#      their own boot splash plays every .mp4 of /userdata/splash: the video is copied there.
#  EmuELEC
#      its own intro video: copied to /storage/roms/splash/intro.mp4 and "always show boot video" is switched on.
#
# Copy to the tools folder and run it. Undo with "Disable Boot Video.sh".
[ -w /dev/tty1 ] && exec > >(tee /dev/tty1) 2>&1

fail() { echo "ERROR: $*"; echo "Nothing was changed."; sleep 8; exit 1; }
done_msg() { echo "$*"; sleep 6; exit 0; }

VIDEO=
for p in /boot/boot.mp4 /flash/boot.mp4 /userdata/boot.mp4; do [ -f "$p" ] && VIDEO="$p" && break; done

# ---------------------------------------------------------------- Batocera / Knulli
if [ -d /userdata/system ] && command -v batocera-settings-get >/dev/null 2>&1; then
  [ -n "$VIDEO" ] || fail "boot.mp4 not found in /boot or /userdata"
  mkdir -p /userdata/splash && cp -f "$VIDEO" /userdata/splash/boot.mp4 || fail "could not copy to /userdata/splash"
  batocera-settings-set splash.screen.enabled 1 >/dev/null 2>&1
  sync
  others=$(find /userdata/splash -maxdepth 1 -iname '*.mp4' ! -name boot.mp4 | wc -l)
  [ "$others" -gt 0 ] && echo "Note: $others other video(s) in /userdata/splash; the splash picks one at random."
  done_msg "Boot video enabled (Batocera/Knulli splash)."
fi

# ---------------------------------------------------------------- EmuELEC
if [ -d /storage/.config/emuelec ]; then
  [ -n "$VIDEO" ] || fail "boot.mp4 not found in /flash, /boot or /userdata"
  mkdir -p /storage/roms/splash && cp -f "$VIDEO" /storage/roms/splash/intro.mp4 || fail "could not copy the video"
  . /etc/profile 2>/dev/null
  command -v set_ee_setting >/dev/null 2>&1 && set_ee_setting ee_bootvideo.enabled 1
  sync
  done_msg "Boot video enabled (EmuELEC intro)."
fi

# ---------------------------------------------------------------- systemd family
command -v systemctl >/dev/null || fail "this system is not supported"
PLAYER=
command -v ffplay >/dev/null && PLAYER=ffplay
[ -z "$PLAYER" ] && command -v mpv >/dev/null && PLAYER=mpv
[ -z "$PLAYER" ] && command -v python3 >/dev/null && command -v ffmpeg >/dev/null && PLAYER=ffmpeg
[ -n "$PLAYER" ] || fail "no video player found (ffplay, mpv or ffmpeg+python3)"
ES_UNIT=
for u in emulationstation emustation; do
  systemctl cat "$u.service" >/dev/null 2>&1 && ES_UNIT="$u.service" && break
done
[ -n "$ES_UNIT" ] || fail "the EmulationStation service was not found"
BOOT=/boot
[ -f /flash/boot.mp4 ] && BOOT=/flash
mountpoint -q "$BOOT" || fail "$BOOT is not the boot partition on this system"

# the player: runs after everything else at boot and never fails the boot. It prefers bootvideo-fb.py (ffmpeg
# decodes, the frames go straight to the framebuffer: no window, so no mouse cursor); ffplay / mpv are the fallback.
sudo tee /usr/local/bin/bootvideo-fb.py >/dev/null <<'EOF'
import os, subprocess, sys
V = sys.argv[1]
W, H = [int(x) for x in open("/sys/class/graphics/fb0/virtual_size").read().strip().split(",")]
size = W * H * 4  # 32 bit framebuffer, checked by the caller
fb = os.open("/dev/fb0", os.O_WRONLY)
vf = subprocess.Popen(["ffmpeg", "-loglevel", "quiet", "-re", "-i", V, "-an", "-vf",
    "scale=%d:%d:force_original_aspect_ratio=decrease,pad=%d:%d:(ow-iw)/2:(oh-ih)/2,format=bgra" % (W, H, W, H),
    "-f", "rawvideo", "-"], stdout=subprocess.PIPE, stdin=subprocess.DEVNULL)
af = subprocess.Popen(["ffmpeg", "-loglevel", "quiet", "-i", V, "-vn", "-f", "alsa", "default"],
    stdin=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
frames = 0
while True:
    buf = b""
    while len(buf) < size:
        c = vf.stdout.read(size - len(buf))
        if not c:
            break
        buf += c
    if len(buf) < size:
        break
    os.pwrite(fb, buf, 0)
    frames += 1
af.terminate()
sys.exit(0 if frames else 1)
EOF
sudo tee /usr/local/bin/bootvideo.sh >/dev/null <<'EOF'
#!/bin/bash
V=
for d in /boot /flash; do [ -f "$d/boot.mp4" ] && V="$d/boot.mp4" && break; done
T=/dev/tty1
# KD_GRAPHICS: the kernel console stops drawing (no blinking text cursor under the video); KD_TEXT gives it back
kd() { command -v python3 >/dev/null && python3 -c "import fcntl,os;fcntl.ioctl(os.open('$T',os.O_RDWR),0x4B3A,$1)" 2>/dev/null; }
if [ -n "$V" ]; then
  printf '[?25l[2J' > $T 2>/dev/null
  echo 0 > /sys/class/graphics/fbcon/cursor_blink 2>/dev/null
  kd 1
  played=
  if command -v python3 >/dev/null && command -v ffmpeg >/dev/null      && [ "$(cat /sys/class/graphics/fb0/bits_per_pixel 2>/dev/null)" = 32 ]; then
    timeout 90 python3 /usr/local/bin/bootvideo-fb.py "$V" </dev/null >/dev/null 2>&1 && played=1
  fi
  if [ -z "$played" ] && command -v ffplay >/dev/null; then
    read -r X Y <<< "$(tr ',' ' ' < /sys/class/graphics/fb0/virtual_size 2>/dev/null)"
    export SDL_VIDEO_EGL_DRIVER=libEGL.so
    timeout 90 ffplay -loglevel quiet -nostats -autoexit -fs -x "${X:-640}" -y "${Y:-480}" "$V" </dev/null >/dev/null 2>&1
  elif [ -z "$played" ] && command -v mpv >/dev/null; then
    timeout 90 mpv --really-quiet --fs --vo=drm --no-input-default-bindings "$V" </dev/null >/dev/null 2>&1
  fi
fi
kd 0
# console colours back to normal (boot.ini hides the console with vt.color=0x00 until here)
TERM=linux setterm --foreground white --background black --store > $T 2>/dev/null < $T
printf '[2J[H[?25h' > $T 2>/dev/null
exit 0
EOF
sudo chmod 755 /usr/local/bin/bootvideo.sh

# the service: after the logo / firstboot, before EmulationStation
sudo tee /etc/systemd/system/bootvideo.service >/dev/null <<EOF
[Unit]
Description=Boot video (boot.mp4)
After=firstboot.service logo.service welcome-message.service
Before=$ES_UNIT

[Service]
Type=oneshot
ExecStart=/usr/local/bin/bootvideo.sh
TimeoutStartSec=100
StandardInput=null
StandardOutput=null

[Install]
WantedBy=multi-user.target
EOF

# no "Welcome to ..." terminal screen when there is a video (lcdyk clones)
if systemctl cat welcome-message.service >/dev/null 2>&1; then
  sudo mkdir -p /etc/systemd/system/welcome-message.service.d
  sudo tee /etc/systemd/system/welcome-message.service.d/bootvideo.conf >/dev/null <<'EOF'
[Unit]
ConditionPathExists=!/boot/boot.mp4
ConditionPathExists=!/flash/boot.mp4
EOF
fi

# hide the console text from the very start of the boot (boot.ini devices); backup kept, result checked
INI="$BOOT/boot.ini"
if [ -f "$INI" ] && grep -q '^setenv bootargs ".* quiet ' "$INI"; then
  if ! grep -q 'vt\.color=' "$INI"; then
    [ -f "$INI.bak-bootvideo" ] || sudo cp -p "$INI" "$INI.bak-bootvideo"
    sudo sed -i '/^setenv bootargs "/ s/ quiet / quiet vt.color=0x00 /' "$INI"
    grep -q 'vt\.global_cursor_default=' "$INI" || sudo sed -i '/^setenv bootargs "/ s/ vt\.color=0x00 / vt.color=0x00 vt.global_cursor_default=0 /' "$INI"
    if ! grep -q '^setenv bootargs ".* vt\.color=0x00 .*"' "$INI"; then
      sudo cp -p "$INI.bak-bootvideo" "$INI"
      echo "boot.ini could not be edited safely, left as it was (the terminals stay visible)."
    fi
  elif ! grep -q 'vt\.global_cursor_default=' "$INI"; then  # boot.ini edited by the first version of this script
    sudo sed -i '/^setenv bootargs "/ s/ vt\.color=0x00 / vt.color=0x00 vt.global_cursor_default=0 /' "$INI"
  fi
else
  echo "No boot.ini with a bootargs line here: the boot terminals cannot be hidden on this device."
fi

sudo systemctl daemon-reload
sudo systemctl enable bootvideo.service >/dev/null 2>&1 || fail "could not enable the service"
sync
[ -f "$BOOT/boot.mp4" ] || echo "Put your video at $BOOT/boot.mp4 (the FAT boot partition)."
done_msg "Boot video enabled."
