// test/esm.test.mjs
import test from 'node:test';
import assert from 'node:assert';
import { genres, styles } from '../index.mjs';
import defaultExport from '../index.mjs';

test('ESM named imports work', () => {
  assert.ok(Array.isArray(genres), 'genres should be an array');
  assert.ok(Array.isArray(styles), 'styles should be an array');
});

test('ESM default export works', () => {
  assert.deepStrictEqual(defaultExport.genres, genres);
  assert.deepStrictEqual(defaultExport.styles, styles);
});
