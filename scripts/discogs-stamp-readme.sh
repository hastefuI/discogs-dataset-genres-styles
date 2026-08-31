#!/usr/bin/env bash
# Records which Discogs Data Dump the dist/ files came from in the README.
# Usage: ./discogs-stamp-readme.sh discogs_YYYYMMDD_releases.xml.gz
# Produces: Updates the LAST_UPDATED marker line in README.md
# Requirements: sha256sum, perl, grep

set -euo pipefail

README_FILE="README.md"
MARKER="<!-- LAST_UPDATED -->"

SOURCE_FILE="${1:-}"

if [[ ! "${SOURCE_FILE}" =~ ^discogs_([0-9]{8})_releases\.xml\.gz$ ]]; then
  echo "Usage: $0 discogs_YYYYMMDD_releases.xml.gz" >&2
  exit 1
fi

if [[ ! -f "${SOURCE_FILE}" ]]; then
  echo "Error: ${SOURCE_FILE} not found." >&2
  exit 1
fi

if ! grep -q "${MARKER}" "${README_FILE}"; then
  echo "Error: Marker '${MARKER}' not found in ${README_FILE}" >&2
  exit 1
fi

# Prefer the checksum Discogs publishes alongside the dump. Fall back to
# hashing the file, which means another full read of about 10 GB.
CHECKSUM_FILE="discogs_${BASH_REMATCH[1]}_CHECKSUM.txt"
if [[ -f "${CHECKSUM_FILE}" ]] && grep -qF " ${SOURCE_FILE}" "${CHECKSUM_FILE}"; then
  CHECKSUM=$(grep -F " ${SOURCE_FILE}" "${CHECKSUM_FILE}" | awk '{print $1}')
else
  echo "No checksum file found, hashing ${SOURCE_FILE} ..." >&2
  CHECKSUM=$(sha256sum "${SOURCE_FILE}" | awk '{print $1}')
fi
EXTRACTED_DATE=$(date '+%Y-%m-%d')
LINE="${MARKER}${SOURCE_FILE} [${CHECKSUM:0:8}] (extracted ${EXTRACTED_DATE})"

perl -i -pe "s|${MARKER}.*|${LINE}|" "${README_FILE}"

echo "Stamped ${README_FILE}: ${SOURCE_FILE} [${CHECKSUM:0:8}] (extracted ${EXTRACTED_DATE})" >&2
