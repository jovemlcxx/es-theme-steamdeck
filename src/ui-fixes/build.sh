#!/bin/bash
# Builds the arkos4clone EmulationStation (lcdyk0517 fork, branch dev) with xmb-sounds.patch
# inside a Debian 10 arm64 container (old glibc -> binary runs on ArkOS and dArkOS).
# Built WITHOUT scraper credentials: ScreenScraper/TheGamesDB are not compiled in.
#
# Run from Windows/Linux with Docker:  bash es-fcamod-sounds/build.sh
# Output: es-fcamod-sounds/out/emulationstation
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
mkdir -p "$HERE/out"

MSYS_NO_PATHCONV=1 docker run --rm --platform linux/arm64 \
  -v "$ROOT/EmulationStation-fcamod-lcdyk:/src" -v "$HERE/out:/out" \
  debian:buster bash -ec '
    # buster is archived; security/updates are needed so -dev packages match the image libc6
    printf "%s\n" "deb http://archive.debian.org/debian buster main" \
      "deb http://archive.debian.org/debian buster-updates main" \
      "deb http://archive.debian.org/debian-security buster/updates main" > /etc/apt/sources.list
    apt-get -o Acquire::Check-Valid-Until=false update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential cmake pkg-config ca-certificates \
      libsdl2-dev libsdl2-mixer-dev libfreeimage-dev libfreetype6-dev libcurl4-openssl-dev \
      rapidjson-dev libasound2-dev libvlc-dev libdrm-dev git
    # the renderer still #includes <go2/audio.h> (all go2_* calls are commented out): headers only
    git clone --depth 1 https://github.com/OtherCrashOverride/libgo2.git /tmp/libgo2
    mkdir -p /usr/include/go2 && cp -L /tmp/libgo2/src/*.h /usr/include/go2/
    # <drm/drm_fourcc.h>: Debian ships it as /usr/include/libdrm/drm_fourcc.h
    [ -e /usr/include/drm/drm_fourcc.h ] || { mkdir -p /usr/include/drm && ln -sf /usr/include/libdrm/*.h /usr/include/drm/; }
    dpkg -i --force-all /src/libmali-rk-*.deb || true
    ls /usr/lib/aarch64-linux-gnu/libMali.so >/dev/null 2>&1 || \
      ln -sf "$(ls /usr/lib/aarch64-linux-gnu/libmali*.so* | head -1)" /usr/lib/aarch64-linux-gnu/libMali.so
    rm -rf /build && cp -a /src /build && cd /build
    rm -f CMakeCache.txt && cmake -DCMAKE_BUILD_TYPE=Release .
    make -j"$(nproc)"
    strip emulationstation
    cp emulationstation /out/
  '
ls -la "$HERE/out/emulationstation"
