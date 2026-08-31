// test/helpers.cjs
const fs = require('node:fs');
const path = require('node:path');

const root = (file) => path.join(__dirname, '..', file);

const dist = (file) => root(path.join('dist', file));

const readText = (file) => fs.readFileSync(dist(file), 'utf8');

const readJson = (file) => JSON.parse(readText(file));

// The extract script sorts with LC_ALL=C, so ordering is compared as UTF-8
// bytes. String comparison in JavaScript uses UTF-16 code units, which differs
// above the BMP.
const compareBytes = (a, b) =>
  Buffer.from(a, 'utf8').compare(Buffer.from(b, 'utf8'));

// Read once and share across the suite.
const datasets = [
  { name: 'genres', singular: 'genre', values: readJson('genres.json') },
  { name: 'styles', singular: 'style', values: readJson('styles.json') },
];

module.exports = { root, dist, readText, readJson, compareBytes, datasets };
