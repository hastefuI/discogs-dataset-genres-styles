// test/entrypoints.test.cjs
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');

const pkg = require('../package.json');
const root = (file) => path.join(__dirname, '..', file);

test('ESM entry points import no Node builtins', () => {
  for (const file of ['index.mjs', 'genres.mjs', 'styles.mjs']) {
    const source = fs.readFileSync(root(file), 'utf8');
    assert.ok(
      !/from\s+['"]node:/.test(source),
      `${file} must not import a node: builtin, it cannot be bundled for the browser`
    );
  }
});

test('every exports target exists', () => {
  for (const [subpath, conditions] of Object.entries(pkg.exports)) {
    for (const [condition, target] of Object.entries(conditions)) {
      assert.ok(
        fs.existsSync(root(target)),
        `exports["${subpath}"].${condition} points at missing ${target}`
      );
    }
  }
});

test('every files entry exists', () => {
  for (const entry of pkg.files) {
    assert.ok(fs.existsSync(root(entry)), `files entry ${entry} does not exist`);
  }
});
