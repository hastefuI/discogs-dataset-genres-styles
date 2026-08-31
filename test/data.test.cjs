// test/data.test.cjs
const { describe, it } = require('node:test');
const { readText, compareBytes, datasets } = require('./helpers.cjs');

describe('JSON', () => {
  for (const { name, values } of datasets) {
    it(`${name}.json holds unique, sorted, unpadded strings`, (t) => {
      t.assert.ok(Array.isArray(values), `${name} should be an array`);
      t.assert.ok(values.length > 0, `${name} should not be empty`);

      values.forEach((value, i) => {
        t.assert.strictEqual(typeof value, 'string', `${name}[${i}] must be a string`);
        t.assert.notStrictEqual(value.trim(), '', `${name}[${i}] must not be empty`);
        t.assert.strictEqual(value, value.trim(), `${name}[${i}] must not be padded`);
      });

      t.assert.strictEqual(
        new Set(values).size,
        values.length,
        `${name} should contain unique values`
      );

      t.assert.deepStrictEqual(
        values,
        [...values].sort(compareBytes),
        `${name} should be sorted in C-locale order`
      );
    });
  }
});

describe('CSV', () => {
  for (const { name, singular, values } of datasets) {
    it(`${name}.csv has a ${singular} header and one row per entry`, (t) => {
      const lines = readText(`${name}.csv`).trimEnd().split('\n');

      t.assert.ok(lines.length > 1, `${name}.csv should have a header and data`);
      t.assert.strictEqual(lines[0], singular, `header should be ${singular}`);
      t.assert.strictEqual(
        lines.length - 1,
        values.length,
        `${name}.csv rows should match the JSON length`
      );
    });
  }
});

describe('XML', () => {
  for (const { name, singular, values } of datasets) {
    it(`${name}.xml declares <${name}> and one <${singular}> per entry`, (t) => {
      const xml = readText(`${name}.xml`);

      t.assert.ok(xml.startsWith('<?xml'), `${name}.xml should start with an XML declaration`);
      t.assert.ok(xml.includes(`<${name}>`), `${name}.xml should contain the <${name}> root`);

      const elements = xml.match(new RegExp(`<${singular}>`, 'g')) ?? [];
      t.assert.strictEqual(
        elements.length,
        values.length,
        `${name}.xml should have ${values.length} <${singular}> elements`
      );
    });
  }
});
