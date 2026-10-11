#!/bin/bash
# Builds ONE system's EmulationStation with the two patches (carousel opacity + theme sounds) applied,
# from THAT system's own ES source, in a Debian 10 arm64 container (old glibc -> runs on these devices).
#   bash build.sh <src_dir> <system>
#     <src_dir>  ES source tree under FCAMOD (with libmali-rk-*.deb and external/ submodules populated)
#     <system>   output name -> es-fcamod-sounds/systems/<system>/emulationstation
# e.g.  bash build.sh EmulationStation-fcamod-lcdyk arkos4clone
#       bash build.sh EmulationStation-fcamod-chmod darkos        (christianhaitian 503noTTS: dArkOS/dArkOSRE)
# Scraper credentials come from scraper.env (next to this script, never published).
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
SRC="${1:?usage: build.sh <src_dir> <system>}"
SYS="${2:?usage: build.sh <src_dir> <system>}"
[ -d "$ROOT/$SRC" ] || { echo "source $ROOT/$SRC not found"; exit 1; }
OUTD="$HERE/systems/$SYS"; mkdir -p "$OUTD"
SS_LOGIN=; SS_SOFT=; GDB_KEY=
[ -f "$HERE/scraper.env" ] && . "$HERE/scraper.env"
[ -n "$SS_LOGIN" ] && echo "ScreenScraper credentials found: scraper compiled in" || echo "No scraper.env: building WITHOUT scraper"

MSYS_NO_PATHCONV=1 docker run --rm --platform linux/arm64 \
  -v "$ROOT/$SRC:/src:ro" -v "$HERE:/es" -v "$OUTD:/out" \
  -e SS_LOGIN="$SS_LOGIN" -e SS_SOFT="$SS_SOFT" -e GDB_KEY="$GDB_KEY" \
  debian:buster bash -ec '
    printf "%s\n" "deb http://archive.debian.org/debian buster main" \
      "deb http://archive.debian.org/debian buster-updates main" \
      "deb http://archive.debian.org/debian-security buster/updates main" > /etc/apt/sources.list
    apt-get -o Acquire::Check-Valid-Until=false update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      build-essential cmake pkg-config ca-certificates patch \
      libsdl2-dev libsdl2-mixer-dev libfreeimage-dev libfreetype6-dev libcurl4-openssl-dev \
      rapidjson-dev libasound2-dev libvlc-dev libdrm-dev git
    git clone --depth 1 https://github.com/OtherCrashOverride/libgo2.git /tmp/libgo2
    mkdir -p /usr/include/go2 && cp -L /tmp/libgo2/src/*.h /usr/include/go2/
    [ -e /usr/include/drm/drm_fourcc.h ] || { mkdir -p /usr/include/drm && ln -sf /usr/include/libdrm/*.h /usr/include/drm/; }
    dpkg -i --force-all /src/libmali-rk-*.deb || true
    ls /usr/lib/aarch64-linux-gnu/libMali.so >/dev/null 2>&1 || \
      ln -sf "$(ls /usr/lib/aarch64-linux-gnu/libmali*.so* | head -1)" /usr/lib/aarch64-linux-gnu/libMali.so
    rm -rf /build && cp -a /src /build && rm -rf /build/.git && cd /build
    # the two features, applied to THIS system own source. The trees can be CRLF (Windows checkout) while
    # the patches are LF, so normalise the four target files first, else patch refuses ("different line endings").
    for f in es-app/src/views/SystemView.cpp es-app/src/views/SystemView.h es-core/src/ThemeData.cpp es-app/src/views/gamelist/ISimpleGameListView.cpp; do
      [ -f "$f" ] && sed -i "s/\r$//" "$f"; done
    # a source tree that already carries a patch (applied by hand earlier) is left as is, never prompted
    for p in carousel-opacity xmb-sounds; do
      if patch -p1 -R --dry-run -s -f < /es/$p.patch >/dev/null 2>&1; then echo "patch $p: already in the source, skipped"
      else patch -p1 -f < /es/$p.patch; fi
    done
    OPTS=; [ -n "$SS_LOGIN" ] && OPTS="$OPTS -DSCREENSCRAPER_DEV_LOGIN=$SS_LOGIN"
    [ -n "$SS_SOFT" ] && OPTS="$OPTS -DSCREENSCRAPER_SOFTNAME=$SS_SOFT"; [ -n "$GDB_KEY" ] && OPTS="$OPTS -DGAMESDB_APIKEY=$GDB_KEY"
    rm -f CMakeCache.txt && cmake -DCMAKE_BUILD_TYPE=Release $OPTS .
    make -j"$(nproc)"
    strip emulationstation
    cp emulationstation /out/
  '
ls -la "$OUTD/emulationstation"
