#!/usr/bin/env bash
# Fetches the latest Discogs Data Dump releases filename for the current year.
# Usage: ./discogs-fetch-data-dump.sh
# Produces: Outputs the latest releases dump filename (e.g., discogs_20260201_releases.xml.gz)
# Requirements: curl, grep, sort

set -euo pipefail

TARGET="https://data.discogs.com"
YEAR=$(date +%Y)

echo "Fetching latest Discogs releases data dump for year $YEAR ..." >&2

FILENAME=$(
  curl -s "${TARGET}/?prefix=data/${YEAR}/" \
    | grep -oE 'discogs_[0-9]{8}_releases\.xml\.gz' \
    | sort -V \
    | tail -1
)

if [[ -z "${FILENAME}" ]]; then
  echo "Error: Could not find data dump." >&2
  exit 1
fi

echo "Latest releases dump filename: ${FILENAME}" >&2
echo "$FILENAME"
