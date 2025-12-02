# discogs-dataset-genre-styles [![build status](https://github.com/hastefuI/discogs-dataset-genres-styles/actions/workflows/build-test-publish.yml/badge.svg?branch=main)](https://github.com/hastefuI/discogs-dataset-genre-styles/actions/workflows/build-test-publish.yml) [![npm](https://img.shields.io/npm/v/discogs-dataset-genres-styles.svg)](https://www.npmjs.com/package/discogs-dataset-genres-styles) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/hastefuI/discogs-dataset-genre-styles/blob/main/LICENSE)
A list of genres and styles extracted from the official [Discogs Data Dump](https://data.discogs.com) that's published monthly as a dataset.

## Overview
The [Discogs API](https://www.discogs.com/developers) doesn't provide endpoints for retrieving genres and styles used across the Discogs database. Developers who need the complete dataset must parse the data dump themselves or resort to scraping.

This repository automates downloading the latest monthly Discogs Data Dump for releases, extracting every unique genre and style, and publishing the updates in standardized machine-readable data exchange formats:
- CSV: [`dist/genres.csv`](./dist/genres.csv), [`dist/styles.csv`](./dist/styles.csv)
- JSON: [`dist/genres.json`](./dist/genres.json), [`dist/styles.json`](./dist/styles.json)
- XML: [`dist/genres.xml`](./dist/genres.xml), [`dist/styles.xml`](./dist/styles.xml)

The derived dataset is made available as a tiny, tree-shakable NPM package with ESM, CommonJS, and TypeScript support out of the box.

## Installation
NPM:
```sh
$ npm install discogs-dataset-genres-styles
```

## Usage
```javascript
// ESM
import { genres, styles } from 'discogs-dataset-genres-styles';

// CommonJS
const { genres, styles } = require('discogs-dataset-genres-styles');

console.log(genres); // ["Electronic", "Rock", "Jazz", ...]
console.log(styles); // ["House", "Techno", "Alternative Rock", ...]
```

## Last Updated
<!-- LAST_UPDATED -->discogs_20251201_releases.xml.gz (extracted 02 December 2025)

## License

Licensed under [MIT License](https://opensource.org/licenses/MIT), see [LICENSE](./LICENSE) for details.

Copyright (c) 2025-present hasteful
