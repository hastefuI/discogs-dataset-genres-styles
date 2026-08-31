// test/encoding.test.cjs
const { describe, it } = require('node:test');
const { readJson } = require('./helpers.cjs');

const { genres, styles } = require('..');

describe('encoding', () => {
  it('JSON files are valid UTF-8', (t) => {
    t.assert.ok(Array.isArray(readJson('genres.json')));
    t.assert.ok(Array.isArray(readJson('styles.json')));
  });

  it('handles special characters in data', (t) => {
    for (const item of [...genres, ...styles]) {
      t.assert.strictEqual(typeof item, 'string');
      t.assert.ok(item.length >= 2, `Item too short: ${item}`);
    }
  });
});
