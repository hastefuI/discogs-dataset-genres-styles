// Browser usage. CI bundles this file to prove the package stays free of
// Node builtins and can be shipped to a browser.
import genres from 'discogs-dataset-genres-styles/genres';

export function renderGenreOptions(select) {
  select.append(...genres.map((genre) => new Option(genre)));
}

export default genres;
