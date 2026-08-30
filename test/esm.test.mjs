// test/esm.test.mjs
import test from 'node:test';
import assert from 'node:assert';
import { genres, styles } from '../index.mjs';
import defaultExport from '../index.mjs';
import { genres as pkgGenres, styles as pkgStyles } from 'discogs-dataset-genres-styles';
import subpathGenres from 'discogs-dataset-genres-styles/genres';
import subpathStyles from 'discogs-dataset-genres-styles/styles';

test('ESM named imports work', () => {
  assert.ok(Array.isArray(genres), 'genres should be an array');
  assert.ok(Array.isArray(styles), 'styles should be an array');
});

test('ESM default export works', () => {
  assert.deepStrictEqual(defaultExport.genres, genres);
  assert.deepStrictEqual(defaultExport.styles, styles);
});

test('ESM package entry resolves through the exports map', () => {
  assert.deepStrictEqual(pkgGenres, genres);
  assert.deepStrictEqual(pkgStyles, styles);
});

test('ESM subpath imports work without an import attribute', () => {
  assert.deepStrictEqual(subpathGenres, genres);
  assert.deepStrictEqual(subpathStyles, styles);
});
