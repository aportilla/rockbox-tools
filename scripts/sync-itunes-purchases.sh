#!/bin/bash
# Mirror DRM-free iTunes purchases (.m4a) from the Music app's media folder into
# ~/Music/iTunes Purchases/<Artist>/<Album>/ for a Rockbox player.
# Safe to rerun: only new tracks are copied. Apple Music downloads (.m4p) live in
# a separate folder and are never touched.
set -u

SRC="$HOME/Music/Music/Media.localized/Music"
DEST="$HOME/Music/iTunes Purchases"

mkdir -p "$DEST"

copied=0
while IFS= read -r -d '' src; do
  dst="$DEST/${src#"$SRC"/}"
  [ -e "$dst" ] && continue
  mkdir -p "$(dirname "$dst")"
  # -c clones the file on APFS, so the copy takes no extra disk space.
  cp -c "$src" "$dst" && copied=$((copied + 1))
done < <(find "$SRC" -type f -name '*.m4a' -print0)

tag() { ffprobe -v quiet -show_entries "format_tags=$1" -of default=nw=1:nk=1 "$2"; }

# Purchased downloads don't embed their artwork, so ask the Music app for the
# artwork of the track matching these tags and write its raw bytes to a file.
fetch_artwork() {
  osascript - "$@" <<'EOF'
on run {trackName, albumName, artistName, outPath}
  tell application "Music"
    set t to first track of library playlist 1 whose name is trackName and album is albumName and artist is artistName
    set artData to raw data of artwork 1 of t
  end tell
  set f to open for access (POSIX file outPath) with write permission
  set eof f to 0
  write artData to f
  close access f
end run
EOF
}

# Rockbox reads album art from cover.jpg and can't decode PNG or progressive
# JPEG, so re-encode the Music app's artwork as a baseline JPEG.
covers=0
art=$(mktemp)
while IFS= read -r -d '' dir; do
  [ -e "$dir/cover.jpg" ] && continue
  track=$(find "$dir" -maxdepth 1 -name '*.m4a' -print -quit)
  [ -n "$track" ] || continue
  if fetch_artwork "$(tag title "$track")" "$(tag album "$track")" "$(tag artist "$track")" "$art" >/dev/null &&
      ffmpeg -nostdin -loglevel quiet -i "$art" -frames:v 1 -update 1 \
        -vf "scale='min(500,iw)':-1" -q:v 2 "$dir/cover.jpg"; then
    covers=$((covers + 1))
  else
    rm -f "$dir/cover.jpg"
    echo "No artwork found for ${dir#"$DEST"/}"
  fi
done < <(find "$DEST" -mindepth 2 -maxdepth 2 -type d -print0)
rm -f "$art"

echo "Copied $copied new tracks and wrote $covers album covers into $DEST"

protected=$(find "$SRC" -type f -name '*.m4p' | wc -l | tr -d ' ')
if [ "$protected" -gt 0 ]; then
  echo "Skipped $protected DRM-protected .m4p files in $SRC"
fi
