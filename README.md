# discogs-dataset-genres-styles [![ci](https://github.com/hastefuI/discogs-dataset-genres-styles/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/hastefuI/discogs-dataset-genres-styles/actions/workflows/ci.yml) [![release](https://github.com/hastefuI/discogs-dataset-genres-styles/actions/workflows/release.yml/badge.svg)](https://github.com/hastefuI/discogs-dataset-genres-styles/actions/workflows/release.yml) [![npm](https://img.shields.io/npm/v/discogs-dataset-genres-styles.svg)](https://www.npmjs.com/package/discogs-dataset-genres-styles) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/hastefuI/discogs-dataset-genres-styles/blob/main/LICENSE)
A list of genres and styles extracted from the official [Discogs Data Dump](https://data.discogs.com), published as a dataset.

## Overview

The [Discogs API](https://www.discogs.com/developers) doesn't provide endpoints for retrieving genres and styles used across the Discogs database.

Developers that need the complete dataset must parse the data dump themselves or resort to scraping.

This repository automates downloading the latest Discogs Data Dump for releases, extracting every unique genre and style, and publishing the updates in standardized machine-readable data exchange formats:
- CSV: [`dist/genres.csv`](./dist/genres.csv), [`dist/styles.csv`](./dist/styles.csv)
- JSON: [`dist/genres.json`](./dist/genres.json), [`dist/styles.json`](./dist/styles.json)
- XML: [`dist/genres.xml`](./dist/genres.xml), [`dist/styles.xml`](./dist/styles.xml)

The derived dataset is made available as a tiny, tree-shakable NPM package with ESM, CommonJS, and TypeScript support out of the box.

## Installation

NPM:
```bash
$ npm install discogs-dataset-genres-styles
```

CDN:

Every file in `dist/` is also served by [jsDelivr](https://www.jsdelivr.com) and [unpkg](https://unpkg.com), for direct use without an install:

```
https://cdn.jsdelivr.net/npm/discogs-dataset-genres-styles/dist/genres.json
https://unpkg.com/discogs-dataset-genres-styles/dist/styles.csv
```

Add a version to pin a specific release:

```
https://cdn.jsdelivr.net/npm/discogs-dataset-genres-styles@1.9.0/dist/genres.json
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

Import a single dataset:

```javascript
// ESM
import genres from 'discogs-dataset-genres-styles/genres';
import styles from 'discogs-dataset-genres-styles/styles';

// CommonJS
const genres = require('discogs-dataset-genres-styles/genres');
const styles = require('discogs-dataset-genres-styles/styles');
```

## Examples

More examples, runnable with `node`, live in [`examples/`](./examples).

### Browser (no build step)

```javascript
const genres = await fetch(
  'https://cdn.jsdelivr.net/npm/discogs-dataset-genres-styles/dist/genres.json'
).then(response => response.json());

document.querySelector('select').append(
  ...genres.map(genre => new Option(genre))
);
```

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

<!-- LAST_UPDATED -->discogs_20260801_releases.xml.gz [325d0ad0] (extracted 2026-08-30)

## License

The code in this repository is licensed under the [MIT License](https://opensource.org/licenses/MIT), see [LICENSE](./LICENSE) for details.

The extracted dataset in [`dist/`](./dist) is derived from the official [Discogs Data Dump](https://data.discogs.com) and is released under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/).

Copyright (c) 2025-present hasteful
