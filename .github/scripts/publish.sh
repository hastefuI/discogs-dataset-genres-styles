#!/usr/bin/env bash
# Updates README, commits genres and styles, optionally bumps version,
# tags release, and publishes to NPM when SHOULD_RELEASE=true.

set -euo pipefail
IFS=$'\n\t'

README_FILE="README.md"
DIST_DIR="dist"
MARKER="<!-- LAST_UPDATED -->"

SOURCE_FILE=""
DUMP_DATE=""
EXTRACTED_DATE=""
PKG_VERSION=""
TAG_NAME=""
RELEASE_NAME=""
SHOULD_RELEASE="${2:-false}"

require_source_file() {
  if (( $# == 0 )) && [[ -z "${SOURCE_FILE:-}" ]]; then
    echo "Error: SOURCE_FILE must be provided as argument or environment variable" >&2
    exit 1
  fi

  SOURCE_FILE="${1:-$SOURCE_FILE}"

  if [[ ! "$SOURCE_FILE" =~ ^discogs_([0-9]{8})_releases\.xml\.gz$ ]]; then
    echo "Error: SOURCE_FILE must be in format discogs_YYYYMMDD_releases.xml.gz" >&2
    exit 1
  fi

  DUMP_DATE="${BASH_REMATCH[1]}"
  EXTRACTED_DATE=$(date '+%d %B %Y')

  echo "Source file: $SOURCE_FILE"
  echo "Dump date: $DUMP_DATE"
  echo "Extracted date: $EXTRACTED_DATE"
  echo "SHOULD_RELEASE (from env): $SHOULD_RELEASE"
}

update_readme() {
  local updated_line="${MARKER}${SOURCE_FILE} (extracted ${EXTRACTED_DATE})"

  echo "Updated line: $updated_line"

  if ! grep -q "$MARKER" "$README_FILE"; then
    echo "Error: Marker '$MARKER' not found in $README_FILE" >&2
    exit 1
  fi

  echo "Updating $README_FILE ..."
  perl -i -pe "s|${MARKER}.*|${updated_line}|" "$README_FILE"
}

stage_dist_and_readme() {
  echo "Staging $DIST_DIR and $README_FILE ..."
  git add "$DIST_DIR" "$README_FILE" 2>/dev/null || true
}

commit_data_changes_if_any() {
  if git diff --cached --quiet; then
    echo "No changes in $DIST_DIR or $README_FILE to commit."
    return
  fi

  echo "Committing data changes ..."
  git commit -m "chore: update genres/styles from ${SOURCE_FILE}
    Source: ${SOURCE_FILE}
    Date: ${EXTRACTED_DATE}"
  git push origin HEAD
}

bump_version_and_set_release_metadata() {
  echo "Bumping package version (minor) ..."
  npm version minor --no-git-tag-version

  git add package.json package-lock.json 2>/dev/null || true

  PKG_VERSION=$(jq -r .version package.json)
  [[ -n "$PKG_VERSION" ]] || {
    echo "Failed to read version from package.json" >&2
    exit 1
  }

  TAG_NAME="v${PKG_VERSION}+${DUMP_DATE}"
  RELEASE_NAME="v${PKG_VERSION} – ${DUMP_DATE}"

  echo "New version: $PKG_VERSION"
  echo "Git tag: $TAG_NAME"
  echo "Release name: $RELEASE_NAME"
}

commit_version_bump() {
  echo "Committing version bump ..."
  git commit -m "chore: bump version to v${PKG_VERSION}
    Source: ${SOURCE_FILE}
    Date: ${EXTRACTED_DATE}"
  git push origin HEAD
}

tag_and_publish_if_new() {
  # If tag already exists remotely, don't try to re-tag or re-publish.
  if git ls-remote --tags origin | grep -q "refs/tags/${TAG_NAME}$"; then
    echo "Tag $TAG_NAME already exists remotely, skipping tag + npm publish."
    set_github_output "false"
    echo "Publish script completed (should_release=false, tag already existed)"
    exit 0
  fi

  echo "Creating git tag $TAG_NAME ..."
  git tag -a "$TAG_NAME" -m "Release v${PKG_VERSION} from ${SOURCE_FILE}"
  git push origin "$TAG_NAME"

  echo "Preparing for publish ..."
  npm ci
  npm publish --access public

  set_github_output "true"
  echo "Publish script completed (should_release=true)"
}

set_github_output() {
  local should_release_flag="$1"

  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
      echo "should_release=${should_release_flag}"
      echo "pkg_version=${PKG_VERSION}"
      echo "tag_name=${TAG_NAME}"
      echo "release_name=${RELEASE_NAME}"
      echo "extracted_date=${EXTRACTED_DATE}"
      echo "source_file=${SOURCE_FILE}"
    } >> "$GITHUB_OUTPUT"
  fi
}

require_source_file "${1:-}"

update_readme
stage_dist_and_readme
commit_data_changes_if_any

# If we are NOT releasing, we're done after updating/committing data.
if [[ "${SHOULD_RELEASE}" != "true" ]]; then
  echo "SHOULD_RELEASE is not 'true'; skipping version bump, tag, and npm publish."
  set_github_output "false"
  echo "Publish script completed (should_release=false)"
  exit 0
fi

echo "SHOULD_RELEASE is true; proceeding with version bump and publish."
bump_version_and_set_release_metadata
commit_version_bump
tag_and_publish_if_new
