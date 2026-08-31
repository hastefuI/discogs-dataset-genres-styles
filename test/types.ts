// Type-level checks for the published declarations.
// Run with: npx tsc --noEmit --strict --module nodenext --moduleResolution nodenext test/types.ts
import { genres, styles } from 'discogs-dataset-genres-styles';
import genresOnly from 'discogs-dataset-genres-styles/genres';
import stylesOnly from 'discogs-dataset-genres-styles/styles';

const firstGenre: string = genres[0];
const styleCount: number = styles.length;
const mutableCopy: string[] = [...genres];
const fromSubpath: string = genresOnly[0];
const alsoSubpath: string = stylesOnly[0];

// @ts-expect-error the exported arrays are readonly
genres.push('not allowed');

// @ts-expect-error the exported arrays are readonly
styles.sort();

console.log(firstGenre, styleCount, mutableCopy.length, fromSubpath, alsoSubpath);
