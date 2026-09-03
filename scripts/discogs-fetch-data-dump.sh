#!/usr/bin/env bash
# Fetches the latest Discogs Data Dump releases filename.
# Usage: ./discogs-fetch-data-dump.sh
# Produces: Outputs the latest releases dump filename (e.g., discogs_20260201_releases.xml.gz)
# Requirements: curl, grep, sort, mktemp

set -euo pipefail

TARGET="https://data.discogs.com"

# Discogs publishes each dump on the first of the month, so the filename follows
# from the date. Probe the derived name before asking for a directory listing.
derived_filename() {
  printf 'discogs_%04d%02d01_releases.xml.gz' "$1" "$2"
}

# Reports the HTTP status for a dump, or 000 if the request itself failed. The
# status separates a dump that is not published yet (404) from a request that
# the server refused (403).
probe_status() {
  local filename="$1"
  local year="${filename:8:4}"
  curl -s -o /dev/null -I --max-time 30 \
    -w '%{http_code}' "${TARGET}/?download=data/${year}/${filename}" || printf '000'
}

try_derived() {
  local year="$1" month="$2" label="$3"
  local filename status
  filename=$(derived_filename "$year" "$month")
  status=$(probe_status "$filename")
  echo "Probing ${label} dump ${filename} ... HTTP ${status}" >&2
  if [[ "${status}" == "200" ]]; then
    printf '%s' "${filename}"
    return 0
  fi
  return 1
}

try_listing() {
  local year="$1"
  local tmp status filename
  tmp=$(mktemp)
  status=$(curl -s --max-time 60 \
    -o "${tmp}" -w '%{http_code}' "${TARGET}/?prefix=data/${year}/" || printf '000')
  echo "Requesting the ${year} directory listing ... HTTP ${status}" >&2
  filename=$(grep -oE 'discogs_[0-9]{8}_releases\.xml\.gz' "${tmp}" | sort -V | tail -1) || true
  rm -f "${tmp}"
  if [[ -n "${filename}" ]]; then
    printf '%s' "${filename}"
    return 0
  fi
  return 1
}

YEAR=$(date -u +%Y)
MONTH=$((10#$(date -u +%m)))

PREV_YEAR="${YEAR}"
PREV_MONTH=$((MONTH - 1))
if (( PREV_MONTH == 0 )); then
  PREV_MONTH=12
  PREV_YEAR=$((YEAR - 1))
fi

if FILENAME=$(try_derived "${YEAR}" "${MONTH}" "current month") \
  || FILENAME=$(try_derived "${PREV_YEAR}" "${PREV_MONTH}" "previous month") \
  || FILENAME=$(try_listing "${YEAR}"); then
  echo "Latest releases dump filename: ${FILENAME}" >&2
  echo "${FILENAME}"
else
  echo "Error: Could not determine a releases dump filename." >&2
  echo "The derived filename probe and the directory listing both failed." >&2
  exit 1
fi
