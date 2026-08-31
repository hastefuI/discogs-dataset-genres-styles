// test/api.test.cjs
const { describe, it } = require('node:test');
const { readJson } = require('./helpers.cjs');

const pkg = require('..');

describe('package entry point', () => {
  it('exports genres and styles as arrays', (t) => {
    t.assert.ok(Array.isArray(pkg.genres), 'genres should be an array');
    t.assert.ok(Array.isArray(pkg.styles), 'styles should be an array');
  });

  // Reads from disk rather than require(), so this compares what the package
  // exports against the files that ship in dist/.
  it('exports match the files in dist/', (t) => {
    t.assert.deepStrictEqual(pkg.genres, readJson('genres.json'));
    t.assert.deepStrictEqual(pkg.styles, readJson('styles.json'));
  });
});
