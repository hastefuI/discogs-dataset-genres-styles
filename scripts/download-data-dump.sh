#!/usr/bin/env bash
# Downloads and verifies a specific Discogs Data Dump release file.
# Usage: ./download-data-dump.sh discogs_YYYYMMDD_releases.xml.gz
# Produces: Discogs Data Dump release file discogs_YYYYMMDD_releases.xml.gz
# Requirements: curl, sha256sum, mktemp, grep

set -euo pipefail
IFS=$'\n\t'

S3_BUCKET="https://discogs-data-dumps.s3-us-west-2.amazonaws.com"

(( $# == 1 )) || { echo "Usage: $0 discogs_YYYYMMDD_releases.xml.gz" >&2; exit 1; }

FILENAME="$1"

if [[ ! "$FILENAME" =~ ^discogs_([0-9]{8})_releases\.xml\.gz$ ]]; then
  echo "Error: Filename must match discogs_YYYYMMDD_releases.xml.gz" >&2
  exit 1
fi

DUMP_DATE="${BASH_REMATCH[1]}"
YEAR="${DUMP_DATE:0:4}"
KEY_DIR="data/${YEAR}"

URL="${S3_BUCKET}/${KEY_DIR}/${FILENAME}"
CHECKSUM_FILE="discogs_${DUMP_DATE}_CHECKSUM.txt"
CHECKSUM_URL="${S3_BUCKET}/${KEY_DIR}/${CHECKSUM_FILE}"

echo "Using releases dump: ${FILENAME}"
echo "Date: ${DUMP_DATE} | Year: ${YEAR}"
echo "Destination directory: ${KEY_DIR}"

download_if_needed() {
  local url="$1" outfile="$2" desc="$3"

  if [[ -f "$outfile" ]] && (( $(stat -c%s "$outfile" 2>/dev/null || stat -f%z "$outfile") > 0 )); then
    echo "Using cached $desc"
    return 0
  fi

  echo "Downloading $desc ..."
  local tmp
  tmp=$(mktemp "${outfile}.XXXXXX")
  trap 'rm -f "$tmp"' EXIT

  if curl -fL --fail --silent --show-error --output "$tmp" "$url"; then
    mv "$tmp" "$outfile"
    trap - EXIT
  else
    rm -f "$tmp"
    echo "Failed to download $desc from $url" >&2
    exit 1
  fi
}

download_if_needed "$URL"            "$FILENAME"       "$FILENAME"
download_if_needed "$CHECKSUM_URL"    "$CHECKSUM_FILE"  "checksum file"

echo "Verifying checksum for ${FILENAME} ..."

if ! checksum_line=$(grep -F " ${FILENAME}" "$CHECKSUM_FILE"); then
  echo "Error: No checksum entry found for ${FILENAME} in ${CHECKSUM_FILE}" >&2
  exit 1
fi

printf '%s\n' "${checksum_line//  / }" | sha256sum -c - >/dev/null

echo "Checksum OK for ${FILENAME}"
echo "Download completed $(du -h "$FILENAME" | cut -f1)"
