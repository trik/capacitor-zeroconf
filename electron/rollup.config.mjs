export default {
  input: 'electron/build/electron/src/zeroconf.js',
  output: [
    {
      file: 'electron/dist/plugin.js',
      format: 'cjs',
      sourcemap: true,
      inlineDynamicImports: true,
    },
  ],
  external: ['@capacitor/core', 'bonjour', 'os'],
};
