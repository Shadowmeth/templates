#!/usr/bin/env bash
#
# Merge every compile_commands.json found under the project into one
# compile_commands.json at the project root, then delete the originals.
#
# Usage: ./merge_compile_commands.sh [project_root]
#        (defaults to the current directory)

set -euo pipefail

ROOT="$(realpath "${1:-.}")"
OUT="$ROOT/compile_commands.json"

if ! command -v jq >/dev/null 2>&1; then
    echo "error: jq is not installed (sudo apt install jq)" >&2
    exit 1
fi

# Find all compile_commands.json files, except the one at the root
# and anything inside clangd's cache.
mapfile -d '' FILES < <(
    find "$ROOT" \
        -path "$ROOT/.cache" -prune -o \
        -name compile_commands.json \
        ! -path "$OUT" \
        -print0
)

if [ "${#FILES[@]}" -eq 0 ]; then
    echo "No compile_commands.json files found under $ROOT - nothing to do."
    exit 0
fi

echo "Merging:"
printf '  %s\n' "${FILES[@]}"

# Merge into a temporary file first, so a bad input never leaves
# a half-written result or deletes the originals.
TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

jq -s 'add | unique' "${FILES[@]}" > "$TMP"

mv "$TMP" "$OUT"
trap - EXIT

echo "Wrote $(jq length "$OUT") entries to $OUT"

# Merge succeeded, now delete the originals.
for f in "${FILES[@]}"; do
    rm -- "$f"
    echo "Deleted $f"
done
