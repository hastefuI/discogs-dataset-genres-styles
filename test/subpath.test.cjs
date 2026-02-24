// test/subpath.test.cjs
const test = require('node:test');
const assert = require('node:assert');

test('subpath ./genres export works', () => {
  const genres = require('../dist/genres.json');
  assert.ok(Array.isArray(genres), 'genres should be an array');
  assert.ok(genres.length > 0, 'genres should not be empty');
});

test('subpath ./styles export works', () => {
  const styles = require('../dist/styles.json');
  assert.ok(Array.isArray(styles), 'styles should be an array');
  assert.ok(styles.length > 0, 'styles should not be empty');
});
