// Check arbitrary strings against the Discogs vocabulary.
// Run with: node examples/validate.mjs
import { genres, styles } from 'discogs-dataset-genres-styles';

const known = new Set([...genres, ...styles]);

const isKnown = (value) => known.has(value);

for (const candidate of ['Rock', 'Techno', 'techno', 'Memphis Blues', 'Chiptune Polka']) {
  console.log(`${isKnown(candidate) ? 'known  ' : 'unknown'}  ${candidate}`);
}

console.log(`\n${known.size} terms across ${genres.length} genres and ${styles.length} styles.`);
