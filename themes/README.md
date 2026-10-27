# Themes

What I'm after: **minimalist**, **classic iPod look and feel**, **1-bit / retro**.

## Fit for the H2

The H2's screen is **320×240 landscape, 16-bit color**, the same as the iPod
Video and iPod Classic. Themes made for the `ipodvideo` and `ipod6g` targets
therefore fit without resizing, and that's where most iPod-style themes live.

- Browse 320×240 themes: <https://themes.rockbox.org/index.php?target=aigoerosq>
  (the theme site files the Eros Q / H2 under `aigoerosq`).
- themes.rockbox.org blocks scripted downloads, so grab zips from it by hand
  into `themes/incoming/`. Git-hosted themes are cloned into `themes/sources/`
  by `scripts/fetch-theme-sources.sh`. Both folders are gitignored.
- Themes built on iPods can assume iPod-only things (wheel hints, button
  labels). Expect small fixes; put adapted versions in `themes/<name>/` with
  upstream credit (most are CC-BY-SA).

## Installing a theme

1. Copy the theme's `.rockbox` folder to the root of the SD card and **merge**
   it with the existing one; don't replace it.
2. On the player: **Settings → Theme Settings → Browse Theme Files**.
3. Many themes need the Rockbox font pack (installable with Rockbox Utility).
   The card already has it.
4. Album art: the library has a `cover.jpg` in every album folder, so set
   **Playback Settings → Album Art → Prefer Image File**.

From Linux, merge a theme into the card without overwriting anything that's
already there:

```sh
rsync -rt --modify-window=1 --ignore-existing --exclude='.*' \
  <theme>/.rockbox/ /run/media/$USER/ROCKBOX/.rockbox/
```

Themes share files (fonts, `icons/modone.bmp`), so compare a theme against the
card first. Anything that differs is a version clash, and `--ignore-existing`
silently keeps the card's copy. Watch for two traps when checking a theme's
files: some configs have Windows (CRLF) line endings, and some font names
contain spaces (`24 iLike.fnt`).

## On the card

Theme setup as of 2026-10-27. The player is set to `adwaitapod_dark_simplified`.

- **Classic iPod:** iVideo, iVideoDark, PodOne, and all four Adwaitapod variants
  (the card's `adwaitapod_dark_simplified.cfg` predates the clone and has the
  scroll settings commented out, so it was kept).
- **1-bit / retro:** OneBitMono (the 2025 fork, see below), OneBit_VFD,
  OneBit_VFD2, ONE_BIT_TO_VFD, OneBit_OLED, CrazyBit Mono, Bayer,
  FleshAndBones, BONES.
- **Installed before this repo:** cabbiev2, Exit, iRetro, jBox_white, Less,
  minimal_retro, MinimalX, Pixel_Computer, redux, retroTapeFixed.

**OneBitMono: the 2025 fork replaced the original.** The site download saved
as a generic `rockbox.zip` (the OneBit themes all download under that name;
read `.rockbox/themes/*.cfg` inside to tell them apart). The original by
chronicallyoffline (2024–25) has three bugs that Cicumpunct's fork (dated
2025-05-24) fixes:

- The battery gauge lines are missing their leading `%`, and the
  thresholds never show fewer than 9 bars.
- The track counter shows the file's track number "of" the playlist
  length; the fork shows the playlist position.
- The charging label is inverted.

The fork also adds a disk-activity indicator and a "LOCKED" label. It drops
the original's white lock-screen background and the inverted elapsed time.

## Shortlist (try these first)

| Theme | Why |
|---|---|
| **PodOne** | iPod *and* 1-bit: a recreation of the 2001 first-gen iPod's grey monochrome LCD |
| **iVideo** | The best-known recreation of the stock iPod Video software |
| **CrazyBit Mono** | Pure black and white with pixel fonts; confirmed 320×240 |
| **Bayer** | Two-tone with ordered-dither patterns and a pixel font; very retro |

## Catalog

Status: **cloned** = in `themes/sources/`; **site** = download by hand;
**seen** = confirmed 320×240 from the theme's files or screenshots;
**installed** = on the card (see above).
Descriptions of site-only themes come from search listings and haven't been
checked yet.

### Classic iPod look

