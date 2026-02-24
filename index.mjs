// index.mjs
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
export const genres = require("./dist/genres.json");
export const styles = require("./dist/styles.json");
export default { genres, styles };
