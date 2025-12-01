// test/api.test.cjs
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');

const pkg = require('..');

const dist = (file) => path.join(__dirname, '..', 'dist', file);

test('package exports genres and styles arrays', () => {
  assert.ok(Array.isArray(pkg.genres), 'pkg.genres should be an array');
  assert.ok(Array.isArray(pkg.styles), 'pkg.styles should be an array');
});

test('exports match dist JSON contents', () => {
  const genresJson = JSON.parse(fs.readFileSync(dist('genres.json'), 'utf8'));
  const stylesJson = JSON.parse(fs.readFileSync(dist('styles.json'), 'utf8'));

  assert.deepStrictEqual(pkg.genres, genresJson, 'pkg.genres should match dist/genres.json');
  assert.deepStrictEqual(pkg.styles, stylesJson, 'pkg.styles should match dist/styles.json');
});
