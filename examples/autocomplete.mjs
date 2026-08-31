// Prefix matching, the pattern behind a typeahead input.
// Run with: node examples/autocomplete.mjs
import { styles } from 'discogs-dataset-genres-styles';

const complete = (prefix, limit = 6) => {
  const needle = prefix.toLowerCase();
  return styles.filter((style) => style.toLowerCase().startsWith(needle)).slice(0, limit);
};

for (const prefix of ['te', 'amb', 'prog']) {
  console.log(`${prefix.padEnd(5)} -> ${complete(prefix).join(', ')}`);
}
