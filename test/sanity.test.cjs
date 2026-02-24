// test/sanity.test.cjs
const test = require('node:test');
const assert = require('node:assert');
const { genres, styles } = require('..');

test('contains expected common genres', () => {
  const expected = ['Electronic', 'Rock', 'Jazz', 'Hip Hop', 'Classical'];
  expected.forEach(g => {
    assert.ok(genres.includes(g), `Missing genre: ${g}`);
  });
});

test('contains expected common styles', () => {
  const expected = ['House', 'Techno', 'Ambient', 'Punk', 'Memphis Blues'];
  expected.forEach(s => {
    assert.ok(styles.includes(s), `Missing style: ${s}`);
  });
});
