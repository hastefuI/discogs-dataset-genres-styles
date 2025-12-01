#!/usr/bin/env bash
# Extracts a list of genres and styles from a given Discogs Data Dump Release
# Requirements: pigz, jq, grep, sed, awk, sort

set -euo pipefail

MIN_LENGTH=2

if [[ $# -ge 1 ]]; then
  FILENAME="$1"
fi

: "${FILENAME:?FILENAME must be provided}"

mkdir -p dist

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Extracting genres and styles from ${FILENAME} (this may take a moment) ..."

pigz -dc "${FILENAME}" | tee \
  >(grep -o '<genre>[^<]*</genre>' \
      | sed -E 's#^<genre>([^<]+)</genre>$#\1#; s/&amp;/\&/g' \
      | awk -v min_len="${MIN_LENGTH}" 'length($0) >= min_len' \
      > "${TMP_DIR}/genres.raw") \
  >(grep -o '<style>[^<]*</style>' \
      | sed -E 's#^<style>([^<]+)</style>$#\1#; s/&amp;/\&/g' \
      | awk -v min_len="${MIN_LENGTH}" 'length($0) >= min_len' \
      > "${TMP_DIR}/styles.raw") \
  > /dev/null

echo "Post-processing ..."

GENRES_SORTED="${TMP_DIR}/genres.sorted"
STYLES_SORTED="${TMP_DIR}/styles.sorted"

LC_ALL=C sort -u "${TMP_DIR}/genres.raw" > "${GENRES_SORTED}"
LC_ALL=C sort -u "${TMP_DIR}/styles.raw" > "${STYLES_SORTED}"

echo "Exporting JSON ..."
jq -R -s 'split("\n") | map(select(length > 0))' < "${GENRES_SORTED}" > dist/genres.json
jq -R -s 'split("\n") | map(select(length > 0))' < "${STYLES_SORTED}" > dist/styles.json

echo "Exporting CSV ..."
{
  echo "genre"
  while IFS= read -r line; do
    esc=${line//\"/\"\"}
    printf "\"%s\"\n" "$esc"
  done < "${GENRES_SORTED}"
} > dist/genres.csv

{
  echo "style"
  while IFS= read -r line; do
    esc=${line//\"/\"\"}
    printf "\"%s\"\n" "$esc"
  done < "${STYLES_SORTED}"
} > dist/styles.csv

echo "Exporting XML ..."
{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<genres>'
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    esc=$(printf '%s' "$line" \
      | sed -e 's/&/\&amp;/g' \
            -e 's/</\&lt;/g' \
            -e 's/>/\&gt;/g')
    printf '  <genre>%s</genre>\n' "$esc"
  done < "${GENRES_SORTED}"
  echo '</genres>'
} > dist/genres.xml

{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<styles>'
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    esc=$(printf '%s' "$line" \
      | sed -e 's/&/\&amp;/g' \
            -e 's/</\&lt;/g' \
            -e 's/>/\&gt;/g')
    printf '  <style>%s</style>\n' "$esc"
  done < "${STYLES_SORTED}"
  echo '</styles>'
} > dist/styles.xml

echo "Completed export of genres and styles dataset"
echo "genres.json: $(jq length dist/genres.json) total entries"
echo "styles.json: $(jq length dist/styles.json) total entries"
echo "Source: ${FILENAME}"
