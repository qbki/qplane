import nodeResolve from "@rollup/plugin-node-resolve";
import { babel } from '@rollup/plugin-babel';

export default {
  output: { format: 'esm' },
  plugins: [
    nodeResolve({ jsnext: true }),
    babel({
      babelHelpers: 'bundled',
      extensions: [".ts", ".mts", ".mjs"],
    }),
  ],
};
