// test/data.test.cjs
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');

const dist = (file) => path.join(__dirname, '..', 'dist', file);

const cmpC = (a, b) =>
  Buffer.from(a, 'utf8').compare(Buffer.from(b, 'utf8'));

test('genres.json and styles.json are valid, sorted, unique arrays', () => {
  const genres = JSON.parse(fs.readFileSync(dist('genres.json'), 'utf8'));
  const styles = JSON.parse(fs.readFileSync(dist('styles.json'), 'utf8'));

  for (const [name, arr] of [['genres', genres], ['styles', styles]]) {
    assert.ok(Array.isArray(arr), `${name} should be an array`);
    assert.ok(arr.length > 0, `${name} should not be empty`);

    arr.forEach((v, i) => {
      assert.strictEqual(typeof v, 'string', `${name}[${i}] must be a string`);
      const trimmed = v.trim();
      assert.notStrictEqual(trimmed, '', `${name}[${i}] must not be empty`);
      assert.strictEqual(v, trimmed, `${name}[${i}] should not have leading/trailing whitespace`);
    });

    const set = new Set(arr);
    assert.strictEqual(set.size, arr.length, `${name} should contain unique values`);

    const sorted = [...arr].sort(cmpC);
    assert.deepStrictEqual(arr, sorted, `${name} should be sorted in C-locale order`);
  }
});

test('CSV files exist and match JSON length', () => {
  const genres = JSON.parse(fs.readFileSync(dist('genres.json'), 'utf8'));
  const styles = JSON.parse(fs.readFileSync(dist('styles.json'), 'utf8'));

  const checkCsv = (file, header, expectedLength) => {
    const contents = fs.readFileSync(dist(file), 'utf8').trimEnd();
    const lines = contents.split('\n');
    assert.ok(lines.length > 1, `${file} should have header + data`);
    assert.strictEqual(lines[0], header, `${file} header should be ${header}`);
    assert.strictEqual(
      lines.length - 1,
      expectedLength,
      `${file} rows should match JSON length`
    );
  };

  checkCsv('genres.csv', 'genre', genres.length);
  checkCsv('styles.csv', 'style', styles.length);
});

test('XML files exist and have expected root/elements count', () => {
  const genres = JSON.parse(fs.readFileSync(dist('genres.json'), 'utf8'));
  const styles = JSON.parse(fs.readFileSync(dist('styles.json'), 'utf8'));

  const checkXml = (file, rootTag, childTag, expectedLength) => {
    const xml = fs.readFileSync(dist(file), 'utf8');
    assert.ok(xml.startsWith('<?xml'), `${file} should start with XML declaration`);
    assert.ok(xml.includes(`<${rootTag}>`), `${file} should contain <${rootTag}> root`);
    const matches = xml.match(new RegExp(`<${childTag}>`, 'g')) || [];
    assert.strictEqual(
      matches.length,
      expectedLength,
      `${file} should have ${expectedLength} <${childTag}> elements`
    );
  };

  checkXml('genres.xml', 'genres', 'genre', genres.length);
  checkXml('styles.xml', 'styles', 'style', styles.length);
});
