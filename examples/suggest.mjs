// Suggests genres and styles for an inexact query using a Levenshtein-distance lookup.
// Run with: node examples/suggest.mjs
import { genres, styles } from 'discogs-dataset-genres-styles';

const terms = [...new Set([...genres, ...styles])];

const distance = (a, b) => {
  const rows = Array.from({ length: a.length + 1 }, (_, i) =>
    Array.from({ length: b.length + 1 }, (_, j) => (i === 0 ? j : j === 0 ? i : 0))
  );
  for (let i = 1; i <= a.length; i++) {
    for (let j = 1; j <= b.length; j++) {
      rows[i][j] = Math.min(
        rows[i - 1][j] + 1,
        rows[i][j - 1] + 1,
        rows[i - 1][j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1)
      );
    }
  }
  return rows[a.length][b.length];
};

const suggest = (query, limit = 3) => {
  const needle = query.toLowerCase();
  const maxDistance = needle.length <= 4 ? 1 : 2;
  return terms
    .map((term) => ({ term, score: distance(needle, term.toLowerCase()) }))
    .filter(({ score }) => score > 0 && score <= maxDistance)
    .sort((a, b) => a.score - b.score || a.term.localeCompare(b.term))
    .slice(0, limit);
};

for (const query of ['technno', 'bosa nova', 'hiphop', 'chiptune polka']) {
  const hits = suggest(query);
  const found = hits.map(({ term, score }) => `${term} (${score})`).join(', ');
  const result = found
    ? `and found a close match ${found}`
    : 'did not find any matches';
  console.log(`Lookup for ${query} ${result}`);
}
