#!/bin/bash
# Clone, or update, the git-hosted themes from themes/README.md into
# themes/sources/ (gitignored). Theme files are only read and copied to the
# player; nothing in these repos is meant to be run.
set -u

SOURCES="$(cd "$(dirname "$0")/.." && pwd)/themes/sources"

REPOS=(
  "adwaitapod https://github.com/D0-0K/adwaitapod"
  "bayer https://github.com/gloceandotdev/bayer-rockbox-theme"
  "crazybit-mono https://codeberg.org/ottoptj/CrazyBitMono"
  "fleshandbones https://github.com/nicnic-cc/fleshandbones"
)

for entry in "${REPOS[@]}"; do
  name=${entry%% *}
  url=${entry#* }
  if [ -d "$SOURCES/$name/.git" ]; then
    git -C "$SOURCES/$name" pull --ff-only --depth 1 --quiet && echo "updated $name"
  else
    git clone --depth 1 --quiet "$url" "$SOURCES/$name" && echo "cloned  $name"
  fi
done
