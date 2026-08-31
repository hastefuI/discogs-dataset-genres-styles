// test/esm.test.mjs
import { describe, it } from 'node:test';
import { genres, styles } from '../index.mjs';
import defaultExport from '../index.mjs';
import { genres as pkgGenres, styles as pkgStyles } from 'discogs-dataset-genres-styles';
import subpathGenres from 'discogs-dataset-genres-styles/genres';
import subpathStyles from 'discogs-dataset-genres-styles/styles';

describe('ESM', () => {
  it('named imports work', (t) => {
    t.assert.ok(Array.isArray(genres), 'genres should be an array');
    t.assert.ok(Array.isArray(styles), 'styles should be an array');
  });

  it('default export works', (t) => {
    t.assert.deepStrictEqual(defaultExport.genres, genres);
    t.assert.deepStrictEqual(defaultExport.styles, styles);
  });

  it('package entry resolves through the exports map', (t) => {
    t.assert.deepStrictEqual(pkgGenres, genres);
    t.assert.deepStrictEqual(pkgStyles, styles);
  });

  it('subpath imports work without an import attribute', (t) => {
    t.assert.deepStrictEqual(subpathGenres, genres);
    t.assert.deepStrictEqual(subpathStyles, styles);
  });
});
