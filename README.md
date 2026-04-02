# discogs-dataset-genres-styles [![build status](https://github.com/hastefuI/discogs-dataset-genres-styles/actions/workflows/build-test-publish.yml/badge.svg?branch=main)](https://github.com/hastefuI/discogs-dataset-genre-styles/actions/workflows/build-test-publish.yml) [![npm](https://img.shields.io/npm/v/discogs-dataset-genres-styles.svg)](https://www.npmjs.com/package/discogs-dataset-genres-styles) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/hastefuI/discogs-dataset-genre-styles/blob/main/LICENSE)
A list of genres and styles extracted from the official [Discogs Data Dump](https://data.discogs.com) that's published monthly as a dataset.

## Overview

The [Discogs API](https://www.discogs.com/developers) doesn't provide endpoints for retrieving genres and styles used across the Discogs database.

Developers that need the complete dataset must parse the data dump themselves or resort to scraping.

This repository automates downloading the latest monthly Discogs Data Dump for releases, extracting every unique genre and style, and publishing the updates in standardized machine-readable data exchange formats:
- CSV: [`dist/genres.csv`](./dist/genres.csv), [`dist/styles.csv`](./dist/styles.csv)
- JSON: [`dist/genres.json`](./dist/genres.json), [`dist/styles.json`](./dist/styles.json)
- XML: [`dist/genres.xml`](./dist/genres.xml), [`dist/styles.xml`](./dist/styles.xml)

The derived dataset is made available as a tiny, tree-shakable NPM package with ESM, CommonJS, and TypeScript support out of the box.

## Installation

NPM:
```bash
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

## Examples

### HTMX

Server-side (Express):
```javascript
import { genres } from 'discogs-dataset-genres-styles';

app.get('/genres', (req, res) => {
  const html = genres.map(genre => `<option>${genre}</option>`).join('');
  res.send(html);
});
```

Client-side:
```xml
<select hx-get="/genres" hx-trigger="load"></select>
```

### React

```javascript
import { genres } from 'discogs-dataset-genres-styles';

function GenreSelect({ value, onChange }) {
  return (
    <select value={value} onChange={e => onChange(e.target.value)}>
      {genres.map(genre => <option key={genre}>{genre}</option>)}
    </select>
  );
}
```

### Vue

```javascript
<script setup>
import { genres } from 'discogs-dataset-genres-styles';
</script>

<template>
  <select>
    <option v-for="genre in genres" :key="genre">{{ genre }}</option>
  </select>
</template>
```

## Last Updated

This repository is up to date with the Discogs Data Dump last published:

<!-- LAST_UPDATED -->discogs_20260401_releases.xml.gz [a345a5ff] (extracted 2026-04-02)

## License

Licensed under [MIT License](https://opensource.org/licenses/MIT), see [LICENSE](./LICENSE) for details.

Copyright (c) 2025-present hasteful
