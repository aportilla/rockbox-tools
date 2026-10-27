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

### On Linux (personal CachyOS machine)

- There's no Music app here. `~/Music` is already a plain
  `<Artist>/<Album>/` tree (plus `Audiobooks/<Author>/<Book>/` with `.m4b`
  files), so that tree is the source.
- `scripts/sync-library-linux.sh [card-music-dir]` writes a baseline 500px
  `cover.jpg` into each album folder, taken from embedded art when the tracks
  have it, otherwise from the iTunes Search API (no key needed, about 20
  requests a minute, so the first run is slow). It finds the artist first and
  then matches the album within that artist's albums: a plain album search
  mostly returns tribute and cover albums. Albums it can't match get a
  hand-picked iTunes collection id in `~/Music/.cover-ids.tsv`
  (`<Artist>/<Album><TAB><id>`, or `-` for albums iTunes doesn't sell). That
  file lives with the music, not in this repo, because it lists what's in the
  library. Another option is to drop a `cover.jpg` into the folder by hand,
  since existing covers are kept. With a destination it then
  `rsync`s the library to the card, skipping `.m4p` and hidden files. It
  never deletes anything on the card. Rerunning it is safe.
- It needs `ffmpeg`, `curl`, `jq` and `rsync`. Cards mount under
  `/run/media/$USER/<label>/`. No `dot_clean` step is needed on Linux.

## Themes

- Taste: minimalist, classic iPod look, 1-bit / retro.
- Catalog and install notes: `themes/README.md`.
- `scripts/fetch-theme-sources.sh` clones git-hosted themes into
  `themes/sources/`. themes.rockbox.org blocks scripted access (bot
  protection), so its zips get downloaded by hand into `themes/incoming/`.
  Both folders are gitignored.
- Adapted or original themes go in `themes/<name>/`, crediting upstream (most
  themes are CC-BY-SA).
