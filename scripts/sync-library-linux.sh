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

# Hand-picked iTunes albums for folders the automatic lookup can't match, one
# "<Artist>/<Album><TAB><collection id>" line each. An id of "-" marks an album
# iTunes doesn't sell, so it isn't looked up again. It's kept with the music,
# not in this public repo, because it lists what's in the library.
IDS="${COVER_IDS:-$LIB/.cover-ids.tsv}"

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

ascii() { iconv -f utf-8 -t ascii//TRANSLIT; }

# The Search API allows roughly 20 requests a minute.
itunes() { sleep 3; curl -sfG "https://itunes.apple.com/$1" "${@:2}"; }

# Turn an API response into "artist<TAB>album<TAB>value" lines with accents
# folded to ASCII. Folding happens after jq because it also turns curly quotes
# into plain ones, which would break the JSON.
rows() { jq -r ".results[] | $1 | @tsv" | ascii; }

# From rows on stdin, print the value of the first row whose artist matches $1
# and whose album matches $2 exactly, or else starts with it (so "Loaded" finds
# "Loaded (Remastered)"). Names are compared lowercased, with "&" as "and",
# edition tags like "(Deluxe Edition)" dropped, and only letters and digits
# kept, so "Whatever & Ever Amen" matches "Whatever and Ever Amen".
pick() {
  jq -Rrs --arg a "$1" --arg al "$2" '
    def norm: ascii_downcase | gsub("&"; "and") | gsub("[^a-z0-9]"; "");
    def base: gsub("\\s*[\\[(][^\\])]*(deluxe|edition|version|remaster|anniversary|expanded|bonus|legacy)[^\\])]*[\\])]"; ""; "i");
    ($a | norm) as $artist | ($al | base | norm) as $want
    | [split("\n")[] | select(. != "") | split("\t") | {artist: .[0], album: .[1], value: .[2]}]
    | [.[] | select((.artist | norm) as $n | $n != "" and ($n == $artist or ($n | contains($artist)) or ($artist | contains($n))))]
    | sort_by((.artist | norm) != $artist) as $r
    | ([$r[] | select((.album | base | norm) == $want)]
       + [$r[] | select((.album | base | norm) | startswith($want))])[0].value // empty'
}

# Print a 600px artwork URL for the album from the iTunes Search API. It goes
# through the artist's album list first, because plain album searches mostly
# return tribute and cover albums. Compilations have no artist page, so those
# fall back to a plain album search.
itunes_artwork_url() {
  local artist album id url=
  artist=$(ascii <<<"$1")
  album=$(ascii <<<"$2")
  id=$(itunes search --data-urlencode "term=$artist" -d entity=musicArtist -d limit=10 |
    rows '[.artistName, "", .artistId]' | pick "$artist" "")
  if [ -n "$id" ]; then
    url=$(itunes lookup -d id="$id" -d entity=album -d limit=200 |
      rows 'select(.wrapperType == "collection") | [.artistName, .collectionName, .artworkUrl100]' |
      pick "$artist" "$album")
  fi
  [ -n "$url" ] || url=$(itunes search --data-urlencode "term=$artist $album" -d entity=album -d limit=25 |
    rows '[.artistName, .collectionName, .artworkUrl100]' | pick "$artist" "$album")
  sed 's|/100x100bb\.|/600x600bb.|' <<<"$url"
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

  rel=${dir#"$LIB"/}
  id=
  [ -f "$IDS" ] && id=$(awk -F'\t' -v d="$rel" '$1 == d { print $2; exit }' "$IDS")
  if [ "$id" = - ]; then
    missing=$((missing + 1))
    continue
  elif [ -n "$id" ]; then
    url=$(itunes lookup -d id="$id" | jq -r '.results[0].artworkUrl100 // empty' |
      sed 's|/100x100bb\.|/600x600bb.|')
  else
    artist=$(tag album_artist "$track")
    [ -n "$artist" ] || artist=$(tag artist "$track")
    # Drop featured artists and disc numbers, which the store doesn't use:
    # "Gorillaz Feat. De La Soul" -> "Gorillaz", "Loaded [Disc 1]" -> "Loaded".
    artist=$(sed -E 's/ +(feat\.?|ft\.?|featuring) .*//I' <<<"$artist")
    album=$(tag album "$track" | sed -E 's/ *[[(](disc|cd) *[0-9]+[])]//I')
    url=$(itunes_artwork_url "$artist" "$album")
  fi
  if [ -n "$url" ] && curl -sf -o "$art" "$url" && write_cover "$art" "$dir/cover.jpg"; then
    covers=$((covers + 1))
  else
    rm -f "$dir/cover.jpg"
    missing=$((missing + 1))
    echo "No artwork found for $rel"
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
