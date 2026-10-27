# rockbox-tools

Notes, configs, themes and scripts for managing my music library on a HiFi
Walker H2 running Rockbox. This repo is not media storage; the music lives in
`~/Music`. The repo is public on GitHub, so don't commit third-party theme
files or anything personal.

## The player

- HiFi Walker H2 = a rebadged AIGO Eros Q. Rockbox target `erosqnative`; the
  theme site files it under `aigoerosq`.
- Screen: 320×240 landscape, 16-bit color, the same as the iPod Video/Classic,
  so `ipodvideo`/`ipod6g` themes fit.
- The SD card is about 250 GB, formatted exFAT, and already has music on it,
  so exFAT works. (Older Rockbox install notes say this port needs FAT32.)
- Rockbox version on the device: not yet checked. It's in
  `/.rockbox/rockbox-info.txt` on the card.
- My work laptop blocks USB storage, so anything that touches the card has to
  happen on my personal computer.

## Library pipeline

- Source of truth is the Music app. Purchased iTunes music downloads as
  DRM-free 256 kbps AAC into `~/Music/Music/Media.localized/Music/`. Apple
  Music downloads (`.m4p`, DRM) go into `.../Apple Music/` and can't play in
  Rockbox.
- `scripts/sync-itunes-purchases.sh` mirrors the `.m4a` files into
  `~/Music/iTunes Purchases/<Artist>/<Album>/` as APFS clones and writes a
  baseline 500px `cover.jpg` per album. Purchases don't embed artwork, so the
  script gets it from the Music app with AppleScript. Rockbox can't decode PNG
  or progressive JPEG. Rerunning it is safe: only new tracks get copied.
  It needs Homebrew `ffmpeg` (for `ffprobe` too), and it only sees purchases
  already downloaded on the Mac it runs on.
- Rockbox plays AAC natively; don't transcode.
- After copying to the card, run `dot_clean -m /Volumes/<card>` to remove the
  AppleDouble `._` files that macOS leaves.

## Themes

- Taste: minimalist, classic iPod look, 1-bit / retro.
- Catalog and install notes: `themes/README.md`.
- `scripts/fetch-theme-sources.sh` clones git-hosted themes into
  `themes/sources/`. themes.rockbox.org blocks scripted access (bot
  protection), so its zips get downloaded by hand into `themes/incoming/`.
  Both folders are gitignored.
- Adapted or original themes go in `themes/<name>/`, crediting upstream (most
  themes are CC-BY-SA).
