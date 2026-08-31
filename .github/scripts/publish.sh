#!/usr/bin/env bash
# Usage: ./publish.sh discogs_YYYYMMDD_releases.xml.gz
# Produces: Version bump commit, git tag, and npm package
# Requirements: git, npm, jq, grep

set -euo pipefail
IFS=$'\n\t'

SOURCE_FILE=""
DUMP_DATE=""
EXTRACTED_DATE=""
PKG_VERSION=""
TAG_NAME=""
RELEASE_TYPE="${RELEASE_TYPE:-minor}"

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
  EXTRACTED_DATE=$(date '+%Y-%m-%d')

  echo "Source file: $SOURCE_FILE"
  echo "Dump date: $DUMP_DATE"
  echo "Extracted date: $EXTRACTED_DATE"
}

bump_version_and_set_release_metadata() {
  echo "Bumping package version (${RELEASE_TYPE}) ..."
  npm version "${RELEASE_TYPE}" --no-git-tag-version

  git add package.json package-lock.json 2>/dev/null || true

  PKG_VERSION=$(jq -r .version package.json)
  [[ -n "$PKG_VERSION" ]] || {
    echo "Failed to read version from package.json" >&2
    exit 1
  }

  TAG_NAME="v${PKG_VERSION}+${DUMP_DATE}"

  echo "New version: $PKG_VERSION"
  echo "Git tag: $TAG_NAME"
}

commit_version_bump() {
  echo "Committing version bump ..."
  git commit -m "chore(release): bump version to v${PKG_VERSION}
    Source: ${SOURCE_FILE}
    Date: ${EXTRACTED_DATE}"
  git push origin HEAD
}

tag_and_publish_if_new() {
  # If tag already exists remotely, don't try to re-tag or re-publish.
  if git ls-remote --tags origin | grep -q "refs/tags/${TAG_NAME}$"; then
    echo "Tag $TAG_NAME already exists remotely, skipping tag + npm publish."
    set_github_output
    echo "Publish script completed (tag already existed)"
    exit 0
  fi

  echo "Creating git tag $TAG_NAME ..."
  git tag -a "$TAG_NAME" -m "Release v${PKG_VERSION} from ${SOURCE_FILE}"
  git push origin "$TAG_NAME"

  echo "Preparing for publish ..."
  npm ci
  npm publish --access public

  set_github_output
  echo "Publish script completed"
}

set_github_output() {
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
    {
      echo "tag_name=${TAG_NAME}"
      echo "extracted_date=${EXTRACTED_DATE}"
    } >> "$GITHUB_OUTPUT"
  fi
}

require_source_file "${1:-}"

bump_version_and_set_release_metadata
commit_version_bump
tag_and_publish_if_new
