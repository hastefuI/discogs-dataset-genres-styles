// test/subpath.test.cjs
const { describe, it } = require('node:test');
const { readJson } = require('./helpers.cjs');

describe('subpath exports', () => {
  it('./genres resolves to the genres dataset', (t) => {
    const genres = require('discogs-dataset-genres-styles/genres');

    t.assert.ok(Array.isArray(genres), 'genres should be an array');
    t.assert.ok(genres.length > 0, 'genres should not be empty');
    t.assert.deepStrictEqual(genres, readJson('genres.json'));
  });

  it('./styles resolves to the styles dataset', (t) => {
    const styles = require('discogs-dataset-genres-styles/styles');

    t.assert.ok(Array.isArray(styles), 'styles should be an array');
    t.assert.ok(styles.length > 0, 'styles should not be empty');
    t.assert.deepStrictEqual(styles, readJson('styles.json'));
  });
});
