#!/usr/bin/env bash
# Downloads and verifies a specific Discogs Data Dump release file.
# Usage: ./discogs-download-data-dump.sh discogs_YYYYMMDD_releases.xml.gz
# Produces: Discogs Data Dump release file, named after the input filename
# Requirements: curl, sha256sum, mktemp, grep

set -euo pipefail
IFS=$'\n\t'

TARGET="https://data.discogs.com"

USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36"

usage() {
  echo "Usage: $0 discogs_YYYYMMDD_releases.xml.gz" >&2
  exit 1
}

(( $# >= 1 )) || usage

FILENAME="$1"

if [[ ! "$FILENAME" =~ ^discogs_([0-9]{8})_releases\.xml\.gz$ ]]; then
  echo "Error: Filename must match discogs_YYYYMMDD_releases.xml.gz" >&2
  exit 1
fi

DUMP_DATE="${BASH_REMATCH[1]}"
YEAR="${DUMP_DATE:0:4}"
REMOTE_PATH="data/${YEAR}"

URL="${TARGET}/?download=${REMOTE_PATH}/${FILENAME}"
CHECKSUM_FILE="discogs_${DUMP_DATE}_CHECKSUM.txt"
CHECKSUM_URL="${TARGET}/?download=${REMOTE_PATH}/${CHECKSUM_FILE}"

echo "Using releases dump: ${FILENAME}"
echo "Date: ${DUMP_DATE} | Year: ${YEAR}"

# Track temp files for cleanup
CLEANUP_FILES=()
cleanup() { rm -f "${CLEANUP_FILES[@]}"; }
trap cleanup EXIT INT TERM

is_cached() {
  local file="$1"
  [[ -f "$file" ]] && (( $(stat -c%s "$file" 2>/dev/null || stat -f%z "$file") > 0 ))
}

download_file() {
  local url="$1" outfile="$2"
  local tmp
  tmp=$(mktemp "${outfile}.XXXXXX")
  CLEANUP_FILES+=("$tmp")

  if curl -fL --http1.1 --fail --silent --show-error -A "${USER_AGENT}" --retry 3 --retry-delay 5 --output "$tmp" "$url"; then
    mv "$tmp" "$outfile"
  else
    echo "Failed to download from $url" >&2
    return 1
  fi
}

download_if_needed() {
  local url="$1" outfile="$2" desc="$3"

  if is_cached "$outfile"; then
    echo "Using cached $desc"
    return 0
  fi

  echo "Downloading $desc ..."
  download_file "$url" "$outfile"
}

download_if_needed "$URL"            "$FILENAME"         "$FILENAME"
download_if_needed "$CHECKSUM_URL"    "$CHECKSUM_FILE"  "checksum file"

echo "Verifying checksum for ${FILENAME} ..."

if ! checksum_line=$(grep -F " ${FILENAME}" "$CHECKSUM_FILE"); then
  echo "Error: No checksum entry found for ${FILENAME} in ${CHECKSUM_FILE}" >&2
  exit 1
fi

expected_hash=$(echo "$checksum_line" | awk '{print $1}')
actual_hash=$(sha256sum "$FILENAME" | awk '{print $1}')

if [[ "$expected_hash" != "$actual_hash" ]]; then
  echo "Checksum mismatch for ${FILENAME}" >&2
  echo "  Expected: ${expected_hash}" >&2
  echo "  Actual:   ${actual_hash}" >&2
  exit 1
fi

echo "Checksum OK for ${FILENAME}"
echo "Download completed $(du -h "$FILENAME" | cut -f1)"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "checksum=${expected_hash}" >> "$GITHUB_OUTPUT"
fi
