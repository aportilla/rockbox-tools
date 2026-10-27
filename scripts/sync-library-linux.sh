#!/bin/bash
# Linux counterpart to sync-itunes-purchases.sh. Here the library is already a
# plain ~/Music/<Artist>/<Album>/ tree, so this writes a Rockbox-friendly
# cover.jpg into each album folder and, given a destination on the SD card,
# copies the library onto it.
#
# Usage: sync-library-linux.sh [/run/media/$USER/<card>/<music folder>]
#
# Safe to rerun: existing covers are kept, only new or changed files are copied,
# and nothing on the card is ever deleted. DRM-protected .m4p files are skipped.
set -u

LIB="${MUSIC_DIR:-$HOME/Music}"
DEST="${1:-}"

if [ -n "$DEST" ] && [ ! -d "$DEST" ]; then
  echo "Destination $DEST is not a directory. Is the card mounted?" >&2
  exit 1
fi

tag() { ffprobe -v quiet -show_entries "format_tags=$1" -of default=nw=1:nk=1 "$2"; }

# Rockbox reads album art from cover.jpg and can't decode PNG or progressive
# JPEG; ffmpeg's JPEG encoder writes baseline, so re-encode through it.
write_cover() {
  ffmpeg -nostdin -loglevel quiet -i "$1" -map 0:v:0 -frames:v 1 -update 1 \
    -vf "scale='min(500,iw)':-1" -q:v 2 "$2"
}

# Look up the album on the iTunes Search API and print a 600px artwork URL.
# Prefers an exact album-name match from the same artist, then any album by them.
itunes_artwork_url() {
  curl -sfG 'https://itunes.apple.com/search' \
      --data-urlencode "term=$1 $2" -d entity=album -d limit=10 |
    jq -r --arg artist "$1" --arg album "$2" '
      [.results[] | select((.artistName | ascii_downcase) == ($artist | ascii_downcase))] as $r
      | ([$r[] | select((.collectionName | ascii_downcase) == ($album | ascii_downcase))] + $r)[0].artworkUrl100
      // empty' |
    sed 's|/100x100bb\.|/600x600bb.|'
}

covers=0
missing=0
art=$(mktemp)
while IFS= read -r -d '' dir; do
  [ -e "$dir/cover.jpg" ] && continue
  track=$(find "$dir" -maxdepth 1 -type f \( -name '*.m4a' -o -name '*.m4b' -o -name '*.mp3' \) -print -quit)
  [ -n "$track" ] || continue

  # Use the artwork embedded in the track when there is one.
  if write_cover "$track" "$dir/cover.jpg"; then
    covers=$((covers + 1))
    continue
  fi
  rm -f "$dir/cover.jpg"

  artist=$(tag album_artist "$track")
  [ -n "$artist" ] || artist=$(tag artist "$track")
  url=$(itunes_artwork_url "$artist" "$(tag album "$track")")
  # The Search API allows roughly 20 requests a minute.
  sleep 3
  if [ -n "$url" ] && curl -sf -o "$art" "$url" && write_cover "$art" "$dir/cover.jpg"; then
    covers=$((covers + 1))
  else
    rm -f "$dir/cover.jpg"
    missing=$((missing + 1))
    echo "No artwork found for ${dir#"$LIB"/}"
  fi
done < <(find "$LIB" -mindepth 2 -type d -print0)
rm -f "$art"

echo "Wrote $covers album covers into $LIB ($missing albums still without one)"

protected=$(find "$LIB" -type f -name '*.m4p' | wc -l)
if [ "$protected" -gt 0 ]; then
  echo "Skipping $protected DRM-protected .m4p files; Rockbox can't play them"
fi

[ -n "$DEST" ] || exit 0

# exFAT has no Unix owners or permissions, so copy only contents and mtimes.
# Linux doesn't leave AppleDouble ._ files, so no dot_clean step is needed.
echo "Copying $LIB to $DEST ..."
rsync -rt --modify-window=1 --exclude='*.m4p' --exclude='.*' --info=stats1 "$LIB/" "$DEST/" || exit 1
sync
echo "Done. Eject the card from the file manager before unplugging it."
