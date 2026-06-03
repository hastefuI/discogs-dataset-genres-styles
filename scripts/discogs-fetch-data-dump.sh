#!/usr/bin/env bash
# Fetches the latest Discogs Data Dump releases filename for the current year.
# Usage: ./discogs-fetch-data-dump.sh
# Produces: Outputs the latest releases dump filename (e.g., discogs_20260201_releases.xml.gz)
# Requirements: curl, grep, sort

set -euo pipefail

TARGET="https://data.discogs.com"
YEAR=$(date +%Y)

USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36"

echo "Fetching latest Discogs releases data dump for year $YEAR ..." >&2

# Fetch the listing first so transient network/HTTP failures surface clearly and are
# retried (-f fails on HTTP errors, -S shows them), kept separate from the "no matching
# file" case handled by the empty-check below.
LISTING=$(curl -fsS -A "${USER_AGENT}" --retry 3 --retry-delay 5 --max-time 60 "${TARGET}/?prefix=data/${YEAR}/")

# `grep` exits non-zero when it finds no match; `|| true` stops `set -e`/`pipefail` from
# aborting here so the explicit empty-check below can emit a clear, actionable error
# instead of the script dying opaquely mid-pipeline.
FILENAME=$(
  printf '%s\n' "${LISTING}" \
    | grep -oE 'discogs_[0-9]{8}_releases\.xml\.gz' \
    | sort -V \
    | tail -1
) || true

if [[ -z "${FILENAME}" ]]; then
  echo "Error: Could not find a releases data dump for year ${YEAR}." >&2
  exit 1
fi

echo "Latest releases dump filename: ${FILENAME}" >&2
echo "$FILENAME"
