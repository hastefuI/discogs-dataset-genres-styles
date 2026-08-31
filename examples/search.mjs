// Case insensitive substring search across styles.
// Run with: node examples/search.mjs
import { styles } from 'discogs-dataset-genres-styles';

const search = (query) => {
  const needle = query.toLowerCase();
  return styles.filter((style) => style.toLowerCase().includes(needle));
};

for (const query of ['house', 'wave', 'jazz']) {
  const matches = search(query);
  console.log(`${query.padEnd(6)} ${String(matches.length).padStart(3)} matches  ${matches.slice(0, 4).join(', ')}`);
}
