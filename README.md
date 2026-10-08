# es-theme-steamdeck

**EN** · [BR](README.pt-BR.md)

Steam Deck–style theme for **EmulationStation-fcamod** on the **R36S** and clones (ArkOS family, 640×480), with two optional add-ons: a **boot video** and **UI fixes** (opaque carousel, extra sounds).

<p align="center">
  <img src="images/carousel-snes.jpg" width="49%"> <img src="images/carousel-ports.jpg" width="49%"><br>
  <img src="images/gamelist-zelda.jpg" width="49%"> <img src="images/gamelist-castlevania.jpg" width="49%">
</p>

[Install](#install) · [Theme](#the-theme) · [Boot video](#boot-video) · [UI Fixes](#steam-deck-ui-fixes) · [Compatibility](#compatibility) · [Customize](#customize)

## Install

The folders mirror the SD card: copy each one over its partition.

```
BOOT/        boot partition   boot.mp4 (your video), logo.bmp
EASYROMS/    games partition  themes/es-theme-steamdeck, tools/*.sh
src/         source of the UI Fixes installer
images/      screenshots used in this README
```

1. Copy `EASYROMS/themes/es-theme-steamdeck` to `/roms/themes/` (or `/easyroms/themes/`).
2. **START → UI Settings → Theme Set → es-theme-steamdeck**. Dark/light is in the same menu.
3. Optional add-ons: copy the scripts of `EASYROMS/tools` to the tools folder and run them from **Options → Tools**.

## The theme

- One **same-size vertical capsule** per system (192×288, 2:3, as in the Steam library): an in-game screenshot of the platform's best-known game, the system's own logo and a thin outline. 310 systems plus the 3 collections have one. The 21 with no screenshot anywhere (obscure computers and homebrew) get Steam's grey card with the logo.
- The selected capsule is the page background, blurred and fading to the page color. Game list laid out like the Deck's game page: image on top, PLAY, last session, times played, list and description.
- Dark and light schemes. For now the theme is focused on the **R36S, 4:3 (640×480)**; other screen aspect ratios are planned and coming soon.
- **27 languages** (same as the XMB theme): footer, tabs, labels, dates and the PortMaster banner.
- Steam Deck UI sounds. Navigation plays on any ES; select/back/launch/favorite need the UI Fixes.

<p align="center">
  <img src="images/carousel-mame.jpg" width="32%"> <img src="images/carousel-capcom.jpg" width="32%"> <img src="images/gamelist-gundam-w.jpg" width="32%">
</p>

## Boot video

`Enable Boot Video.sh` plays `boot.mp4` (from `/boot`, or `/flash`) after the boot logo and before EmulationStation, and hides the boot terminals and the text cursor. `Disable Boot Video.sh` undoes it.

| System | Method |
|---|---|
| ArkOS, arkos4clone, dArkOSen, dArkOSRE-R36 | systemd service `bootvideo.service`; `boot.ini` gets `vt.color=0x00 vt.global_cursor_default=0` (backup `boot.ini.bak-bootvideo`); the "Welcome to…" screen of the lcdyk clones is skipped while the video exists. `ffmpeg` decodes straight to `/dev/fb0` (no window, no mouse cursor), `ffplay`/`mpv` as fallback |

The script also contains code for other systems, but only the ones in the compatibility table below are confirmed. Tip: 640×480, H.264, a few seconds.

## Steam Deck UI Fixes

The ES of this family draws unselected carousel items at a fixed 50% opacity and ignores most theme sounds. `Enable Steam Deck UI Fixes.sh` installs a patched ES that adds `unselectedOpacity` to `<carousel>` (the theme uses `1`), plays the `select`, `back`, `favorite` and `quicksysselect` sounds, and shows a small logo on the loading screen. `Disable Steam Deck UI Fixes.sh` restores the original (kept as `emulationstation.orig-xmbsounds`).

⚠️ Test build: **no built-in scraper** (those credentials only exist in the official build), and an arkos4clone update replaces ES again (just run it again). It checks architecture and libraries first and changes nothing on a mismatch. Without it the theme works the same, with covers at 50% and only the navigation sound.

<details><summary>Build from source</summary>

Source: `src/ui-fixes` (patches for [lcdyk0517/EmulationStation-fcamod](https://github.com/lcdyk0517/EmulationStation-fcamod), branch `dev`). Needs Docker.

```bash
git clone --recursive --depth 1 -b dev https://github.com/lcdyk0517/EmulationStation-fcamod.git EmulationStation-fcamod-lcdyk
git -C EmulationStation-fcamod-lcdyk apply ../src/ui-fixes/xmb-sounds.patch ../src/ui-fixes/carousel-opacity.patch
bash src/ui-fixes/build.sh   # Debian 10 arm64 container (old glibc), ~10-15 min
bash src/ui-fixes/pack.sh    # binary + install-template.sh -> Enable Steam Deck UI Fixes.sh
```
Adjust the paths in the scripts if you move the folders.
</details>

## Compatibility

| | Theme | Boot video | UI Fixes |
|---|---|---|---|
| ArkOS | ✅ | ✅ | ✅ |
| arkos4clone | ✅ | ✅ | ✅ |
| dArkOSen | ✅ | ✅ | ✅ |
| dArkOSRE-R36 | ✅ | ✅ | ✅ |
| dArkOS | ✅ | ❌ does not work | ✅ |
| muOS | ❌ does not work | – | – |
| ArchR, Batocera, Knulli, EmuELEC | not tested yet | not tested yet | not tested yet |

Other limits: only 640×480 (4:3) for now, other aspect ratios are coming soon; tabs, STEAM pill and banner are decorative; a few screenshots are weak (Lynx, Kodi); the light scheme is less tested than the dark one.

## Customize

Files are named after the system's `<theme>` entry in `es_systems.cfg` (e.g. `snes`, `megadrive`), not the ROM folder. All paths are inside `_inc/`.

| What | Where | Size |
|---|---|---|
| Capsule | `systems/capsule/<theme>.png` | 192×288 (2:3, larger is fine) |
| Game-list background (dark / light) | `systems/gl/` · `gl-light/` | 640×480 |
| Part under the game image | `systems/glinfo/` · `glinfo-light/` | 640×284 |
| Banner (all systems, per language) | `images/banner-portmaster[-<lang>].png` | 1202×274 |
| Banner (one system) | `systems/banner/<theme>.png` | 1202×274 |
| Avatar | `images/avatar.png` | 96×96 |
| Colors | `colors/dark.xml`, `light.xml` | |
| Translations | `lang/<code>.xml` | |

To replace a grey capsule, drop your own PNG with the system's name in `systems/capsule/`. Layout is in `aspect-ratio-4-3.xml`; English texts are the `variables` at the top of `theme.xml` (fcamod stops reading `variables` blocks at the first one of another language, so each translation is its own file).

## Credits and license

**Testing:** huge thanks to [Sabrina Broch](https://www.youtube.com/@sabrinabroch1/videos), a beloved YouTuber of the Brazilian R36S community, who generously tested the theme, the boot video and the UI Fixes on the systems marked ✅ above. This project would not be confirmed on so many systems without her help. Go check out her channel!

**License:** [CC BY-NC 4.0](LICENSE)
