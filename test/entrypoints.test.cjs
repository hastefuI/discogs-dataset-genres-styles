// test/entrypoints.test.cjs
const { describe, it } = require('node:test');
const fs = require('node:fs');
const { root } = require('./helpers.cjs');

const pkg = require('../package.json');

describe('entry points', () => {
  it('import no Node builtins', (t) => {
    for (const file of ['index.mjs', 'genres.mjs', 'styles.mjs']) {
      const source = fs.readFileSync(root(file), 'utf8');

      t.assert.ok(
        !/from\s+['"]node:/.test(source),
        `${file} must not import a node: builtin, it cannot be bundled for the browser`
      );
    }
  });

  it('every exports target exists', (t) => {
    for (const [subpath, conditions] of Object.entries(pkg.exports)) {
      for (const [condition, target] of Object.entries(conditions)) {
        t.assert.ok(
          fs.existsSync(root(target)),
          `exports["${subpath}"].${condition} points at missing ${target}`
        );
      }
    }
  });

  it('every files entry exists', (t) => {
    for (const entry of pkg.files) {
      t.assert.ok(fs.existsSync(root(entry)), `files entry ${entry} does not exist`);
    }
  });
});