| Theme | Source | Notes | Status |
|---|---|---|---|
| iVideo | [themes #1309](https://themes.rockbox.org/index.php?themeid=1309) | Humberto Santana. Based on the iLike mockup; menus behave like the original iPod firmware. ~77k downloads. | site, installed |
| iVideoDark | [themes #3137](https://themes.rockbox.org/index.php?themeid=3137) | Dark variant of iVideo. | site, installed |
| miXtheme | [themes #1819](https://themes.rockbox.org/index.php?themeid=1819) | Dark theme modified from iVideo. | site |
| PodOne | [themes #2156](https://themes.rockbox.org/index.php?themeid=2156) | Mimics the 2001 iPod's grey LCD. Needs specific fonts; Rockbox 3.14+. Trades away some features for looks. | site, installed |
| PodTwo | [themes #2173](https://themes.rockbox.org/index.php?themeid=2173) | PodOne with some changes. | site |
| Adwaitapod | [GitHub D0-0K/adwaitapod](https://github.com/D0-0K/adwaitapod) | Modern iPod UI in GNOME style (Cantarell font, Adwaita icons). Light and dark; the *simplified* variants are the minimal ones. Also has CJK and large-font packs. CC-BY-SA. | cloned, installed |
| Themify 2 | [itch.io](https://d00k.itch.io/themify2-and-manual) · [site](https://themify.dook.net) | Same author as Adwaitapod. Colorful, with colors that adapt to the album art; more modern than retro. Comes to themes.rockbox.org later than itch. | — |

### 1-bit / monochrome / retro

| Theme | Source | Notes | Status |
|---|---|---|---|
| OneBit Monochrome | [themes #3633](https://themes.rockbox.org/index.php?themeid=3633) | Ben Clayton. The original theme the whole OneBit family is based on. | site, replaced by fork |
| OneBit_Mono | [themes #3824](https://themes.rockbox.org/index.php?themeid=3824) | Nathaniel Nader's fork; works on Rockbox 4.0. ~10k downloads. | site |
| CrazyBit Mono | [Codeberg ottoptj/CrazyBitMono](https://codeberg.org/ottoptj/CrazyBitMono) · [themes #3951](https://themes.rockbox.org/index.php?themeid=3951) | Fork of OneBit_Mono. Pure white on black, inverse-bar selector, LanaPixel and digital-7 fonts, and a combined font that shows Asian titles. No clock. CC-BY-SA. | cloned, seen, installed |
| OneBit VFD family | [TO_VFD #3810](https://themes.rockbox.org/index.php?themeid=3810) · [OP_VFD #3806](https://themes.rockbox.org/index.php?themeid=3806) · [Hal-9000 #3801](https://themes.rockbox.org/index.php?themeid=3801) · [GEIGER #3838](https://themes.rockbox.org/index.php?themeid=3838) | Look like old vacuum-fluorescent displays, in various colors. TO_VFD is listed for the Eros Q target. | site, TO_VFD installed |
| OneBit_OLED | [themes #3901](https://themes.rockbox.org/index.php?themeid=3901) | Configurable minimal theme based on OneBit_VFD. | installed |
| Bayer | [GitHub gloceandotdev/bayer-rockbox-theme](https://github.com/gloceandotdev/bayer-rockbox-theme) | Two-tone with Bayer-dither patterns and the DotGothic16 pixel font. Includes a lock screen. Brand new (2026). MIT. | cloned, seen, installed |
| FleshAndBones | [GitHub nicnic-cc/fleshandbones](https://github.com/nicnic-cc/fleshandbones) · [themes #4030](https://themes.rockbox.org/index.php?themeid=4030) | Minimal dark theme (OneBit_OLED + BONES) with ProFont and monogram pixel fonts. Its `extras/cover.sh` dithers album art to suit the theme (assumes FLAC; would need adapting for `.m4a`). | cloned, seen, installed |
| BONES | [themes #3579](https://themes.rockbox.org/index.php?themeid=3579) | Minimal, text-only, showcases Pro Font. | installed |
| MinimalY | [themes #2631](https://themes.rockbox.org/index.php?themeid=2631) | Very stripped down: no album art, icons off, only shuffle/repeat/low-battery indicators. | site |

### Worth a look

| Theme | Source | Notes |
|---|---|---|
| Walkman Sports | [themes #3909](https://themes.rockbox.org/index.php?themeid=3909) | "Nostalgic but clean." Very popular. |
| podamp | [GitHub nilsding/rockbox-theme-podamp](https://github.com/nilsding/rockbox-theme-podamp) | Winamp-style now-playing screen, but made for the iPod mini (176×132), so it would need porting. |
| XPloRR | [vanbarel.eu.org](https://vanbarel.eu.org/tools/rockbox/index.html) | Modern restyle for the iPod Classic/Video. Needs two extra fonts. |
| Rockpod | [GitHub nuxcodes/rockpod](https://github.com/nuxcodes/rockpod) | Not a theme: a Rockbox fork for iPods with Apple-style Cover Flow, plus fixed versions of Adwaitapod and Themify 2. Only useful for ideas. |
