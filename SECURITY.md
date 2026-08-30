# Security Policy

## Reporting a Vulnerability

See [GitHub's private vulnerability reporting](https://github.com/hastefuI/discogs-dataset-genres-styles/security) feature for this repository to report a vulnerability.

Provide as much detail as possible to help reproduce the issue and assess impact.

## Scope

This package has no dependencies and no runtime code beyond reading the JSON files in `dist/`. Reports about the build pipeline, the published npm package, or the integrity of the extracted dataset are in scope.

The genres and styles are extracted from the official [Discogs Data Dump](https://data.discogs.com), which is verified against its published SHA-256 checksum before extraction. Inaccurate, missing, or objectionable terms in the source data are not security issues.
