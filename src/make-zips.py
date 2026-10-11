#!/usr/bin/env python3
"""Builds one SD-card zip per system at the repo root: es-theme-steamdeck-<system>.zip, holding BOOT/ and EASYROMS/
(the theme + that system's scripts in EASYROMS/tools). Run it again after changing the theme or any script:
    python src/make-zips.py"""
import os, zipfile

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SYSTEMS = ["ArkOS", "arkos4clone", "dArkOS", "dArkOS4Clone", "dArkOSRE-R36", "dArkOSen"]
# the boot video does not work on dArkOS (README compatibility table): its zip gets no boot.mp4 / boot video scripts
BOOT_VIDEO = {"ArkOS", "arkos4clone", "dArkOS4Clone", "dArkOSRE-R36", "dArkOSen"}


def add(z, path, arc):
    zi = zipfile.ZipInfo.from_file(path, arc)
    zi.compress_type = zipfile.ZIP_DEFLATED
    if arc.endswith(".sh"):
        zi.external_attr = 0o100755 << 16  # executable when extracted on Linux
    with open(path, "rb") as f:
        z.writestr(zi, f.read(), compresslevel=9)


def add_tree(z, src, arc):
    for dp, dn, fn in os.walk(src):
        dn.sort()
        for f in sorted(fn):
            p = os.path.join(dp, f)
            add(z, p, arc + "/" + os.path.relpath(p, src).replace(os.sep, "/"))


for s in SYSTEMS:
    out = os.path.join(ROOT, f"es-theme-steamdeck-{s}.zip")
    with zipfile.ZipFile(out, "w") as z:
        add(z, os.path.join(ROOT, "BOOT", "logo.bmp"), "BOOT/logo.bmp")
        if s in BOOT_VIDEO:
            add(z, os.path.join(ROOT, "BOOT", "boot.mp4"), "BOOT/boot.mp4")
            for f in ("Enable Boot Video.sh", "Disable Boot Video.sh"):
                add(z, os.path.join(ROOT, "EASYROMS", "tools", f), "EASYROMS/tools/" + f)
        add_tree(z, os.path.join(ROOT, "EASYROMS", "themes"), "EASYROMS/themes")
        add_tree(z, os.path.join(ROOT, "UI Fixes", s, "EASYROMS", "tools"), "EASYROMS/tools")
    print(f"{os.path.basename(out):42} {os.path.getsize(out) / 1048576:5.1f} MB")
