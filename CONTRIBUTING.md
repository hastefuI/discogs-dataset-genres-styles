# Contributing

Thanks for taking an interest in this project.

## Getting Started

The package has no dependencies, so there is nothing to install. Clone the repository and run the tests:

```bash
$ npm test
```

Node 24 is the supported version and is pinned in [`.nvmrc`](./.nvmrc). It is the current Node LTS release.

## Project Layout

Hand written:

- `index.cjs`, `index.mjs`, `genres.mjs`, `styles.mjs`: the package entry points
- `index.d.ts`, `types/`: the type declarations
- `scripts/`: the download and extraction scripts
- `test/`: the test suite

Generated, so please do not edit these by hand:

- `dist/`: the genres and styles in CSV, JSON, and XML
- the `LAST_UPDATED` line in `README.md`
- the `version` field in `package.json` and `package-lock.json`

## Tests

```bash
$ npm test
```

The suite uses the Node test runner and takes a few seconds. It runs on every push and pull request.

## Updating the Dataset

The dataset comes from the official [Discogs Data Dump](https://data.discogs.com). Rebuilding it downloads about 10 GB:

```bash
$ make dataset
```

That command downloads the latest dump, rebuilds `dist/`, and records the source dump in the README. Run `make help` to list the individual targets, or `make clean` to remove a downloaded dump.

Genres and styles change rarely. A rebuild often produces no change at all, which is a normal result.

## Commits

Please use [Conventional Commits](https://www.conventionalcommits.org):

```
fix: resolve the ESM subpath imports
docs: correct the badge links in the README
```

Sign commits where possible.

## Releases

Maintainers publish releases with the Release workflow in GitHub Actions. The workflow takes a patch, minor, or major bump, then tests, tags, publishes to NPM, and creates a GitHub Release.

## Security

Please report vulnerabilities through the process described in [SECURITY.md](./SECURITY.md) rather than in a public issue.
