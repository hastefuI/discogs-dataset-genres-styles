// test/encoding.test.cjs
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');

const dist = (file) => path.join(__dirname, '..', 'dist', file);

test('JSON files are valid UTF-8', () => {
  ['genres.json', 'styles.json'].forEach(file => {
    const content = fs.readFileSync(dist(file), 'utf8');
    JSON.parse(content);
  });
});

test('handles special characters in data', () => {
  const { genres, styles } = require('..');
  const all = [...genres, ...styles];
  all.forEach(item => {
    assert.strictEqual(typeof item, 'string');
    assert.ok(item.length >= 2, `Item too short: ${item}`);
  });
});
