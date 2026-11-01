#!/bin/sh
# Symlink every file in this repo into $HOME.
# Existing real files are kept as *.bak (or *.bak.1, *.bak.2, ... if taken).
set -eu
cd "$(dirname "$0")"
src=$(pwd -P)

# A symlink inside the repo means it is broken (e.g. a file linked to itself).
# Refuse to run rather than make it worse.
broken=$(find . -type l ! -path './.git/*')
if [ -n "$broken" ]; then
    echo "error: symlinks found inside the repo (should be regular files):" >&2
    echo "$broken" >&2
    echo "restore them first, e.g. with: git checkout -- <file>" >&2
    exit 1
fi

# Move $1 to the first free $1.bak, $1.bak.1, $1.bak.2, ...
backup() {
    b=$1.bak
    n=1
    while [ -e "$b" ] || [ -L "$b" ]; do
        b=$1.bak.$n
        n=$((n + 1))
    done
    mv "$1" "$b"
    echo "backup: $b"
}

skipped='|'
find . -type f ! -path './.git/*' ! -name install.sh | while IFS= read -r f; do
    f=${f#./}
    dst=$HOME/$f
    dir=$(dirname "$dst")
    mkdir -p "$dir"

    # If the destination directory is (via a symlink) the repo directory itself,
    # linking would replace the repo file with a symlink to itself. Skip it.
    if [ "$(realpath "$dir")" = "$(realpath "$src/$(dirname "$f")")" ]; then
        case $skipped in
            *"|$dir|"*) ;;
            *)
                echo "skip: $dir is a symlink into the repo; replace it with a real directory and re-run" >&2
                skipped="$skipped$dir|"
                ;;
        esac
        continue
    fi

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        backup "$dst"
    fi
    ln -sfn "$src/$f" "$dst"
done
