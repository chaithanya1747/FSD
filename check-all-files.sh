#!/bin/bash

BASE="$HOME/Desktop/fsdgit"
TEMP="$(mktemp -d)"
trap 'rm -rf "$TEMP"' EXIT

PASS=0
FAIL=0

for DIR in "$BASE"/*/; do
    [ -d "$DIR/.git" ] || continue

    NAME="$(basename "$DIR")"
    echo ""
    echo "===== Checking: $NAME ====="

    URL=$(git -C "$DIR" remote get-url origin)
    REPO="${URL%.git}"
    TARGET="$TEMP/$NAME"
    mkdir -p "$TARGET"

    if ! git clone --quiet "$REPO" "$TARGET"; then
        echo "❌ Could not download repository"
        FAIL=$((FAIL+1))
        continue
    fi

    (
      cd "$DIR" || exit
      find . -type f ! -path './.git/*' -exec shasum -a 256 {} \; |
      sed 's#  \./#  #' | sort
    ) > "$TEMP/local.txt"

    (
      cd "$TARGET" || exit
      find . -type f ! -path './.git/*' -exec shasum -a 256 {} \; |
      sed 's#  \./#  #' | sort
    ) > "$TEMP/remote.txt"

    if diff -u "$TEMP/local.txt" "$TEMP/remote.txt"; then
        echo "✅ EXACT FILE MATCH"
        PASS=$((PASS+1))
    else
        echo "❌ DIFFERENCES FOUND"
        FAIL=$((FAIL+1))
    fi
done

echo ""
echo "===== FINAL RESULT ====="
echo "Exact matches: $PASS"
echo "Differences: $FAIL"
echo "Total checked: $((PASS+FAIL))"
