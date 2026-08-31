// test/sanity.test.cjs
const { describe, it } = require('node:test');

const { genres, styles } = require('..');

describe('sanity', () => {
  it('contains expected common genres', (t) => {
    for (const genre of ['Electronic', 'Rock', 'Jazz', 'Hip Hop', 'Classical']) {
      t.assert.ok(genres.includes(genre), `Missing genre: ${genre}`);
    }
  });

  it('contains expected common styles', (t) => {
    for (const style of ['House', 'Techno', 'Ambient', 'Punk', 'Memphis Blues']) {
      t.assert.ok(styles.includes(style), `Missing style: ${style}`);
    }
  });
});
